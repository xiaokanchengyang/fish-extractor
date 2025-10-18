# Archive compression command for Fish Extractor (fish 4.12+)
# Supports smart format selection, multiple compression algorithms, and comprehensive options

function __fish_extractor_compress --description 'Create archives with intelligent format selection and options'
    set -l usage "\
compress / compressor - Create archives with smart format selection and optimization

Usage: compress [OPTIONS] OUTPUT [INPUT...]
   or: compressor [OPTIONS] OUTPUT [INPUT...]

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
      --checksum          Generate checksum file after creation
      --split SIZE        Split archive into parts of SIZE (e.g., 100M, 1G)
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
  compress backup.tar.zst ./data             # Fast compression with zstd
  compress -F tar.xz logs.tar.xz /var/log    # Maximum compression
  compress --smart output.auto ./project     # Auto-select format
  compress -L 9 archive.7z files/            # Maximum 7z compression
  compress -e -p secret secure.zip docs/     # Encrypted ZIP
  compress -x '*.tmp' -x '*.log' out.tgz .   # Exclude patterns
  compress -u existing.tar.gz newfile.txt    # Update existing archive
  compress --checksum backup.txz data/       # Create with checksum
  compress --split 100M large.zip huge/      # Split into 100MB parts
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
    set -l gen_checksum 0
    set -l split_size ''
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
        'checksum' \
        'split=' \
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
    set -q _flag_chdir; and set chdir (__fish_extractor_sanitize_path $_flag_chdir)
    set -q _flag_include_glob; and set include_globs $_flag_include_glob
    set -q _flag_exclude_glob; and set exclude_globs $_flag_exclude_glob
    set -q _flag_update; and set update 1
    set -q _flag_append; and set append 1
    set -q _flag_quiet; and set quiet 1
    set -q _flag_verbose; and set verbose 1
    set -q _flag_no_progress; and set show_progress 0
    set -q _flag_smart; and set smart 1
    set -q _flag_solid; and set solid 1
    set -q _flag_checksum; and set gen_checksum 1
    set -q _flag_split; and set split_size $_flag_split
    set -q _flag_dry_run; and set dry_run 1

    # Validate arguments
    if test (count $argv) -lt 1
        __fish_extractor_log error "Output archive not specified"
        echo $usage >&2
        return 2
    end

    set -l output (__fish_extractor_sanitize_path $argv[1])
    set -l inputs $argv[2..-1]
    
    # Default to current directory if no inputs
    if test (count $inputs) -eq 0
        set inputs .
    end

    # Validate chdir if specified
    if test -n "$chdir"; and not test -d "$chdir"
        __fish_extractor_log error "Directory not found: $chdir"
        return 1
    end

    # Smart format selection
    if test $smart -eq 1; or test "$format" = auto
        # Detect from output filename if it has an extension
        set -l detected (__fish_extractor_detect_format "$output")
        if test "$detected" != unknown
            set format $detected
            __fish_extractor_log debug "Detected format from filename: $format"
        else
            # Analyze input content
            set format (__fish_extractor_smart_format $inputs)
            __fish_extractor_log info "Smart format selected: $format"
            
            # Update output filename with appropriate extension
            set output "$output."(string replace tar. '' -- $format)
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
    set -l thread_count (__fish_extractor_resolve_threads $threads)

    # Validate compression level
    set -l comp_level (__fish_extractor_validate_level $format $level)

    # Build file list
    set -l file_list
    if test -n "$chdir"
        pushd "$chdir" >/dev/null
        or begin
            __fish_extractor_log error "Failed to change directory to: $chdir"
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
        __fish_extractor_log error "No files to compress"
        return 1
    end

    # Calculate total size
    set -l total_size 0
    for file in $file_list
        if test -f "$file"
            set -l fsize (__fish_extractor_get_file_size "$file")
            set total_size (math $total_size + $fsize)
        end
    end

    # Dry run mode
    if test $dry_run -eq 1
        __fish_extractor_log info "[DRY-RUN] Would create: $output"
        __fish_extractor_log info "[DRY-RUN] Format: $format"
        __fish_extractor_log info "[DRY-RUN] Compression level: $comp_level"
        __fish_extractor_log info "[DRY-RUN] Files: "(count $file_list)" ("(__fish_extractor_human_size $total_size)")"
        test $verbose -eq 1; and printf "  - %s\n" $file_list
        return 0
    end

    # Show info
    if test $quiet -eq 0
        __fish_extractor_log info "Creating archive: $output"
        if test $verbose -eq 1
            __fish_extractor_log debug "  Format: $format"
            __fish_extractor_log debug "  Compression level: $comp_level"
            __fish_extractor_log debug "  Files: "(count $file_list)
            __fish_extractor_log debug "  Total size: "(__fish_extractor_human_size $total_size)
            __fish_extractor_log debug "  Threads: $thread_count"
        end
    end

    # Perform compression
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

    if __fish_extractor_create_archive $compress_opts
        if test $quiet -eq 0
            set -l out_size (__fish_extractor_get_file_size "$output")
            set -l ratio 0
            if test $total_size -gt 0
                set ratio (math -s1 "100 - ($out_size * 100 / $total_size)")
            end
            __fish_extractor_colorize green "✓ Created: $output ("(__fish_extractor_human_size $out_size)", $ratio% compression)\n"
        end
        
        # Generate checksum if requested
        if test $gen_checksum -eq 1
            set -l checksum_file "$output.sha256"
            __fish_extractor_log info "Generating checksum: $checksum_file"
            __fish_extractor_calculate_hash "$output" sha256 > "$checksum_file"
        end
        
        # Split archive if requested
        if test -n "$split_size"
            __fish_extractor_log info "Splitting archive into $split_size parts..."
            if __fish_extractor_split_archive "$output" "$split_size"
                __fish_extractor_log info "✓ Archive split complete"
            else
                __fish_extractor_log warn "Failed to split archive"
            end
        end
        
        return 0
    else
        __fish_extractor_log error "Failed to create archive: $output"
        return 1
    end
end

# ============================================================================
# Internal: Archive Creation Logic
# ============================================================================

function __fish_extractor_create_archive --description 'Internal: perform actual compression'
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
            __fish_extractor_create_tar "$output" $files none $level $threads $verbose $progress "$chdir" $update
            
        case tar.gz
            __fish_extractor_create_tar "$output" $files gzip $level $threads $verbose $progress "$chdir" $update
            
        case tar.bz2
            __fish_extractor_create_tar "$output" $files bzip2 $level $threads $verbose $progress "$chdir" $update
            
        case tar.xz
            __fish_extractor_create_tar "$output" $files xz $level $threads $verbose $progress "$chdir" $update
            
        case tar.zst
            __fish_extractor_create_tar "$output" $files zstd $level $threads $verbose $progress "$chdir" $update
            
        case tar.lz4
            __fish_extractor_create_tar "$output" $files lz4 $level $threads $verbose $progress "$chdir" $update
            
        case tar.lz
            __fish_extractor_create_tar "$output" $files lzip $level $threads $verbose $progress "$chdir" $update
            
        case tar.lzo
            __fish_extractor_create_tar "$output" $files lzop $level $threads $verbose $progress "$chdir" $update
            
        case tar.br
            __fish_extractor_create_tar "$output" $files brotli $level $threads $verbose $progress "$chdir" $update
            
        case zip
            __fish_extractor_create_zip "$output" $files $level $encrypt "$password" $verbose $update "$chdir"
            
        case 7z
            __fish_extractor_create_7z "$output" $files $level $threads $encrypt "$password" $solid $verbose $update "$chdir"
            
        case '*'
            __fish_extractor_log error "Unsupported format: $format"
            return 2
    end
end

# ============================================================================
# Format-Specific Compression Functions
# ============================================================================

function __fish_extractor_create_tar --description 'Create tar archives with optional compression'
    set -l output $argv[1]
    set -l files $argv[2..-9]
    set -l compressor $argv[-8]
    set -l level $argv[-7]
    set -l threads $argv[-6]
    set -l verbose $argv[-5]
    set -l progress $argv[-4]
    set -l chdir $argv[-3]
    set -l update $argv[-2]

    __fish_extractor_require_cmds tar; or return 127

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
                __fish_extractor_require_cmds gzip; or return 127
                # Try pigz for parallel compression if available
                if command -q pigz
                    if test $progress -eq 1; and __fish_extractor_can_progress
                        tar $tar_opts -f - $files | pigz -$level -p $threads | __fish_extractor_progress_bar 0 > "$output"
                    else
                        tar $tar_opts -f - $files | pigz -$level -p $threads > "$output"
                    end
                else
                    if test $progress -eq 1; and __fish_extractor_can_progress
                        tar $tar_opts -f - $files | gzip -$level | __fish_extractor_progress_bar 0 > "$output"
                    else
                        set -a tar_opts -z -f "$output"
                        env GZIP=-$level tar $tar_opts $files
                    end
                end
                
            case bzip2
                __fish_extractor_require_cmds bzip2; or return 127
                # Try pbzip2 for parallel compression if available
                if command -q pbzip2
                    if test $progress -eq 1; and __fish_extractor_can_progress
                        tar $tar_opts -f - $files | pbzip2 -$level -p$threads | __fish_extractor_progress_bar 0 > "$output"
                    else
                        tar $tar_opts -f - $files | pbzip2 -$level -p$threads > "$output"
                    end
                else
                    if test $progress -eq 1; and __fish_extractor_can_progress
                        tar $tar_opts -f - $files | bzip2 -$level | __fish_extractor_progress_bar 0 > "$output"
                    else
                        set -a tar_opts -j -f "$output"
                        env BZIP2=-$level tar $tar_opts $files
                    end
                end
                
            case xz
                __fish_extractor_require_cmds xz; or return 127
                if test $progress -eq 1; and __fish_extractor_can_progress
                    tar $tar_opts -f - $files | xz -$level -T$threads | __fish_extractor_progress_bar 0 > "$output"
                else
                    set -a tar_opts --use-compress-program="xz -$level -T$threads" -f "$output"
                    tar $tar_opts $files
                end
                
            case zstd
                __fish_extractor_require_cmds zstd; or return 127
                if test $progress -eq 1; and __fish_extractor_can_progress
                    tar $tar_opts -f - $files | zstd -$level -T$threads -q | __fish_extractor_progress_bar 0 > "$output"
                else
                    set -a tar_opts --use-compress-program="zstd -$level -T$threads -q" -f "$output"
                    tar $tar_opts $files
                end
                
            case lz4
                __fish_extractor_require_cmds lz4; or return 127
                if test $progress -eq 1; and __fish_extractor_can_progress
                    tar $tar_opts -f - $files | lz4 -$level | __fish_extractor_progress_bar 0 > "$output"
                else
                    set -a tar_opts --use-compress-program="lz4 -$level" -f "$output"
                    tar $tar_opts $files
                end
                
            case lzip
                __fish_extractor_require_cmds lzip; or return 127
                set -a tar_opts --lzip -f "$output"
                env LZIP=-$level tar $tar_opts $files
                
            case lzop
                __fish_extractor_require_cmds lzop; or return 127
                set -a tar_opts --lzop -f "$output"
                env LZOP=-$level tar $tar_opts $files
                
            case brotli
                __fish_extractor_require_cmds brotli; or return 127
                if test $progress -eq 1; and __fish_extractor_can_progress
                    tar $tar_opts -f - $files | brotli -$level | __fish_extractor_progress_bar 0 > "$output"
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

function __fish_extractor_create_zip --description 'Create ZIP archives'
    set -l output $argv[1]
    set -l files $argv[2..-8]
    set -l level $argv[-7]
    set -l encrypt $argv[-6]
    set -l password $argv[-5]
    set -l verbose $argv[-4]
    set -l update $argv[-3]
    set -l chdir $argv[-2]

    __fish_extractor_require_cmds zip; or return 127

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

function __fish_extractor_create_7z --description 'Create 7z archives'
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

    __fish_extractor_require_cmds 7z; or return 127

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
        if test $verbose -eq 1
            7z $opts "$output" $files
        else
            7z $opts "$output" $files >/dev/null
        end
        set -l status_code $status
        popd >/dev/null
        return $status_code
    else
        if test $verbose -eq 1
            7z $opts "$output" $files
        else
            7z $opts "$output" $files >/dev/null
        end
    end
end

# ============================================================================
# Archive Splitting
# ============================================================================

function __fish_extractor_split_archive --description 'Split archive into smaller parts'
    set -l archive $argv[1]
    set -l size $argv[2]
    
    test -f "$archive"; or return 1
    
    if command -q split
        # Convert size to bytes for split command
        set -l size_bytes (string replace -r 'M$' '000000' -- $size)
        set size_bytes (string replace -r 'G$' '000000000' -- $size_bytes)
        set size_bytes (string replace -r 'K$' '000' -- $size_bytes)
        
        split -b $size_bytes "$archive" "$archive.part"
        
        # Create a join script
        echo "#!/bin/sh" > "$archive.join.sh"
        echo "cat $archive.part* > $archive" >> "$archive.join.sh"
        chmod +x "$archive.join.sh"
        
        return 0
    else
        __fish_extractor_log error "'split' command not found"
        return 1
    end
end
