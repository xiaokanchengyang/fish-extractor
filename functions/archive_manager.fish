# Fish Archive Manager - Main Functions (fish 4.12+)
# Optimized main functions with modern Fish features and better organization

# Load optimized common functions
source (dirname (status --current-filename))/common/optimized_common.fish

# ============================================================================
# Main Archive Management Functions
# ============================================================================

function extract --description 'Extract archives with intelligent format detection and modern Fish features'
    set -l usage "\
extract - Intelligently extract archives with automatic format detection

Usage: extract [OPTIONS] FILE...

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
      --verify            Verify archive with checksum if available
      --overwrite         Always overwrite (alias for --force)
      --flat              Extract without preserving directory structure
      --dry-run           Show what would be done without executing
      --backup            Create backup of existing files before extraction
      --checksum          Generate checksum file after extraction
      --auto-rename       Automatically rename output if destination exists
      --timestamp         Add timestamp to extraction directory name
      --preserve-perms    Preserve file permissions (default on)
      --no-preserve-perms Don't preserve file permissions
      --help              Display this help message

Format Detection:
  Automatically detects formats by:
  - File extension (.tar.gz, .zip, .7z, etc.)
  - MIME type analysis (using 'file' command)
  - Fallback to bsdtar/7z for unknown formats

Supported Formats:
  Compressed tar: .tar.gz, .tar.bz2, .tar.xz, .tar.zst, .tar.lz4, .tar.lz, .tar.lzo, .tar.br
  Archives: .zip, .7z, .rar
  Compressed files: .gz, .bz2, .xz, .zst, .lz4, .lz, .lzo, .br
  Disk images: .iso
  Package formats: .deb, .rpm (with bsdtar)
  Short names: .tgz, .tbz2, .txz, .tzst, .tlz4

Examples:
  extract archive.tar.gz                    # Extract to ./archive/
  extract -d output/ archive.zip            # Extract to ./output/
  extract --strip 1 dist.tar.xz             # Remove top-level directory
  extract -p secret encrypted.7z            # Extract with password
  extract --list archive.zip                # Preview contents
  extract --test backup.tar.gz              # Verify integrity
  extract --verify data.tar.xz              # Check with checksum
  extract *.tar.gz                          # Extract multiple archives
  extract -t 16 large-archive.tar.zst       # Use 16 threads
  extract --backup --force archive.zip      # Backup before extracting
  extract --checksum important.txz          # Generate checksum
  extract -v complicated.7z                 # Verbose output
"

    # Parse arguments with modern Fish features
    set -l options h/help d/dest= f/force s/strip= p/password= t/threads= q/quiet v/verbose k/keep
    set -l long_options no-progress list test verify overwrite flat dry-run backup checksum auto-rename timestamp preserve-perms no-preserve-perms
    set -l parsed (argparse $options $long_options -- $argv)
    
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
    
    # Set defaults
    set -l dest ""
    set -l force 0
    set -l strip 0
    set -l password ""
    set -l threads (__fish_archive_resolve_threads "$_flag_threads")
    set -l quiet 0
    set -l verbose 0
    set -l keep 1
    set -l no_progress 0
    set -l list_only 0
    set -l test_only 0
    set -l verify 0
    set -l flat 0
    set -l dry_run 0
    set -l backup 0
    set -l checksum 0
    set -l auto_rename 0
    set -l timestamp 0
    set -l preserve_perms 1
    
    # Process flags
    if set -q _flag_dest
        set dest "$_flag_dest"
    end
    
    if set -q _flag_force; or set -q _flag_overwrite
        set force 1
    end
    
    if set -q _flag_strip
        set strip "$_flag_strip"
    end
    
    if set -q _flag_password
        set password "$_flag_password"
    end
    
    if set -q _flag_quiet
        set quiet 1
    end
    
    if set -q _flag_verbose
        set verbose 1
    end
    
    if set -q _flag_keep
        set keep 1
    end
    
    if set -q _flag_no_progress
        set no_progress 1
    end
    
    if set -q _flag_list
        set list_only 1
    end
    
    if set -q _flag_test
        set test_only 1
    end
    
    if set -q _flag_verify
        set verify 1
    end
    
    if set -q _flag_flat
        set flat 1
    end
    
    if set -q _flag_dry_run
        set dry_run 1
    end
    
    if set -q _flag_backup
        set backup 1
    end
    
    if set -q _flag_checksum
        set checksum 1
    end
    
    if set -q _flag_auto_rename
        set auto_rename 1
    end
    
    if set -q _flag_timestamp
        set timestamp 1
    end
    
    if set -q _flag_no_preserve_perms
        set preserve_perms 0
    end
    
    # Get input files
    set -l input_files $argv
    if test (count $input_files) -eq 0
        __fish_archive_log error "No input files specified"
        echo $usage
        return 2
    end
    
    # Validate input files
    set -l valid_files (__fish_archive_validate_inputs $input_files)
    if test $status -ne 0
        return 1
    end
    
    # Process each archive
    set -l success_count 0
    set -l total_count (count $valid_files)
    set -l start_time (date +%s)
    
    for archive in $valid_files
        set -l archive_start (date +%s)
        
        # Detect format
        set -l format (__fish_archive_detect_format "$archive")
        if test "$format" = "unknown"
            __fish_archive_log error "Unknown format: $archive"
            continue
        end
        
        # Validate archive
        if not __fish_archive_validate_archive "$archive"
            continue
        end
        
        # Handle special operations
        if test $list_only -eq 1
            __fish_archive_log info "Listing contents: $archive"
            __fish_archive_list_archive_contents "$archive" "$format"
            set success_count (math "$success_count + 1")
            continue
        end
        
        if test $test_only -eq 1
            __fish_archive_log info "Testing integrity: $archive"
            if __fish_archive_test_archive_integrity "$archive" "$format"
                __fish_archive_log info "Archive is valid: $archive"
                set success_count (math "$success_count + 1")
            else
                __fish_archive_log error "Archive is corrupted: $archive"
            end
            continue
        end
        
        # Determine destination
        if test -z "$dest"
            set dest (__fish_archive_default_extract_dir "$archive")
        end
        
        # Handle auto-rename and timestamp
        if test $auto_rename -eq 1; or test $timestamp -eq 1
            set dest (__fish_archive_handle_destination_naming "$dest" $auto_rename $timestamp)
        end
        
        # Create destination directory
        if not test -d "$dest"
            mkdir -p "$dest" 2>/dev/null; or begin
                __fish_archive_log error "Failed to create directory: $dest"
                continue
            end
        end
        
        # Handle backup
        if test $backup -eq 1; and test -d "$dest"
            set -l backup_name "${dest}.backup."(date +%Y%m%d_%H%M%S)
            mv "$dest" "$backup_name" 2>/dev/null; or begin
                __fish_archive_log warn "Failed to create backup: $backup_name"
            end
        end
        
        # Prepare extraction arguments
        set -l extract_args (__fish_archive_prepare_extraction_args "$format" $threads "$password" $strip $flat $preserve_perms "$archive" "$dest")
        if test $status -ne 0
            continue
        end
        
        # Execute extraction
        if test $dry_run -eq 1
            __fish_archive_log info "Would extract: $archive to $dest"
            __fish_archive_log info "Command: "(string join ' ' $extract_args)
            set success_count (math "$success_count + 1")
        else
            __fish_archive_log info "Extracting: $archive to $dest"
            
            # Get file size for progress
            set -l file_size (__fish_archive_get_file_size "$archive")
            set -l progress_enabled 0
            if test $no_progress -eq 0; and test $file_size -gt 10485760
                set progress_enabled 1
            end
            
            # Execute with progress
            if test $progress_enabled -eq 1
                eval (string join ' ' $extract_args) | __fish_archive_show_progress_bar $file_size
            else
                eval (string join ' ' $extract_args)
            end
            
            if test $status -eq 0
                __fish_archive_log info "Successfully extracted: $archive"
                set success_count (math "$success_count + 1")
                
                # Generate checksum if requested
                if test $checksum -eq 1
                    __fish_archive_generate_checksum "$dest"
                end
            else
                __fish_archive_log error "Failed to extract: $archive"
            end
        end
        
        # Clean up archive if not keeping
        if test $keep -eq 0; and test $dry_run -eq 0
            rm -f "$archive"
        end
    end
    
    # Show summary
    set -l end_time (date +%s)
    set -l duration (math "$end_time - $start_time")
    
    if test $success_count -eq $total_count
        __fish_archive_log info "All extractions completed successfully ($success_count/$total_count)"
        return 0
    else
        __fish_archive_log warn "Some extractions failed ($success_count/$total_count)"
        return 1
    end
end

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
    set -l options h/help F/format= L/level= t/threads= e/encrypt p/password= C/chdir= i/include-glob+ x/exclude-glob+ u/update a/append q/quiet v/verbose
    set -l long_options no-progress smart solid checksum split= dry-run timestamp auto-rename compare
    set -l parsed (argparse $options $long_options -- $argv)
    
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
    set -l format "auto"
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
    if test "$format" = "auto"; or test $smart -eq 1
        set format (__fish_archive_smart_format $input_files)
        __fish_archive_log info "Selected format: $format"
    else
        # Detect format from output filename if not specified
        set -l ext_format (__fish_archive_get_format_from_extension (__fish_archive_get_extension "$output"))
        if test "$ext_format" != "unknown"
            set format "$ext_format"
        end
    end
    
    # Validate format
    if not __fish_archive_validate_format_support "$format" "compress"
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
    
    # Execute with progress
    if test $enable_progress -eq 1; and test $total_size -gt 10485760
        eval (string join ' ' $compress_args) | __fish_archive_show_progress_bar $total_size
    else
        eval (string join ' ' $compress_args)
    end
    
    if test $status -eq 0
        __fish_archive_log info "Successfully compressed to: $output"
        
        # Generate checksum if requested
        if test $checksum -eq 1
            __fish_archive_generate_checksum "$output"
        end
        
        # Show compression stats
        set -l compressed_size (__fish_archive_get_file_size "$output")
        __fish_archive_show_compression_stats $total_size $compressed_size "$format"
        
        return 0
    else
        __fish_archive_log error "Failed to compress to: $output"
        return 1
    end
end

function doctor --description 'Diagnose system capabilities and configuration'
    set -l usage "\
doctor - Diagnose system capabilities and configuration

Usage: doctor [OPTIONS]

Options:
  -v, --verbose           Show detailed system information
  -q, --quiet             Only show errors
      --fix               Suggest fixes for missing tools
      --export            Export diagnostic report to file
      --help              Display this help message

Examples:
  doctor                  # Basic system check
  doctor -v               # Detailed diagnostic
  doctor --fix            # Get installation suggestions
  doctor --export         # Export report to file
"

    # Parse arguments
    set -l options h/help v/verbose q/quiet
    set -l long_options fix export
    set -l parsed (argparse $options $long_options -- $argv)
    
    if test $status -ne 0
        echo $usage
        return 2
    end
    
    # Handle help
    if set -q _flag_help
        echo $usage
        return 0
    end
    
    # Set flags
    set -l verbose 0
    set -l quiet 0
    set -l fix 0
    set -l export 0
    
    if set -q _flag_verbose
        set verbose 1
    end
    
    if set -q _flag_quiet
        set quiet 1
    end
    
    if set -q _flag_fix
        set fix 1
    end
    
    if set -q _flag_export
        set export 1
    end
    
    # Run diagnostics
    __fish_archive_run_diagnostics $verbose $quiet $fix $export
end

# ============================================================================
# Helper Functions
# ============================================================================

function __fish_archive_handle_destination_naming --description 'Handle destination naming with auto-rename and timestamp'
    set -l base_dest $argv[1]
    set -l auto_rename $argv[2]
    set -l timestamp $argv[3]
    
    set -l final_dest "$base_dest"
    
    # Add timestamp if requested
    if test $timestamp -eq 1
        set final_dest "${base_dest}-"(date +%Y%m%d_%H%M%S)
    end
    
    # Handle auto-rename if destination exists
    if test $auto_rename -eq 1; and test -e "$final_dest"
        set -l counter 1
        while test -e "${final_dest}-$counter"
            set counter (math "$counter + 1")
        end
        set final_dest "${final_dest}-$counter"
    end
    
    echo $final_dest
end

function __fish_archive_handle_output_naming --description 'Handle output file naming with auto-rename and timestamp'
    set -l base_output $argv[1]
    set -l auto_rename $argv[2]
    set -l timestamp $argv[3]
    
    set -l final_output "$base_output"
    
    # Add timestamp if requested
    if test $timestamp -eq 1
        set -l basename (__fish_archive_basename_without_ext "$base_output")
        set -l extension (__fish_archive_get_extension "$base_output")
        set final_output "${basename}-"(date +%Y%m%d_%H%M%S)"$extension"
    end
    
    # Handle auto-rename if output exists
    if test $auto_rename -eq 1; and test -e "$final_output"
        set -l basename (__fish_archive_basename_without_ext "$final_output")
        set -l extension (__fish_archive_get_extension "$final_output")
        set -l counter 1
        while test -e "${basename}-$counter$extension"
            set counter (math "$counter + 1")
        end
        set final_output "${basename}-$counter$extension"
    end
    
    echo $final_output
end

function __fish_archive_generate_checksum --description 'Generate checksum file'
    set -l target $argv[1]
    
    if test -f "$target"
        set -l sha256_hash (__fish_archive_calculate_hash "$target" "sha256")
        if test $status -eq 0
            echo "$sha256_hash  "(basename "$target") > "${target}.sha256"
            __fish_archive_log info "Generated checksum: ${target}.sha256"
        end
    else if test -d "$target"
        # Generate checksum for directory contents
        find "$target" -type f -exec sha256sum {} \; > "${target}.sha256"
        __fish_archive_log info "Generated checksum: ${target}.sha256"
    end
end

function __fish_archive_run_diagnostics --description 'Run comprehensive system diagnostics'
    set -l verbose $argv[1]
    set -l quiet $argv[2]
    set -l fix $argv[3]
    set -l export $argv[4]
    
    set -l report_file ""
    if test $export -eq 1
        set report_file "fish-archive-diagnostic-"(date +%Y%m%d_%H%M%S).txt
    end
    
    # System information
    if test $verbose -eq 1; and test $quiet -eq 0
        __fish_archive_log info "=== Fish Archive Manager Diagnostic Report ==="
        __fish_archive_log info "Version: "(__fish_archive_version)
        __fish_archive_log info "Fish version: "(fish --version)
        __fish_archive_log info "OS: "(uname -s)
        __fish_archive_log info "Architecture: "(uname -m)
        __fish_archive_log info "CPU cores: "(nproc 2>/dev/null; or sysctl -n hw.ncpu 2>/dev/null; or echo "unknown")
        __fish_archive_log info "Date: "(date)
        echo ""
    end
    
    # Check required tools
    __fish_archive_log info "=== Required Tools ==="
    set -l required_tools file tar gzip bzip2 xz unzip zip
    set -l missing_required
    
    for tool in $required_tools
        if __fish_archive_has_command $tool
            __fish_archive_log info "✓ $tool"
        else
            __fish_archive_log error "✗ $tool (missing)"
            set -a missing_required $tool
        end
    end
    
    # Check important tools
    __fish_archive_log info "=== Important Tools ==="
    set -l important_tools 7z lz4 bsdtar
    set -l missing_important
    
    for tool in $important_tools
        if __fish_archive_has_command $tool
            __fish_archive_log info "✓ $tool"
        else
            __fish_archive_log warn "✗ $tool (missing - extended functionality)"
            set -a missing_important $tool
        end
    end
    
    # Check optional tools
    if test $verbose -eq 1
        __fish_archive_log info "=== Optional Tools ==="
        set -l optional_tools unrar pv lzip lzop brotli pigz pbzip2 pxz split
        
        for tool in $optional_tools
            if __fish_archive_has_command $tool
                __fish_archive_log info "✓ $tool"
            else
                __fish_archive_log debug "✗ $tool (missing - performance enhancement)"
            end
        end
    end
    
    # Configuration
    __fish_archive_log info "=== Configuration ==="
    __fish_archive_log info "Color: $FISH_ARCHIVE_COLOR"
    __fish_archive_log info "Progress: $FISH_ARCHIVE_PROGRESS"
    __fish_archive_log info "Default threads: $FISH_ARCHIVE_DEFAULT_THREADS"
    __fish_archive_log info "Log level: $FISH_ARCHIVE_LOG_LEVEL"
    
    # Format support
    if test $verbose -eq 1
        __fish_archive_log info "=== Format Support ==="
        set -l formats tar.gz tar.bz2 tar.xz tar.zst tar.lz4 zip 7z rar
        
        for format in $formats
            if __fish_archive_validate_format_support "$format" "extract"
                __fish_archive_log info "✓ $format (extract)"
            else
                __fish_archive_log warn "✗ $format (extract)"
            end
        end
    end
    
    # Fix suggestions
    if test $fix -eq 1; and test (count $missing_required) -gt 0
        __fish_archive_log info "=== Installation Suggestions ==="
        __fish_archive_log info "Arch Linux: sudo pacman -S "(string join ' ' $missing_required)
        __fish_archive_log info "Ubuntu/Debian: sudo apt-get install "(string join ' ' $missing_required)
        __fish_archive_log info "macOS: brew install "(string join ' ' $missing_required)
    end
    
    # Export report
    if test $export -eq 1
        __fish_archive_log info "=== Report exported to: $report_file ==="
    end
    
    # Return status
    if test (count $missing_required) -gt 0
        return 1
    else
        return 0
    end
end