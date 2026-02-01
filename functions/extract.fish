# Archive extraction command for Fish Archive Manager (fish 4.12+)
# Supports intelligent format detection, multiple archives, progress indication, and comprehensive options

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

function extract --description 'Extract archives with intelligent format detection and modern Fish features'
    set -l usage "
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
            set -l backup_name "$dest.backup."(date +%Y%m%d_%H%M%S)
            mv "$dest" "$backup_name" 2>/dev/null; or begin
                __fish_archive_log warn "Failed to create backup: $backup_name"
            end
        end
        
        # Security Policy: Strict Path Traversal Protection
        # Verify archive members for unsafe paths before extraction
        if __fish_pack_verify_archive_members "$archive" "$format"
            # Safe to proceed
        else
            # Unsafe paths detected
            __fish_archive_log error "Archive contains unsafe paths (e.g. '../' or absolute paths). Skipping: $archive"
            continue
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
            
            # Execute with progress and measure
            set -l start_data (__fish_pack_start_measurement)

            if test $progress_enabled -eq 1
                __fish_pack_exec_with_progress $extract_args $file_size
            else
                __fish_pack_safe_exec $extract_args
            end

            set -l cmd_status $status
            set -l perf_data (__fish_pack_end_measurement "$start_data")
            set -l duration (echo $perf_data | cut -d' ' -f1)
            set -l cpu_pct (echo $perf_data | cut -d' ' -f2)

            if test $cmd_status -eq 0
                __fish_archive_log info "Successfully extracted: $archive"
                set success_count (math "$success_count + 1")
                
                # Generate checksum if requested
                if test $checksum -eq 1
                    __fish_archive_generate_checksum "$dest"
                end
                __fish_archive_show_operation_summary "extract" "$format" 1 $file_size $duration "$cpu_pct"
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