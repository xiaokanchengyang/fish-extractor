# Validation and helper functions for Fish Archive Manager (fish 4.12+)
# Provides common validation, option checking, and utility functions

# Load error handling
source (dirname (status --current-filename))/error_handling.fish

# ============================================================================
# Option Validation Helpers
# ============================================================================

function is_flag_set --description 'Check if a flag variable is set to 1'
    test $argv[1] -eq 1
end

function is_verbose --description 'Check if verbose mode is enabled'
    is_flag_set $argv[1]
end

function is_quiet --description 'Check if quiet mode is enabled'
    is_flag_set $argv[1]
end

function is_dry_run --description 'Check if dry run mode is enabled'
    is_flag_set $argv[1]
end

function is_force --description 'Check if force mode is enabled'
    is_flag_set $argv[1]
end

function is_backup --description 'Check if backup mode is enabled'
    is_flag_set $argv[1]
end

function is_encrypt --description 'Check if encryption is enabled'
    is_flag_set $argv[1]
end

function is_smart --description 'Check if smart mode is enabled'
    is_flag_set $argv[1]
end

function is_solid --description 'Check if solid archive mode is enabled'
    is_flag_set $argv[1]
end

function is_checksum --description 'Check if checksum generation is enabled'
    is_flag_set $argv[1]
end

function is_auto_rename --description 'Check if auto-rename is enabled'
    is_flag_set $argv[1]
end

function is_timestamp --description 'Check if timestamp is enabled'
    is_flag_set $argv[1]
end

function is_progress_enabled --description 'Check if progress display is enabled'
    is_flag_set $argv[1]
end

# ============================================================================
# Path and File Validation
# ============================================================================

function validate_output_path --description 'Validate and prepare output path'
    set -l path $argv[1]
    set -l auto_rename $argv[2]
    set -l timestamp $argv[3]
    
    # Add timestamp if requested
    if is_timestamp $timestamp
        set -l base_name (string replace -r '\.[^.]+$' '' -- (basename $path))
        set -l extension (string match -r '\.[^.]+$' -- (basename $path))
        set -l dir_name (dirname $path)
        set path "$dir_name/$base_name-"(date +%Y%m%d_%H%M%S)"$extension"
    end
    
    # Auto-rename if output exists
    if is_auto_rename $auto_rename; and test -e "$path"
        set -l counter 1
        set -l base_path $path
        set -l base_name (string replace -r '\.[^.]+$' '' -- $path)
        set -l extension (string match -r '\.[^.]+$' -- $path)
        while test -e "$path"
            set path "$base_name-$counter$extension"
            set counter (math $counter + 1)
        end
    end
    
    echo $path
end

function validate_extract_dir --description 'Validate and prepare extraction directory'
    set -l archive_path $argv[1]
    set -l dest $argv[2]
    set -l auto_rename $argv[3]
    set -l timestamp $argv[4]
    set -l force $argv[5]
    set -l backup $argv[6]
    
    # Determine extraction directory
    set -l extract_dir $dest
    if test -z "$extract_dir"
        set extract_dir (default_extract_dir "$archive_path")
    end
    
    # Add timestamp if requested
    if is_timestamp $timestamp
        set extract_dir "$extract_dir-"(date +%Y%m%d_%H%M%S)
    end
    
    # Auto-rename if destination exists
    if is_auto_rename $auto_rename; and test -e "$extract_dir"
        set -l counter 1
        set -l base_dir $extract_dir
        while test -e "$extract_dir"
            set extract_dir "$base_dir-$counter"
            set counter (math $counter + 1)
        end
    end
    
    set extract_dir (sanitize_path $extract_dir)
    
    # Create extraction directory
    if not test -d "$extract_dir"
        mkdir -p "$extract_dir"
        or begin
            log error "Failed to create directory: $extract_dir"
            return 1
        end
    else if not is_force $force
        # Directory exists and no force flag
        if test (count (ls -A "$extract_dir" 2>/dev/null)) -gt 0
            if is_backup $backup
                # Create backup
                set -l backup_dir "$extract_dir.backup."(date +%Y%m%d_%H%M%S)
                log info "Creating backup: $backup_dir"
                mv "$extract_dir" "$backup_dir"
                or begin
                    log error "Failed to create backup"
                    return 1
                end
                mkdir -p "$extract_dir"
            else
                log warn "Directory not empty: $extract_dir (use --force or --backup)"
                return 1
            end
        end
    end
    
    echo $extract_dir
end

# ============================================================================
# Archive Operation Validation
# ============================================================================

function validate_archive_operation --description 'Validate archive operation parameters'
    set -l archive $argv[1]
    set -l format $argv[2]
    set -l password $argv[3]
    set -l encrypt $argv[4]
    
    # Validate archive file
    if not validate_archive "$archive"
        return 1
    end
    
    # Check encryption requirements
    if is_encrypt $encrypt; and test -z "$password"
        log error "Password required for encrypted archives"
        return 1
    end
    
    # Check format-specific requirements
    switch $format
        case zip 7z
            # These formats support encryption
            return 0
        case '*'
            if is_encrypt $encrypt
                log error "Encryption not supported for format: $format"
                return 1
            end
    end
    
    return 0
end

# ============================================================================
# Progress and Output Helpers
# ============================================================================

function should_show_progress --description 'Determine if progress should be shown'
    set -l progress_flag $argv[1]
    set -l quiet $argv[2]
    set -l file_size $argv[3]
    
    is_progress_enabled $progress_flag; and not is_quiet $quiet; and test $file_size -gt 10485760
end

function should_show_verbose --description 'Determine if verbose output should be shown'
    set -l verbose $argv[1]
    set -l quiet $argv[2]
    
    is_verbose $verbose; and not is_quiet $quiet
end

function should_show_info --description 'Determine if info output should be shown'
    not is_quiet $argv[1]
end

# ============================================================================
# Format and Compression Helpers
# ============================================================================

function get_compression_command --description 'Get the best available compression command'
    set -l format $argv[1]
    set -l parallel $argv[2]
    
    switch $format
        case gzip tar.gz
            if test $parallel -eq 1; and has_command pigz
                echo "pigz"
            else
                echo "gzip"
            end
        case bzip2 tar.bz2
            if test $parallel -eq 1; and has_command pbzip2
                echo "pbzip2"
            else
                echo "bzip2"
            end
        case xz tar.xz
            echo "xz"
        case zstd tar.zst
            echo "zstd"
        case lz4 tar.lz4
            echo "lz4"
        case lzip tar.lz
            echo "lzip"
        case lzop tar.lzo
            echo "lzop"
        case brotli tar.br
            echo "brotli"
        case '*'
            echo "unknown"
    end
end

function get_decompression_command --description 'Get the best available decompression command'
    set -l format $argv[1]
    
    switch $format
        case gzip tar.gz
            echo "gunzip"
        case bzip2 tar.bz2
            echo "bunzip2"
        case xz tar.xz
            echo "unxz"
        case zstd tar.zst
            echo "unzstd"
        case lz4 tar.lz4
            echo "unlz4"
        case lzip tar.lz
            echo "lunzip"
        case lzop tar.lzo
            echo "lzop"
        case brotli tar.br
            echo "brotli"
        case '*'
            echo "unknown"
    end
end

# ============================================================================
# Error Handling Helpers
# ============================================================================

function handle_operation_error --description 'Handle operation errors with appropriate logging'
    set -l operation $argv[1]
    set -l target $argv[2]
    set -l error_code $argv[3]
    
    switch $error_code
        case 1
            log error "$operation failed: $target"
        case 2
            log error "Invalid arguments for $operation: $target"
        case 127
            log error "Required command not found for $operation: $target"
        case '*'
            log error "Unknown error ($error_code) during $operation: $target"
    end
end

function check_required_commands --description 'Check if required commands are available for operation'
    set -l format $argv[1]
    set -l operation $argv[2]  # extract or compress
    
    switch $format
        case tar tar.gz tar.bz2 tar.xz tar.zst tar.lz4 tar.lz tar.lzo tar.br
            require_commands tar
        case zip
            if test "$operation" = "extract"
                require_commands unzip
            else
                require_commands zip
            end
        case 7z
            require_commands 7z
        case rar
            if has_command unrar
                return 0
            else if has_command bsdtar
                return 0
            else
                log error "Neither unrar nor bsdtar available for RAR $operation"
                return 127
            end
        case iso deb rpm
            if has_command bsdtar
                return 0
            else if has_command 7z
                return 0
            else
                log error "bsdtar or 7z required for $format $operation"
                return 127
            end
        case gzip gz bzip2 bz2 xz zstd zst lz4 lz lzip lzo brotli br
            set -l cmd (get_decompression_command $format)
            if test "$cmd" != "unknown"
                require_commands $cmd
            end
    end
end

# ============================================================================
# Summary and Statistics Helpers
# ============================================================================

function show_operation_summary --description 'Show operation summary'
    set -l operation $argv[1]  # extract or compress
    set -l success_count $argv[2]
    set -l fail_count $argv[3]
    set -l total $argv[4]
    set -l quiet $argv[5]
    
    if not is_quiet $quiet; and test $total -gt 1
        echo ""
        if test $fail_count -eq 0
            colorize green "✓ All $operation operations completed successfully ($success_count/$total)\n"
        else
            colorize yellow "⚠ $operation summary: $success_count succeeded, $fail_count failed\n"
        end
    end
end

function show_file_info --description 'Show file information'
    set -l file $argv[1]
    set -l format $argv[2]
    set -l size $argv[3]
    set -l verbose $argv[4]
    set -l quiet $argv[5]
    set -l operation $argv[6]
    set -l current $argv[7]
    set -l total $argv[8]
    
    if not is_quiet $quiet
        if test $total -gt 1
            log info "[$current/$total] $operation: $file"
        else
            log info "$operation: $file"
        end
        
        if should_show_verbose $verbose $quiet
            log debug "  Format: $format"
            log debug "  Size: "(human_size $size)
        end
    end
end