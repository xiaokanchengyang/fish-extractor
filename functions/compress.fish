# Archive compression command for Fish Archive Manager (fish 4.12+)
# Supports smart format selection, multiple compression algorithms, and comprehensive options

# Load validation helpers
source (dirname (status --current-filename))/validation.fish
# Load format handlers
source (dirname (status --current-filename))/format_handlers.fish
# Load error handling
source (dirname (status --current-filename))/error_handling.fish
# Load common functions
source (dirname (status --current-filename))/common/archive_operations.fish
source (dirname (status --current-filename))/common/file_operations.fish
source (dirname (status --current-filename))/common/format_operations.fish

function compress --description 'Create archives with intelligent format selection and options'
    set -l usage "\
compress - Create archives with smart format selection and optimization

Usage: compress [OPTIONS] OUTPUT [INPUT...]

Options:
  -F, --format FMT        Archive format (see formats below)
  -L, --level NUM         Compression level (format-dependent, typically 1-9)
  -t, --threads NUM       Number of threads for compression
  -e, --encrypt           Enable encryption (zip/7z only)
  -p, --password PASS     Encryption password
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
      --timestamp         Add timestamp to archive name
      --auto-rename       Automatically rename if output exists
      --compare           Compare compression efficiency across formats
      --help              Display this help message

Smart Format Selection:
  With --smart or format 'auto', automatically chooses best format:
  - High text content (70%+) → tar.xz (maximum compression)
  - Mixed content (30-70%) → tar.gz (balanced)
  - Binary content (<30%) → tar.zst (fast, efficient)

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
    set -l add_timestamp 0
    set -l auto_rename 0
    set -l compare_formats 0

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
        'timestamp' \
        'auto-rename' \
        'compare' \
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
    set -q _flag_chdir; and set chdir (sanitize_path $_flag_chdir)
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
    set -q _flag_timestamp; and set add_timestamp 1
    set -q _flag_auto_rename; and set auto_rename 1
    set -q _flag_compare; and set compare_formats 1

    # Validate arguments
    if test (count $argv) -lt 1
        log error "Output archive not specified"
        echo $usage >&2
        return 2
    end

    set -l output (sanitize_path $argv[1])
    set -l inputs $argv[2..-1]
    
    # Default to current directory if no inputs
    if test (count $inputs) -eq 0
        set inputs .
    end
    
    # Prepare output path with timestamp and auto-rename
    set output (validate_output_path "$output" $auto_rename $add_timestamp)
    if test $auto_rename -eq 1; and test $quiet -eq 0
        log info "Auto-renamed to: $output"
    end

    # Validate chdir if specified
    if test -n "$chdir"; and not test -d "$chdir"
        log error "Directory not found: $chdir"
        return 1
    end

    # Smart format selection and normalization
    set -l format_result (normalize_output_format "$output" $format $smart)
    set format $format_result[1]
    set output $format_result[2]

    # Resolve thread count
    set -l thread_count (resolve_threads $threads)

    # Validate compression level
    set -l comp_level (validate_level $format $level)

    # Collect and filter files
    set -l file_list (collect_input_files $inputs $chdir)
    set file_list (apply_file_filters $file_list $include_globs $exclude_globs)
    
    # Validate file list
    if not validate_file_list $file_list "compress"
        return 1
    end
    
    # Calculate total size
    set -l total_size (calculate_total_size $file_list)

    # Dry run mode
    if test $dry_run -eq 1
        log info "[DRY-RUN] Would create: $output"
        log info "[DRY-RUN] Format: $format"
        log info "[DRY-RUN] Compression level: $comp_level"
        log info "[DRY-RUN] Files: "(count $file_list)" ("(human_size $total_size)")"
        test $verbose -eq 1; and printf "  - %s\n" $file_list
        return 0
    end

    # Show info
    if test $quiet -eq 0
        log info "Creating archive: $output"
        if test $verbose -eq 1
            log debug "  Format: $format"
            log debug "  Compression level: $comp_level"
            log debug "  Threads: $thread_count"
        end
        show_file_statistics $file_list $total_size $verbose $quiet
    end

    # Prepare environment
    if not prepare_archive_environment "compress" $format $thread_count $verbose
        return $status
    end
    
    # Validate archive operation
    if not validate_archive_common "$output" "compress" $format "$password" $encrypt
        return $status
    end
    
    # Create output directory
    if not create_output_directory "$output" $quiet
        return $status
    end
    
    # Perform compression
    if create_archive "$output" $file_list $format $comp_level $thread_count $encrypt "$password" "$chdir" $update $append $verbose $show_progress $solid
        if test $quiet -eq 0
            set -l out_size (get_file_size "$output")
            set -l ratio 0
            if test $total_size -gt 0
                set ratio (math -s1 "100 - ($out_size * 100 / $total_size)")
            end
            colorize green "✓ Created: $output ("(human_size $out_size)", $ratio% compression)\n"
        end
        
        # Generate checksum if requested
        if test $gen_checksum -eq 1
            generate_checksum_file "$output" "sha256" $quiet
        end
        
        # Split archive if requested
        if test -n "$split_size"
            log info "Splitting archive into $split_size parts..."
            if split_archive_file "$output" "$split_size" $quiet
                log info "✓ Archive split complete"
            else
                log warn "Failed to split archive"
            end
        end
        
        return 0
    else
        log error "Failed to create archive: $output"
        return 1
    end
end

# ============================================================================
# Internal: Archive Creation Logic
# ============================================================================

function create_archive --description 'Internal: perform actual compression'
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

    # Use common archive operation function
    execute_format_command $format "compress" $output $files $level $threads $encrypt "$password" $solid $verbose $update "$chdir"
end

# ============================================================================
# Format-Specific Compression Functions
# ============================================================================

# Note: Format-specific compression functions are now handled by common functions
# in functions/common/format_operations.fish

# ============================================================================
# Archive Splitting
# ============================================================================

# Note: Archive splitting function is now handled by common functions
# in functions/common/file_operations.fish