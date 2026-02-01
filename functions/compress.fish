# Archive compression command for Fish Archive Manager (fish 4.12+)
# Supports smart format selection, multiple compression algorithms, and comprehensive options

# Load optimized common functions
source (dirname (status --current-filename))/common/optimized_common.fish
# Load secure execution functions
source (dirname (status --current-filename))/common/safe_exec.fish
# Load secure archive operations
source (dirname (status --current-filename))/common/secure_archive_ops.fish
# Load format operations
source (dirname (status --current-filename))/common/format_operations.fish
# Load performance utilities
source (dirname (status --current-filename))/common/performance_utils.fish

function compress --description 'Create archives with intelligent format selection and modern Fish features'
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

Supported Formats:
  tar, tar.gz, tar.bz2, tar.xz, tar.zst, tar.lz4, tar.lz, tar.lzo, tar.br
  zip, 7z, rar (extract only)
  Short names: tgz, tbz2, txz, tzst, tlz4, tlz, tzo, tbr

Examples:
  compress backup.tar.zst ./mydata          # Fast compression with zstd
  compress -F tar.xz -L 9 logs.tar.xz /var/log  # Maximum compression
  compress --smart output.auto ./project    # Auto-select best format
  compress -e -p secret secure.zip docs/    # Create encrypted archive
  compress -x '*.tmp' -x '*.log' clean.tgz .  # Exclude patterns
  compress -i '*.txt' -i '*.md' docs.zip .  # Include patterns only
  compress -u existing.tar.gz newfile.txt  # Update existing archive
  compress -t 16 -F tar.zst fast.tzst large-dir/  # Multi-threaded
  compress -C /var/www -F tar.xz web-backup.txz html/  # Change directory
  compress --solid -F 7z backup.7z data/   # Solid 7z archive
  compress --checksum backup.tar.xz data/  # Generate checksum
  compress --split 100M large.zip huge-files/  # Split archive
  compress -v -L 7 -F tar.xz archive.txz files/  # Verbose output
"

    # Parse arguments with modern Fish features
    set -l options h/help F/format= L/level= t/threads= e/encrypt p/password= C/chdir= i/include-glob=+ x/exclude-glob=+ u/update a/append q/quiet v/verbose
    set -l long_options no-progress smart solid checksum split= dry-run timestamp auto-rename compare
    argparse $options $long_options -- $argv

    if test $status -ne 0
        echo $usage
        return 2
    end

    # Handle help
    if set -q _flag_help
        echo $usage
        return 0
    end

    # Check Fish compatibility
    __fish_archive_ensure_fish_compatibility; or begin
        __fish_archive_log warn "Continuing with limited functionality"
    end

    # Get output and input files
    set -l output $argv[1]
    set -l input_files $argv[2..-1]

    if test -z "$output"
        __fish_archive_log error "Output file not specified"
        echo $usage
        return 2
    end

    if test (count $input_files) -eq 0
        __fish_archive_log error "No input files specified"
        echo $usage
        return 2
    end

    # Set defaults
    set -l format auto
    set -l level 6
    set -l threads (__fish_archive_resolve_threads "$_flag_threads")
    set -l encrypt 0
    set -l password ""
    set -l chdir ""
    set -l include_patterns
    set -l exclude_patterns
    set -l update 0
    set -l append 0
    set -l quiet 0
    set -l verbose 0
    set -l no_progress 0
    set -l smart 0
    set -l solid 0
    set -l checksum 0
    set -l split_size ""
    set -l dry_run 0
    set -l timestamp 0
    set -l auto_rename 0
    set -l compare 0

    # Process flags
    if set -q _flag_format
        set format "$_flag_format"
    end

    if set -q _flag_level
        set level "$_flag_level"
    end

    if set -q _flag_encrypt
        set encrypt 1
    end

    if set -q _flag_password
        set password "$_flag_password"
    end

    if set -q _flag_chdir
        set chdir "$_flag_chdir"
    end

    if set -q _flag_include_glob
        set include_patterns $_flag_include_glob
    end

    if set -q _flag_exclude_glob
        set exclude_patterns $_flag_exclude_glob
    end

    if set -q _flag_update
        set update 1
    end

    if set -q _flag_append
        set append 1
    end

    if set -q _flag_quiet
        set quiet 1
    end

    if set -q _flag_verbose
        set verbose 1
    end

    if set -q _flag_no_progress
        set no_progress 1
    end

    if set -q _flag_smart
        set smart 1
    end

    if set -q _flag_solid
        set solid 1
    end

    if set -q _flag_checksum
        set checksum 1
    end

    if set -q _flag_split
        set split_size "$_flag_split"
    end

    if set -q _flag_dry_run
        set dry_run 1
    end

    if set -q _flag_timestamp
        set timestamp 1
    end

    if set -q _flag_auto_rename
        set auto_rename 1
    end

    if set -q _flag_compare
        set compare 1
    end

    # Determine format
    if test "$format" = auto; or test $smart -eq 1
        # Prefer zstd for small, pigz(gzip) for huge unless user specifies
        set format (__fish_archive_smart_format $input_files)
        __fish_archive_log info "Selected format: $format"
    else
        # Detect format from output filename if not specified
        set -l ext_format (__fish_archive_get_format_from_extension (__fish_archive_get_extension "$output"))
        if test "$ext_format" != unknown
            set format "$ext_format"
        end
    end

    # Validate format
    if not __fish_archive_validate_format_support "$format" compress
        return 1
    end

    # Validate compression level
    if not __fish_archive_validate_level $level "$format"
        __fish_archive_log error "Invalid compression level $level for format $format"
        return 1
    end

    # Collect and filter input files
    set -l valid_files (__fish_archive_collect_and_filter_files $input_files "$include_patterns" "$exclude_patterns")
    if test $status -ne 0
        return 1
    end

    # Handle output file naming
    if test $auto_rename -eq 1; or test $timestamp -eq 1
        set output (__fish_archive_handle_output_naming "$output" $auto_rename $timestamp)
    end

    # Get file sizes for progress and optimization
    set -l total_size 0
    for file in $valid_files
        set total_size (math "$total_size + "(__fish_archive_get_file_size "$file"))
    end

    # Optimize performance
    set -l perf_settings (__fish_archive_optimize_performance $total_size "compress")
    set -l optimal_threads (echo $perf_settings | cut -d' ' -f1)
    set -l enable_progress (echo $perf_settings | cut -d' ' -f2)

    # Override with user settings
    if test -n "$_flag_threads"
        set optimal_threads $threads
    end

    if test $no_progress -eq 1
        set enable_progress 0
    end

    # Prepare compression arguments
    set -l compress_args (__fish_archive_prepare_compression_args "$format" $level $optimal_threads $solid $encrypt "$password" "$output" $valid_files)
    if test $status -ne 0
        return 1
    end

    # Execute compression
    if test $dry_run -eq 1
        __fish_archive_log info "Would compress to: $output"
        __fish_archive_log info "Command: "(string join ' ' $compress_args)
        return 0
    end

    __fish_archive_log info "Compressing to: $output"

    # Execute with progress and measure
    set -l start_data (__fish_pack_start_measurement)

    if test $enable_progress -eq 1; and test $total_size -gt 10485760
        __fish_pack_exec_with_progress $compress_args $total_size
    else
        __fish_pack_safe_exec $compress_args
    end
    set -l cmd_status $status

    set -l perf_data (__fish_pack_end_measurement "$start_data")
    set -l duration (echo $perf_data | cut -d' ' -f1)
    set -l cpu_pct (echo $perf_data | cut -d' ' -f2)

    if test $cmd_status -eq 0
        __fish_archive_log info "Successfully compressed to: $output"

        # Generate checksum if requested
        if test $checksum -eq 1
            __fish_archive_generate_checksum "$output"
        end

        # Show compression stats and summary
        set -l compressed_size (__fish_archive_get_file_size "$output")
        __fish_archive_show_compression_stats $total_size $compressed_size "$format"
        __fish_archive_show_operation_summary compress "$format" (count $valid_files) $compressed_size $duration "$cpu_pct"

        return 0
    else
        __fish_archive_log error "Failed to compress to: $output"
        return 1
    end
end
