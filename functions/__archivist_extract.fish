# Archive extraction command for Archivist (fish 4.12+)
# Supports intelligent format detection, multiple archives, progress indication, and comprehensive options

function __archivist_extract --description 'Extract archives with smart detection and extensive format support'
    set -l usage "\
archx - Extract archives intelligently

Usage: archx [OPTIONS] FILE...

Options:
  -d, --dest DIR          Destination directory (default: derived from archive name)
  -f, --force             Overwrite existing files without prompting
  -s, --strip NUM         Strip NUM leading path components (tar archives)
  -p, --password PASS     Password for encrypted archives
  -t, --threads NUM       Number of threads for decompression (where supported)
  -q, --quiet             Suppress non-error output
  -v, --verbose           Enable verbose output
  -k, --keep              Keep archive file after extraction
      --no-progress       Disable progress indicators
      --list              List archive contents without extracting
      --test              Test archive integrity without extracting
      --overwrite         Always overwrite (alias for --force)
      --flat              Extract without preserving directory structure
      --dry-run           Show what would be done without executing
      --help              Display this help message

Supported Formats:
  - Compressed tar: .tar.gz, .tar.bz2, .tar.xz, .tar.zst, .tar.lz4, .tar.lz, .tar.lzo, .tar.br
  - Archives: .zip, .7z, .rar
  - Compressed files: .gz, .bz2, .xz, .zst, .lz4, .lz, .lzo, .br
  - Disk images: .iso
  - Package formats: .deb, .rpm (with bsdtar)
  - And more via automatic fallback to bsdtar/7z

Examples:
  archx file.tar.gz                    # Extract to ./file/
  archx -d output/ archive.zip         # Extract to ./output/
  archx --strip 1 dist.tar.xz          # Strip top-level directory
  archx -p secret encrypted.7z         # Extract encrypted archive
  archx --list archive.zip             # List contents only
  archx --test backup.tar.gz           # Test integrity
  archx *.tar.gz                       # Extract multiple archives
"

    # Parse arguments
    set -l dest ''
    set -l force 0
    set -l strip 0
    set -l password ''
    set -l threads ''
    set -l quiet 0
    set -l verbose 0
    set -l keep 1
    set -l show_progress 1
    set -l list_only 0
    set -l test_only 0
    set -l flat 0
    set -l dry_run 0

    argparse -i \
        'd/dest=' \
        'f/force' \
        's/strip=' \
        'p/password=' \
        't/threads=' \
        'q/quiet' \
        'v/verbose' \
        'k/keep' \
        'no-progress' \
        'list' \
        'test' \
        'overwrite' \
        'flat' \
        'dry-run' \
        'h/help' \
        -- $argv
    or begin
        echo $usage >&2
        return 2
    end

    # Handle flags
    set -q _flag_help; and echo $usage; and return 0
    set -q _flag_dest; and set dest (__archivist__sanitize_path $_flag_dest)
    set -q _flag_force; and set force 1
    set -q _flag_overwrite; and set force 1
    set -q _flag_strip; and set strip $_flag_strip
    set -q _flag_password; and set password $_flag_password
    set -q _flag_threads; and set threads $_flag_threads
    set -q _flag_quiet; and set quiet 1
    set -q _flag_verbose; and set verbose 1
    set -q _flag_keep; and set keep 1
    set -q _flag_no_progress; and set show_progress 0
    set -q _flag_list; and set list_only 1
    set -q _flag_test; and set test_only 1
    set -q _flag_flat; and set flat 1
    set -q _flag_dry_run; and set dry_run 1

    # Validate arguments
    set -l files $argv
    if test (count $files) -eq 0
        __archivist__log error "No archive files specified"
        echo $usage >&2
        return 2
    end

    # Verify basic tools
    __archivist__require_cmds file
    or return 127

    # Resolve thread count
    set -l thread_count (__archivist__resolve_threads $threads)

    # Process each archive
    set -l success_count 0
    set -l fail_count 0

    for archive in $files
        # Validate and normalize path
        set -l archive_path (__archivist__sanitize_path $archive)
        
        if not __archivist__validate_archive "$archive_path"
            set fail_count (math $fail_count + 1)
            continue
        end

        # Detect format
        set -l format (__archivist__detect_format "$archive_path")
        if test "$format" = unknown
            __archivist__log warn "Unknown format for $archive, attempting automatic detection"
        end

        # Determine extraction directory
        set -l extract_dir $dest
        if test -z "$extract_dir"
            set extract_dir (__archivist__default_extract_dir "$archive_path")
        end
        set extract_dir (__archivist__sanitize_path $extract_dir)

        # Handle different operation modes
        if test $list_only -eq 1
            __archivist__list_archive "$archive_path" $format
            set -l status_code $status
            if test $status_code -eq 0
                set success_count (math $success_count + 1)
            else
                set fail_count (math $fail_count + 1)
            end
            continue
        else if test $test_only -eq 1
            __archivist__test_archive "$archive_path" $format
            set -l status_code $status
            if test $status_code -eq 0
                set success_count (math $success_count + 1)
                test $quiet -eq 0; and __archivist__colorize green "✓ $archive: OK\n"
            else
                set fail_count (math $fail_count + 1)
                __archivist__colorize red "✗ $archive: FAILED\n"
            end
            continue
        end

        # Dry run mode
        if test $dry_run -eq 1
            __archivist__log info "[DRY-RUN] Would extract: $archive_path → $extract_dir"
            continue
        end

        # Create extraction directory
        if not test -d "$extract_dir"
            mkdir -p "$extract_dir"
            or begin
                __archivist__log error "Failed to create directory: $extract_dir"
                set fail_count (math $fail_count + 1)
                continue
            end
        else if test $force -eq 0
            # Directory exists and no force flag
            if test (count (ls -A "$extract_dir" 2>/dev/null)) -gt 0
                __archivist__log warn "Directory not empty: $extract_dir (use --force to overwrite)"
                set fail_count (math $fail_count + 1)
                continue
            end
        end

        # Perform extraction
        test $quiet -eq 0; and __archivist__log info "Extracting: $archive → $extract_dir"
        
        if __archivist__extract_archive "$archive_path" "$extract_dir" $format $strip $password $thread_count $show_progress $verbose $flat
            set success_count (math $success_count + 1)
            test $quiet -eq 0; and __archivist__colorize green "✓ Extracted: $archive\n"
        else
            set fail_count (math $fail_count + 1)
            __archivist__log error "Extraction failed: $archive"
        end
    end

    # Summary
    if test $quiet -eq 0; and test (math $success_count + $fail_count) -gt 1
        echo ""
        __archivist__log info "Extraction complete: $success_count succeeded, $fail_count failed"
    end

    # Return appropriate exit code
    test $fail_count -eq 0
end

# ============================================================================
# Internal: Archive Extraction Logic
# ============================================================================

function __archivist__extract_archive --description 'Internal: perform actual extraction'
    set -l archive $argv[1]
    set -l dest $argv[2]
    set -l format $argv[3]
    set -l strip $argv[4]
    set -l password $argv[5]
    set -l threads $argv[6]
    set -l progress $argv[7]
    set -l verbose $argv[8]
    set -l flat $argv[9]

    # Build extraction command based on format
    switch $format
        case tar.gz tgz
            __archivist__extract_tar "$archive" "$dest" gz $strip $threads $progress $verbose
            
        case tar.bz2 tbz2 tbz
            __archivist__extract_tar "$archive" "$dest" bz2 $strip $threads $progress $verbose
            
        case tar.xz txz
            __archivist__extract_tar "$archive" "$dest" xz $strip $threads $progress $verbose
            
        case tar.zst tzst
            __archivist__extract_tar "$archive" "$dest" zst $strip $threads $progress $verbose
            
        case tar.lz4 tlz4
            __archivist__extract_tar "$archive" "$dest" lz4 $strip $threads $progress $verbose
            
        case tar.lz tlz
            __archivist__extract_tar "$archive" "$dest" lz $strip $threads $progress $verbose
            
        case tar.lzo tzo
            __archivist__extract_tar "$archive" "$dest" lzo $strip $threads $progress $verbose
            
        case tar.br tbr
            __archivist__extract_tar "$archive" "$dest" br $strip $threads $progress $verbose
            
        case tar
            __archivist__extract_tar "$archive" "$dest" none $strip $threads $progress $verbose
            
        case zip
            __archivist__extract_zip "$archive" "$dest" "$password" $verbose
            
        case 7z
            __archivist__extract_7z "$archive" "$dest" "$password" $threads $verbose
            
        case rar
            __archivist__extract_rar "$archive" "$dest" "$password" $verbose
            
        case gzip gz
            __archivist__extract_compressed "$archive" "$dest" gunzip $threads
            
        case bzip2 bz2
            __archivist__extract_compressed "$archive" "$dest" bunzip2 $threads
            
        case xz
            __archivist__extract_compressed "$archive" "$dest" unxz $threads
            
        case zstd zst
            __archivist__extract_compressed "$archive" "$dest" unzstd $threads
            
        case lz4
            __archivist__extract_compressed "$archive" "$dest" unlz4 $threads
            
        case lzip lz
            __archivist__extract_compressed "$archive" "$dest" lunzip $threads
            
        case brotli br
            __archivist__extract_compressed "$archive" "$dest" brotli $threads
            
        case iso
            __archivist__extract_iso "$archive" "$dest" $verbose
            
        case deb rpm
            __archivist__extract_package "$archive" "$dest" $format $verbose
            
        case '*'
            # Try fallback extractors
            __archivist__extract_fallback "$archive" "$dest" $verbose
    end
end

# ============================================================================
# Format-Specific Extraction Functions
# ============================================================================

function __archivist__extract_tar --description 'Extract tar archives'
    set -l archive $argv[1]
    set -l dest $argv[2]
    set -l compression $argv[3]
    set -l strip $argv[4]
    set -l threads $argv[5]
    set -l progress $argv[6]
    set -l verbose $argv[7]

    __archivist__require_cmds tar; or return 127

    set -l tar_opts -xpf
    test $verbose -eq 1; and set -a tar_opts -v
    test $strip -gt 0; and set -a tar_opts --strip-components=$strip
    set -a tar_opts -C "$dest"

    # Add compression option
    switch $compression
        case gz
            set -a tar_opts -z
        case bz2
            set -a tar_opts -j
        case xz
            __archivist__require_cmds xz; or return 127
            set -a tar_opts -J
        case zst
            __archivist__require_cmds zstd; or return 127
            set -a tar_opts --zstd
        case lz4
            __archivist__require_cmds lz4; or return 127
            set -a tar_opts --use-compress-program=lz4
        case lz
            __archivist__require_cmds lzip; or return 127
            set -a tar_opts --lzip
        case lzo
            set -a tar_opts --lzop
        case br
            set -a tar_opts --use-compress-program=brotli
    end

    # Execute with or without progress
    if test $progress -eq 1; and __archivist__can_progress
        set -l size (stat -c %s "$archive" 2>/dev/null; or echo 0)
        if test $size -gt 10485760  # 10MB
            pv -s $size "$archive" | tar $tar_opts -f -
        else
            tar $tar_opts "$archive"
        end
    else
        tar $tar_opts "$archive"
    end
end

function __archivist__extract_zip --description 'Extract ZIP archives'
    set -l archive $argv[1]
    set -l dest $argv[2]
    set -l password $argv[3]
    set -l verbose $argv[4]

    __archivist__require_cmds unzip; or return 127

    set -l zip_opts -d "$dest"
    test $verbose -eq 0; and set -a zip_opts -q
    test -n "$password"; and set -a zip_opts -P "$password"

    unzip -o $zip_opts "$archive"
end

function __archivist__extract_7z --description 'Extract 7z archives'
    set -l archive $argv[1]
    set -l dest $argv[2]
    set -l password $argv[3]
    set -l threads $argv[4]
    set -l verbose $argv[5]

    __archivist__require_cmds 7z; or return 127

    set -l opts x -y -o"$dest"
    test -n "$password"; and set -a opts -p"$password"
    test $threads -gt 1; and set -a opts -mmt=$threads

    7z $opts "$archive" >/dev/null
end

function __archivist__extract_rar --description 'Extract RAR archives'
    set -l archive $argv[1]
    set -l dest $argv[2]
    set -l password $argv[3]
    set -l verbose $argv[4]

    if command -q unrar
        set -l opts x -y -idq
        test -n "$password"; and set -a opts -p"$password"
        unrar $opts "$archive" "$dest/"
    else if command -q bsdtar
        __archivist__log warn "unrar not found, using bsdtar (may have limitations)"
        bsdtar -xpf "$archive" -C "$dest"
    else
        __archivist__log error "Neither unrar nor bsdtar available for RAR extraction"
        return 127
    end
end

function __archivist__extract_compressed --description 'Extract single compressed files'
    set -l archive $argv[1]
    set -l dest $argv[2]
    set -l decompressor $argv[3]
    set -l threads $argv[4]

    # Determine output filename
    set -l basename (basename "$archive")
    set -l outfile "$dest/"(string replace -r '\\.[^.]+$' '' -- $basename)

    switch $decompressor
        case gunzip
            __archivist__require_cmds gzip; or return 127
            gzip -dc "$archive" > "$outfile"
            
        case bunzip2
            __archivist__require_cmds bzip2; or return 127
            bzip2 -dc "$archive" > "$outfile"
            
        case unxz
            __archivist__require_cmds xz; or return 127
            set -l xz_opts -dc
            test $threads -gt 1; and set -a xz_opts -T$threads
            xz $xz_opts "$archive" > "$outfile"
            
        case unzstd
            __archivist__require_cmds zstd; or return 127
            set -l zstd_opts -dc
            test $threads -gt 1; and set -a zstd_opts -T$threads
            zstd $zstd_opts "$archive" > "$outfile"
            
        case unlz4
            __archivist__require_cmds lz4; or return 127
            lz4 -dc "$archive" > "$outfile"
            
        case lunzip
            __archivist__require_cmds lzip; or return 127
            lzip -dc "$archive" > "$outfile"
            
        case brotli
            __archivist__require_cmds brotli; or return 127
            brotli -dc "$archive" > "$outfile"
    end
end

function __archivist__extract_iso --description 'Extract ISO images'
    set -l archive $argv[1]
    set -l dest $argv[2]
    set -l verbose $argv[3]

    if command -q bsdtar
        bsdtar -xpf "$archive" -C "$dest"
    else if command -q 7z
        7z x -y -o"$dest" "$archive" >/dev/null
    else
        __archivist__log error "No suitable tool for ISO extraction (need bsdtar or 7z)"
        return 127
    end
end

function __archivist__extract_package --description 'Extract package files (deb, rpm)'
    set -l archive $argv[1]
    set -l dest $argv[2]
    set -l format $argv[3]
    set -l verbose $argv[4]

    if command -q bsdtar
        bsdtar -xpf "$archive" -C "$dest"
    else
        __archivist__log error "bsdtar required for $format extraction"
        return 127
    end
end

function __archivist__extract_fallback --description 'Fallback extraction using bsdtar or 7z'
    set -l archive $argv[1]
    set -l dest $argv[2]
    set -l verbose $argv[3]

    if command -q bsdtar
        __archivist__log info "Attempting extraction with bsdtar"
        bsdtar -xpf "$archive" -C "$dest"
    else if command -q 7z
        __archivist__log info "Attempting extraction with 7z"
        7z x -y -o"$dest" "$archive" >/dev/null
    else
        __archivist__log error "No fallback extractor available (need bsdtar or 7z)"
        return 127
    end
end

# ============================================================================
# Archive Listing and Testing
# ============================================================================

function __archivist__list_archive --description 'List archive contents'
    set -l archive $argv[1]
    set -l format $argv[2]

    switch $format
        case tar tar.gz tgz tar.bz2 tbz2 tar.xz txz tar.zst tzst tar.lz4 tar.lz tar.lzo tar.br
            __archivist__require_cmds tar; or return 127
            set -l opts -tf
            
            switch $format
                case tar.gz tgz
                    set -a opts -z
                case tar.bz2 tbz2
                    set -a opts -j
                case tar.xz txz
                    set -a opts -J
                case tar.zst tzst
                    set -a opts --zstd
                case tar.lz4 tlz4
                    set -a opts --use-compress-program=lz4
                case tar.lz tlz
                    set -a opts --lzip
            end
            
            tar $opts "$archive"
            
        case zip
            __archivist__require_cmds unzip; or return 127
            unzip -l "$archive"
            
        case 7z
            __archivist__require_cmds 7z; or return 127
            7z l "$archive"
            
        case rar
            if command -q unrar
                unrar l "$archive"
            else if command -q bsdtar
                bsdtar -tf "$archive"
            else
                return 127
            end
            
        case '*'
            if command -q bsdtar
                bsdtar -tf "$archive"
            else if command -q 7z
                7z l "$archive"
            else
                __archivist__log error "No tool available for listing"
                return 127
            end
    end
end

function __archivist__test_archive --description 'Test archive integrity'
    set -l archive $argv[1]
    set -l format $argv[2]

    switch $format
        case tar tar.gz tgz tar.bz2 tbz2 tar.xz txz tar.zst tzst tar.lz4
            __archivist__require_cmds tar; or return 127
            set -l opts -tf
            
            switch $format
                case tar.gz tgz
                    set -a opts -z
                case tar.bz2 tbz2
                    set -a opts -j
                case tar.xz txz
                    set -a opts -J
                case tar.zst tzst
                    set -a opts --zstd
                case tar.lz4 tlz4
                    set -a opts --use-compress-program=lz4
            end
            
            tar $opts "$archive" >/dev/null 2>&1
            
        case zip
            __archivist__require_cmds unzip; or return 127
            unzip -t "$archive" >/dev/null 2>&1
            
        case 7z
            __archivist__require_cmds 7z; or return 127
            7z t "$archive" >/dev/null 2>&1
            
        case rar
            if command -q unrar
                unrar t "$archive" >/dev/null 2>&1
            else
                __archivist__log warn "Cannot test RAR without unrar"
                return 1
            end
            
        case gzip gz
            __archivist__require_cmds gzip; or return 127
            gzip -t "$archive" 2>&1
            
        case bzip2 bz2
            __archivist__require_cmds bzip2; or return 127
            bzip2 -t "$archive" 2>&1
            
        case xz
            __archivist__require_cmds xz; or return 127
            xz -t "$archive" 2>&1
            
        case zstd zst
            __archivist__require_cmds zstd; or return 127
            zstd -t "$archive" 2>&1
            
        case '*'
            if command -q 7z
                7z t "$archive" >/dev/null 2>&1
            else
                __archivist__log warn "Cannot test this format"
                return 1
            end
    end
end
