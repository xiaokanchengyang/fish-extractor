# Archive extraction command for Fish Archive Manager (fish 4.12+)
# Supports intelligent format detection, multiple archives, progress indication, and comprehensive options

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

function extract --description 'Extract archives with smart detection and extensive format support'
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
  - Compressed tar: .tar.gz, .tar.bz2, .tar.xz, .tar.zst, .tar.lz4, .tar.lz, .tar.lzo, .tar.br
  - Archives: .zip, .7z, .rar
  - Compressed files: .gz, .bz2, .xz, .zst, .lz4, .lz, .lzo, .br
  - Disk images: .iso
  - Package formats: .deb, .rpm (with bsdtar)
  - And more via automatic fallback to bsdtar/7z

Examples:
  extract file.tar.gz                      # Extract to ./file/
  extract -d output/ archive.zip           # Extract to ./output/
  extract --strip 1 dist.tar.xz            # Strip top-level directory
  extract -p secret encrypted.7z           # Extract encrypted archive
  extract --list archive.zip               # List contents only
  extract --test backup.tar.gz             # Test integrity
  extract *.tar.gz                         # Extract multiple archives
  extract --verify --checksum data.txz     # Verify and generate checksum
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
    set -l verify 0
    set -l flat 0
    set -l dry_run 0
    set -l backup 0
    set -l gen_checksum 0
    set -l auto_rename 0
    set -l add_timestamp 0
    set -l preserve_perms 1

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
        'verify' \
        'overwrite' \
        'flat' \
        'dry-run' \
        'backup' \
        'checksum' \
        'auto-rename' \
        'timestamp' \
        'preserve-perms' \
        'no-preserve-perms' \
        'h/help' \
        -- $argv
    or begin
        echo $usage >&2
        return 2
    end

    # Handle flags
    set -q _flag_help; and echo $usage; and return 0
    set -q _flag_dest; and set dest (sanitize_path $_flag_dest)
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
    set -q _flag_verify; and set verify 1
    set -q _flag_flat; and set flat 1
    set -q _flag_dry_run; and set dry_run 1
    set -q _flag_backup; and set backup 1
    set -q _flag_checksum; and set gen_checksum 1
    set -q _flag_auto_rename; and set auto_rename 1
    set -q _flag_timestamp; and set add_timestamp 1
    set -q _flag_no_preserve_perms; and set preserve_perms 0

    # Validate arguments
    set -l files $argv
    if test (count $files) -eq 0
        log error "No archive files specified"
        echo $usage >&2
        return 2
    end

    # Verify basic tools
    require_commands file tar
    or return 127

    # Resolve thread count
    set -l thread_count (resolve_threads $threads)

    # Process each archive
    set -l success_count 0
    set -l fail_count 0
    set -l total_archives (count $files)

    # Show summary header for multiple files
    if test $quiet -eq 0; and test $total_archives -gt 1
        log info "Processing $total_archives archive(s)..."
        echo ""
    end

    for archive in $files
        # Validate and normalize path
        set -l archive_path (sanitize_path $archive)
        
        if not validate_archive "$archive_path"
            set fail_count (math $fail_count + 1)
            continue
        end

        # Detect format
        set -l format (detect_archive_format "$archive_path")
        if test "$format" = "unknown"
            log warn "Unknown format for $archive, attempting automatic detection"
        end

        # Get file size for optimization
        set -l file_size (get_file_size "$archive_path")

        # Determine extraction directory
        set -l extract_dir (generate_extract_directory "$archive_path" $dest $auto_rename $add_timestamp)

    # Handle different operation modes
    if test $list_only -eq 1
        list_format_contents "$archive_path" $format
        set -l status_code $status
        if test $status_code -eq 0
            set success_count (math $success_count + 1)
        else
            set fail_count (math $fail_count + 1)
        end
        continue
    end
    
    if test $test_only -eq 1
        test_format_integrity "$archive_path" $format
        set -l status_code $status
        if test $status_code -eq 0
            set success_count (math $success_count + 1)
            test $quiet -eq 0; and colorize green "✓ $archive: OK\n"
        else
            set fail_count (math $fail_count + 1)
            colorize red "✗ $archive: FAILED\n"
        end
        continue
    end
    
    if test $verify -eq 1
        if not verify_checksum_file "$archive_path" "sha256"
            log warn "Verification failed for $archive"
            set fail_count (math $fail_count + 1)
            continue
        end
    end

        # Dry run mode
        if test $dry_run -eq 1
            log info "[DRY-RUN] Would extract: $archive_path → $extract_dir"
            log info "[DRY-RUN] Format: $format, Size: "(human_size $file_size)
            continue
        end

        # Prepare extraction directory
        if not prepare_extraction_directory "$extract_dir" $force $backup $quiet
            set fail_count (math $fail_count + 1)
            continue
        end

        # Show file info
        show_operation_progress "Extracting" $archive $format $file_size $verbose $quiet $success_count $total_archives
        if should_show_verbose $verbose $quiet
            log debug "  Destination: $extract_dir"
            log debug "  Threads: $thread_count"
        end

        # Perform extraction
        if execute_format_command $format "extract" "$archive_path" "$extract_dir" $strip "$password" $thread_count $show_progress $verbose $flat
            set success_count (math $success_count + 1)
            test $quiet -eq 0; and colorize green "✓ Extracted: $archive\n"
            
            # Generate checksum if requested
            if test $gen_checksum -eq 1
                generate_checksum_file "$extract_dir" "sha256" $quiet
            end
        else
            set fail_count (math $fail_count + 1)
            log error "Extraction failed: $archive"
        end
    end

    # Summary
    show_operation_summary "extraction" $success_count $fail_count $total_archives $quiet

    # Return appropriate exit code
    test $fail_count -eq 0
end

# ============================================================================
# Internal: Archive Extraction Logic
# ============================================================================

# Note: Archive extraction logic is now handled by common functions
# in functions/common/format_operations.fish

# ============================================================================
# Format-Specific Extraction Functions
# ============================================================================

# Note: Format-specific extraction functions are now handled by common functions
# in functions/common/format_operations.fish

# ============================================================================
# Archive Listing and Testing
# ============================================================================

# Note: Archive listing and testing functions are now handled by common functions
# in functions/common/format_operations.fish