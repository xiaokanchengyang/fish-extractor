# Archive compression command for Archivist (fish 4.12+)
# Supports smart format selection, multiple compression algorithms, and comprehensive options

function __archivist_compress --description 'Create archives with intelligent format selection and options'
    set -l usage "\
archc - Create archives intelligently

Usage: archc [OPTIONS] OUTPUT [INPUT...]

Options:
  -F, --format FMT        Archive format (see formats below)
  -L, --level NUM         Compression level (format-dependent, typically 1-9)
  -t, --threads NUM       Number of threads for compression
  -e, --encrypt           Enable encryption (zip/7z only)
  -p, --password PASS     Password for encryption
  -C, --chdir DIR         Change to directory before adding files
  -i, --include-glob PAT  Include only matching files (can be repeated)
  -x, --exclude-glob PAT  Exclude matching files (can be repeated)
  -u, --update            Update existing archive (add/replace changed files)
  -a, --append            Append to existing archive
  -q, --quiet             Suppress non-error output
  -v, --verbose           Enable verbose output
      --no-progress       Disable progress indicators
      --smart             Automatically choose best format
      --solid             Create solid archive (7z only)
      --dry-run           Show what would be done without executing
      --help              Display this help message

Formats:
  tar           Uncompressed tar
  tar.gz, tgz   Gzip compressed tar (balanced)
  tar.bz2, tbz2 Bzip2 compressed tar (high compression, slow)
  tar.xz, txz   XZ compressed tar (best compression for text)
  tar.zst, tzst Zstd compressed tar (fast, good compression)
  tar.lz4, tlz4 LZ4 compressed tar (very fast, lower compression)
  tar.lz, tlz   Lzip compressed tar
  tar.lzo, tzo  LZO compressed tar
  tar.br, tbr   Brotli compressed tar
  zip           ZIP archive (universal compatibility)
  7z            7-Zip archive (high compression, supports encryption)
  auto          Automatically detect best format (default)

Examples:
  archc backup.tar.zst ./data           # Fast compression with zstd
  archc -F tar.xz logs.tar.xz /var/log  # Maximum compression
  archc --smart output.auto ./project   # Auto-select format
  archc -L 9 archive.7z files/          # Maximum 7z compression
  archc -e -p secret secure.zip docs/   # Encrypted ZIP
  archc -x '*.tmp' -x '*.log' out.tgz . # Exclude patterns
  archc -u existing.tar.gz newfile.txt  # Update existing archive
"

    # Parse arguments
    set -l format auto
    set -l level ''
    set -l threads ''
    set -l encrypt 0
    set -l password ''
    set -l chdir ''
    set -l include_globs
    set -l exclude_globs
    set -l update 0
    set -l append 0
    set -l quiet 0
    set -l verbose 0
    set -l show_progress 1
    set -l smart 0
    set -l solid 0
    set -l dry_run 0

    argparse -i \
        'F/format=' \
        'L/level=' \
        't/threads=' \
        'e/encrypt' \
        'p/password=' \
        'C/chdir=' \
        'i/include-glob=+' \
        'x/exclude-glob=+' \
        'u/update' \
        'a/append' \
        'q/quiet' \
        'v/verbose' \
        'no-progress' \
        'smart' \
        'solid' \
        'dry-run' \
        'h/help' \
        -- $argv
    or begin
        echo $usage >&2
        return 2
    end

    # Handle flags
    set -q _flag_help; and echo $usage; and return 0
    set -q _flag_format; and set format (string lower -- $_flag_format)
    set -q _flag_level; and set level $_flag_level
    set -q _flag_threads; and set threads $_flag_threads
    set -q _flag_encrypt; and set encrypt 1
    set -q _flag_password; and set password $_flag_password
    set -q _flag_chdir; and set chdir (__archivist__sanitize_path $_flag_chdir)
    set -q _flag_include_glob; and set include_globs $_flag_include_glob
    set -q _flag_exclude_glob; and set exclude_globs $_flag_exclude_glob
    set -q _flag_update; and set update 1
    set -q _flag_append; and set append 1
    set -q _flag_quiet; and set quiet 1
    set -q _flag_verbose; and set verbose 1
    set -q _flag_no_progress; and set show_progress 0
    set -q _flag_smart; and set smart 1
    set -q _flag_solid; and set solid 1
    set -q _flag_dry_run; and set dry_run 1

    # Validate arguments
    if test (count $argv) -lt 1
        __archivist__log error "Output archive not specified"
        echo $usage >&2
        return 2
    end

    set -l output (__archivist__sanitize_path $argv[1])
    set -l inputs $argv[2..-1]
    
    # Default to current directory if no inputs
    if test (count $inputs) -eq 0
        set inputs .
    end

    # Validate chdir if specified
    if test -n "$chdir"; and not test -d "$chdir"
        __archivist__log error "Directory not found: $chdir"
        return 1
    end

    # Smart format selection
    if test $smart -eq 1; or test "$format" = auto
        # Detect from output filename if it has an extension
        set -l detected (__archivist__detect_format "$output")
        if test "$detected" != unknown
            set format $detected
            __archivist__log debug "Detected format from filename: $format"
        else
            # Analyze input content
            set format (__archivist__smart_format $inputs)
            __archivist__log info "Smart format selected: $format"
        end
    end

    # Normalize format aliases
    switch $format
        case tgz
            set format tar.gz
        case tbz tbz2
            set format tar.bz2
        case txz
            set format tar.xz
        case tzst
            set format tar.zst
        case tlz4
            set format tar.lz4
        case tlz
            set format tar.lz
        case tzo
            set format tar.lzo
        case tbr
            set format tar.br
        case '7zip'
            set format 7z
    end

    # Resolve thread count
    set -l thread_count (__archivist__resolve_threads $threads)

    # Validate compression level
    set -l comp_level (__archivist__validate_level $format $level)

    # Build file list
    set -l file_list
    if test -n "$chdir"
        pushd "$chdir" >/dev/null
        or begin
            __archivist__log error "Failed to change directory to: $chdir"
            return 1
        end
    end

    # Collect input files
    for input in $inputs
        if test -e "$input"
            set -a file_list "$input"
        else
            # Try glob expansion
            set -l expanded (eval echo "$input" 2>/dev/null)
            for item in $expanded
                test -e "$item"; and set -a file_list "$item"
            end
        end
    end

    # Apply include/exclude filters
    if test (count $include_globs) -gt 0
        set -l filtered
        for file in $file_list
            for pattern in $include_globs
                if string match -q -- $pattern $file
                    set -a filtered $file
                    break
                end
            end
        end
        set file_list $filtered
    end

    if test (count $exclude_globs) -gt 0
        set -l filtered
        for file in $file_list
            set -l excluded 0
            for pattern in $exclude_globs
                if string match -q -- $pattern $file
                    set excluded 1
                    break
                end
            end
            test $excluded -eq 0; and set -a filtered $file
        end
        set file_list $filtered
    end

    if test -n "$chdir"
        popd >/dev/null
    end

    # Verify we have files to compress
    if test (count $file_list) -eq 0
        __archivist__log error "No files to compress"
        return 1
    end

    # Dry run mode
    if test $dry_run -eq 1
        __archivist__log info "[DRY-RUN] Would create: $output"
        __archivist__log info "[DRY-RUN] Format: $format"
        __archivist__log info "[DRY-RUN] Files: "(count $file_list)
        test $verbose -eq 1; and printf "  - %s\n" $file_list
        return 0
    end

    # Perform compression
    test $quiet -eq 0; and __archivist__log info "Creating archive: $output"
    
    set -l compress_opts \
        "$output" \
        $file_list \
        $format \
        $comp_level \
        $thread_count \
        $encrypt \
        "$password" \
        "$chdir" \
        $update \
        $append \
        $verbose \
        $show_progress \
        $solid

    if __archivist__create_archive $compress_opts
        test $quiet -eq 0; and __archivist__colorize green "✓ Created: $output\n"
        return 0
    else
        __archivist__log error "Failed to create archive: $output"
        return 1
    end
end

# ============================================================================
# Internal: Archive Creation Logic
# ============================================================================

function __archivist__create_archive --description 'Internal: perform actual compression'
    set -l output $argv[1]
    set -l files $argv[2..-13]  # Files come before the fixed options
    set -l format $argv[-12]
    set -l level $argv[-11]
    set -l threads $argv[-10]
    set -l encrypt $argv[-9]
    set -l password $argv[-8]
    set -l chdir $argv[-7]
    set -l update $argv[-6]
    set -l append $argv[-5]
    set -l verbose $argv[-4]
    set -l progress $argv[-3]
    set -l solid $argv[-2]

    # Dispatch to format-specific handler
    switch $format
        case tar
            __archivist__create_tar "$output" $files none $level $threads $verbose $progress "$chdir" $update
            
        case tar.gz
            __archivist__create_tar "$output" $files gzip $level $threads $verbose $progress "$chdir" $update
            
        case tar.bz2
            __archivist__create_tar "$output" $files bzip2 $level $threads $verbose $progress "$chdir" $update
            
        case tar.xz
            __archivist__create_tar "$output" $files xz $level $threads $verbose $progress "$chdir" $update
            
        case tar.zst
            __archivist__create_tar "$output" $files zstd $level $threads $verbose $progress "$chdir" $update
            
        case tar.lz4
            __archivist__create_tar "$output" $files lz4 $level $threads $verbose $progress "$chdir" $update
            
        case tar.lz
            __archivist__create_tar "$output" $files lzip $level $threads $verbose $progress "$chdir" $update
            
        case tar.lzo
            __archivist__create_tar "$output" $files lzop $level $threads $verbose $progress "$chdir" $update
            
        case tar.br
            __archivist__create_tar "$output" $files brotli $level $threads $verbose $progress "$chdir" $update
            
        case zip
            __archivist__create_zip "$output" $files $level $encrypt "$password" $verbose $update "$chdir"
            
        case 7z
            __archivist__create_7z "$output" $files $level $threads $encrypt "$password" $solid $verbose $update "$chdir"
            
        case '*'
            __archivist__log error "Unsupported format: $format"
            return 2
    end
end

# ============================================================================
# Format-Specific Compression Functions
# ============================================================================

function __archivist__create_tar --description 'Create tar archives with optional compression'
    set -l output $argv[1]
    set -l files $argv[2..-9]
    set -l compressor $argv[-8]
    set -l level $argv[-7]
    set -l threads $argv[-6]
    set -l verbose $argv[-5]
    set -l progress $argv[-4]
    set -l chdir $argv[-3]
    set -l update $argv[-2]

    __archivist__require_cmds tar; or return 127

    # Build tar options
    set -l tar_opts
    
    # Operation mode
    if test $update -eq 1; and test -f "$output"
        set -a tar_opts -u  # Update
    else
        set -a tar_opts -c  # Create
    end
    
    test $verbose -eq 1; and set -a tar_opts -v
    test -n "$chdir"; and set -a tar_opts -C "$chdir"

    # Handle compression
    if test "$compressor" != none
        switch $compressor
            case gzip
                __archivist__require_cmds gzip; or return 127
                if test $progress -eq 1; and __archivist__can_progress
                    # Use pipeline with pv
                    if test -n "$chdir"
                        tar $tar_opts -f - $files | pv | gzip -$level > "$output"
                    else
                        tar $tar_opts -f - $files | pv | gzip -$level > "$output"
                    end
                else
                    set -a tar_opts -z -f "$output"
                    env GZIP=-$level tar $tar_opts $files
                end
                
            case bzip2
                __archivist__require_cmds bzip2; or return 127
                if test $progress -eq 1; and __archivist__can_progress
                    tar $tar_opts -f - $files | pv | bzip2 -$level > "$output"
                else
                    set -a tar_opts -j -f "$output"
                    env BZIP2=-$level tar $tar_opts $files
                end
                
            case xz
                __archivist__require_cmds xz; or return 127
                if test $progress -eq 1; and __archivist__can_progress
                    tar $tar_opts -f - $files | pv | xz -$level -T$threads > "$output"
                else
                    set -a tar_opts --use-compress-program="xz -$level -T$threads" -f "$output"
                    tar $tar_opts $files
                end
                
            case zstd
                __archivist__require_cmds zstd; or return 127
                if test $progress -eq 1; and __archivist__can_progress
                    tar $tar_opts -f - $files | pv | zstd -$level -T$threads -q -o "$output"
                else
                    set -a tar_opts --use-compress-program="zstd -$level -T$threads -q" -f "$output"
                    tar $tar_opts $files
                end
                
            case lz4
                __archivist__require_cmds lz4; or return 127
                if test $progress -eq 1; and __archivist__can_progress
                    tar $tar_opts -f - $files | pv | lz4 -$level > "$output"
                else
                    set -a tar_opts --use-compress-program="lz4 -$level" -f "$output"
                    tar $tar_opts $files
                end
                
            case lzip
                __archivist__require_cmds lzip; or return 127
                set -a tar_opts --lzip -f "$output"
                env LZIP=-$level tar $tar_opts $files
                
            case lzop
                __archivist__require_cmds lzop; or return 127
                set -a tar_opts --lzop -f "$output"
                env LZOP=-$level tar $tar_opts $files
                
            case brotli
                __archivist__require_cmds brotli; or return 127
                if test $progress -eq 1; and __archivist__can_progress
                    tar $tar_opts -f - $files | pv | brotli -$level -o "$output"
                else
                    tar $tar_opts -f - $files | brotli -$level -o "$output"
                end
        end
    else
        # Uncompressed tar
        set -a tar_opts -f "$output"
        tar $tar_opts $files
    end
end

function __archivist__create_zip --description 'Create ZIP archives'
    set -l output $argv[1]
    set -l files $argv[2..-8]
    set -l level $argv[-7]
    set -l encrypt $argv[-6]
    set -l password $argv[-5]
    set -l verbose $argv[-4]
    set -l update $argv[-3]
    set -l chdir $argv[-2]

    __archivist__require_cmds zip; or return 127

    set -l zip_opts
    
    # Operation mode
    if test $update -eq 1; and test -f "$output"
        set -a zip_opts -u  # Update
    else
        set -a zip_opts -r  # Recursive
    end
    
    # Compression level
    set -a zip_opts -$level
    
    # Encryption
    if test $encrypt -eq 1
        set -a zip_opts -e
        if test -n "$password"
            set -a zip_opts -P "$password"
        end
    end
    
    # Verbosity
    test $verbose -eq 0; and set -a zip_opts -q

    # Change directory if needed
    if test -n "$chdir"
        pushd "$chdir" >/dev/null
        zip $zip_opts "$output" $files
        set -l status_code $status
        popd >/dev/null
        return $status_code
    else
        zip $zip_opts "$output" $files
    end
end

function __archivist__create_7z --description 'Create 7z archives'
    set -l output $argv[1]
    set -l files $argv[2..-10]
    set -l level $argv[-9]
    set -l threads $argv[-8]
    set -l encrypt $argv[-7]
    set -l password $argv[-6]
    set -l solid $argv[-5]
    set -l verbose $argv[-4]
    set -l update $argv[-3]
    set -l chdir $argv[-2]

    __archivist__require_cmds 7z; or return 127

    set -l opts
    
    # Operation mode
    if test $update -eq 1; and test -f "$output"
        set opts u  # Update
    else
        set opts a  # Add
    end
    
    # Options
    set -a opts -y  # Yes to all
    set -a opts -mx=$level  # Compression level
    test $threads -gt 1; and set -a opts -mmt=$threads
    test $solid -eq 1; and set -a opts -ms=on
    
    # Encryption
    if test $encrypt -eq 1
        set -a opts -mhe=on  # Encrypt headers
        test -n "$password"; and set -a opts -p"$password"
    end

    # Change directory if needed
    if test -n "$chdir"
        pushd "$chdir" >/dev/null
        7z $opts "$output" $files >/dev/null
        set -l status_code $status
        popd >/dev/null
        return $status_code
    else
        7z $opts "$output" $files >/dev/null
    end
end
