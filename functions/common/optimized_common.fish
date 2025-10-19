# Optimized common functions for Fish Archive Manager (fish 4.12+)
# Consolidates shared functionality with modern Fish features

# Load core utilities
source (dirname (status --current-filename))/../core_optimized.fish
# Load safe execution helpers
source (dirname (status --current-filename))/safe_exec.fish

# ============================================================================
# Enhanced Archive Operation Helpers
# ============================================================================

function __fish_archive_execute_with_progress --description 'Execute command with enhanced progress handling'
    set -l command $argv[1]
    set -l operation $argv[2]  # compress or extract
    set -l target $argv[3]
    set -l format $argv[4]
    set -l verbose $argv[5]
    set -l progress $argv[6]
    set -l threads $argv[7]
    set -l args $argv[8..-1]
    
    # Check command availability
    if not __fish_archive_has_command $command
        __fish_archive_log error "Command not found: $command"
        return 127
    end
    
    # Build command with modern Fish features
    set -l full_command $command
    for arg in $args
        set full_command $full_command $arg
    end
    
    # Execute with progress if enabled
    if test $progress -eq 1; and __fish_archive_can_show_progress
        set -l size (__fish_archive_get_file_size "$target")
        __fish_pack_exec_with_progress $full_command $size
    else
        __fish_pack_safe_exec $full_command
    end
    
    set -l exit_code $status
    
    # Enhanced error handling
    if test $exit_code -ne 0
        __fish_archive_log error "Command failed with exit code $exit_code: $command"
        return $exit_code
    end
    
    return 0
end

function __fish_archive_prepare_compression_args --description 'Prepare compression arguments with modern Fish features'
    set -l format $argv[1]
    set -l level $argv[2]
    set -l threads $argv[3]
    set -l solid $argv[4]
    set -l encrypt $argv[5]
    set -l password $argv[6]
    set -l output $argv[7]
    set -l inputs $argv[8..-1]
    
    set -l args
    
    # Format-specific argument preparation
    switch $format
        case 'tar.gz' 'tgz'
            if __fish_archive_has_command pigz; and test $threads -gt 1
                set -a args tar -I "pigz -p $threads"
            else
                set -a args tar -czf
            end
            if test $level -gt 0
                set -a args -$level
            end
            
        case 'tar.bz2' 'tbz2' 'tbz'
            if __fish_archive_has_command pbzip2; and test $threads -gt 1
                set -a args tar -I "pbzip2 -p$threads"
            else
                set -a args tar -cjf
            end
            if test $level -gt 0
                set -a args -$level
            end
            
        case 'tar.xz' 'txz'
            set -a args tar -cJf
            if test $level -gt 0
                set -a args -$level
            end
            
        case 'tar.zst' 'tzst'
            set -a args tar -I "zstd -T$threads"
            if test $level -gt 0
                set -a args -$level
            end
            
        case 'zip'
            set -a args zip
            if test $level -gt 0
                set -a args -$level
            end
            if test $encrypt -eq 1
                set -a args -e
                if test -n "$password"
                    set -a args -P "$password"
                end
            end
            
        case '7z'
            set -a args 7z a
            if test $level -gt 0
                set -a args -mx$level
            end
            if test $solid -eq 1
                set -a args -ms
            end
            if test $encrypt -eq 1
                set -a args -p"$password"
            end
            set -a args -t7z
            
        case '*'
            __fish_archive_log error "Unsupported format: $format"
            return 1
    end
    
    # Add output and inputs
    set -a args "$output" $inputs
    
    echo $args
end

function __fish_archive_prepare_extraction_args --description 'Prepare extraction arguments with modern Fish features'
    set -l format $argv[1]
    set -l threads $argv[2]
    set -l password $argv[3]
    set -l strip $argv[4]
    set -l flat $argv[5]
    set -l preserve_perms $argv[6]
    set -l archive $argv[7]
    set -l destination $argv[8]
    
    set -l args
    
    # Format-specific argument preparation
    switch $format
        case 'tar.gz' 'tgz'
            if __fish_archive_has_command pigz; and test $threads -gt 1
                set -a args tar -I "pigz -p $threads"
            else
                set -a args tar -xzf
            end
            
        case 'tar.bz2' 'tbz2' 'tbz'
            if __fish_archive_has_command pbzip2; and test $threads -gt 1
                set -a args tar -I "pbzip2 -p$threads"
            else
                set -a args tar -xjf
            end
            
        case 'tar.xz' 'txz'
            set -a args tar -xJf
            
        case 'tar.zst' 'tzst'
            set -a args tar -I "zstd -T$threads" -xf
            
        case 'zip'
            set -a args unzip
            if test -n "$password"
                set -a args -P "$password"
            end
            
        case '7z'
            set -a args 7z x
            if test -n "$password"
                set -a args -p"$password"
            end
            
        case 'rar'
            set -a args unrar x
            if test -n "$password"
                set -a args -p"$password"
            end
            
        case '*'
            # Try bsdtar as fallback
            set -a args bsdtar -xf
            
    end
    
    # Add common options
    if test $strip -gt 0
        set -a args --strip-components $strip
    end
    
    if test $flat -eq 1
        set -a args -j
    end
    
    if test $preserve_perms -eq 0
        set -a args --no-same-permissions
    end
    
    # Add archive and destination
    set -a args "$archive"
    if test -n "$destination"
        set -a args -C "$destination"
    end
    
    echo $args
end

# ============================================================================
# Enhanced File Processing Functions
# ============================================================================

function __fish_archive_collect_and_filter_files --description 'Collect and filter files with enhanced pattern matching'
    set -l inputs $argv[1..-3]
    set -l include_patterns $argv[-2]
    set -l exclude_patterns $argv[-1]
    
    set -l file_list
    
    # Collect files with modern Fish features
    for input in $inputs
        if test -f "$input"
            set -a file_list "$input"
        else if test -d "$input"
            # Use find with modern options
            for file in (find "$input" -type f 2>/dev/null)
                set -a file_list "$file"
            end
        else
            # Try glob expansion safely
            set -l expanded (string match -r '.*' -- $input)
            for file in $expanded
                test -f "$file"; and set -a file_list "$file"
            end
        end
    end
    
    # Apply include patterns
    if test -n "$include_patterns"
        set -l filtered
        for file in $file_list
            set -l include_match 0
            for pattern in $include_patterns
                if string match -q -- $pattern "$file"
                    set include_match 1
                    break
                end
            end
            if test $include_match -eq 1
                set -a filtered "$file"
            end
        end
        set file_list $filtered
    end
    
    # Apply exclude patterns
    if test -n "$exclude_patterns"
        set -l filtered
        for file in $file_list
            set -l exclude_match 0
            for pattern in $exclude_patterns
                if string match -q -- $pattern "$file"
                    set exclude_match 1
                    break
                end
            end
            if test $exclude_match -eq 0
                set -a filtered "$file"
            end
        end
        set file_list $filtered
    end
    
    echo $file_list
end

function __fish_archive_validate_inputs --description 'Validate input files with comprehensive checks'
    set -l inputs $argv
    
    set -l valid_inputs
    set -l errors
    
    for input in $inputs
        if test -f "$input"
            set -a valid_inputs "$input"
        else if test -d "$input"
            set -a valid_inputs "$input"
        else
            set -a errors "Input not found: $input"
        end
    end
    
    if test (count $errors) -gt 0
        for error in $errors
            __fish_archive_log error $error
        end
        return 1
    end
    
    if test (count $valid_inputs) -eq 0
        __fish_archive_log error "No valid input files found"
        return 1
    end
    
    echo $valid_inputs
end

# ============================================================================
# Enhanced Archive Validation Functions
# ============================================================================

function __fish_archive_test_archive_integrity --description 'Test archive integrity with format-specific methods'
    set -l archive $argv[1]
    set -l format $argv[2]
    
    switch $format
        case 'tar.gz' 'tgz' 'tar.bz2' 'tbz2' 'tbz' 'tar.xz' 'txz' 'tar.zst' 'tzst'
            tar -tf "$archive" >/dev/null 2>&1
            
        case 'zip'
            unzip -t "$archive" >/dev/null 2>&1
            
        case '7z'
            7z t "$archive" >/dev/null 2>&1
            
        case 'rar'
            unrar t "$archive" >/dev/null 2>&1
            
        case '*'
            # Try bsdtar as fallback
            bsdtar -tf "$archive" >/dev/null 2>&1
    end
end

function __fish_archive_list_archive_contents --description 'List archive contents with format-specific methods'
    set -l archive $argv[1]
    set -l format $argv[2]
    
    switch $format
        case 'tar.gz' 'tgz' 'tar.bz2' 'tbz2' 'tbz' 'tar.xz' 'txz' 'tar.zst' 'tzst'
            tar -tf "$archive"
            
        case 'zip'
            unzip -l "$archive"
            
        case '7z'
            7z l "$archive"
            
        case 'rar'
            unrar l "$archive"
            
        case '*'
            # Try bsdtar as fallback
            bsdtar -tf "$archive"
    end
end

# ============================================================================
# Enhanced Progress and Status Reporting
# ============================================================================

function __fish_archive_show_operation_summary --description 'Show operation summary with modern formatting'
    set -l operation $argv[1]  # compress or extract
    set -l format $argv[2]
    set -l input_count $argv[3]
    set -l output_size $argv[4]
    set -l duration $argv[5]
    set -l cpu_pct $argv[6]
    
    set -l operation_name (string capitalize $operation)
    set -l format_display (string upper $format)
    
    __fish_archive_log info "$operation_name completed successfully"
    __fish_archive_log info "Format: $format_display"
    __fish_archive_log info "Files processed: $input_count"
    
    if test $output_size -gt 0
        set -l size_human (__fish_archive_human_size $output_size)
        __fish_archive_log info "Output size: $size_human"
    end
    
    if test $duration -gt 0
        __fish_archive_log info "Duration: ${duration}s"
        if test $output_size -gt 0
            set -l throughput (math -s2 "$output_size / $duration / 1048576")
            __fish_archive_log info "Throughput: ${throughput}MB/s"
        end
    end

    if test -n "$cpu_pct"
        __fish_archive_log info "Estimated CPU utilization: ${cpu_pct}%"
    end
end

function __fish_archive_show_compression_stats --description 'Show compression statistics'
    set -l original_size $argv[1]
    set -l compressed_size $argv[2]
    set -l format $argv[3]
    
    if test $original_size -gt 0; and test $compressed_size -gt 0
        set -l ratio (math -s1 "100 - ($compressed_size * 100 / $original_size)")
        set -l original_human (__fish_archive_human_size $original_size)
        set -l compressed_human (__fish_archive_human_size $compressed_size)
        
        __fish_archive_log info "Compression ratio: $ratio%"
        __fish_archive_log info "Original size: $original_human"
        __fish_archive_log info "Compressed size: $compressed_human"
    end
end

# ============================================================================
# Enhanced Error Handling and Recovery
# ============================================================================

function __fish_archive_handle_operation_error --description 'Handle operation errors with recovery suggestions'
    set -l operation $argv[1]
    set -l format $argv[2]
    set -l error_code $argv[3]
    set -l details $argv[4..-1]
    
    set -l suggestions
    
    switch $error_code
        case 127
            set suggestions "Install required tools using your package manager"
        case 1
            switch $format
                case 'zip' '7z'
                    set suggestions "Check if archive is password-protected or corrupted"
                case '*'
                    set suggestions "Check if archive is corrupted or format is unsupported"
            end
        case 2
            set suggestions "Check file permissions and disk space"
        case '*'
            set suggestions "Check system resources and try again"
    end
    
    __fish_archive_log error "$operation failed with error code $error_code"
    for detail in $details
        __fish_archive_log error $detail
    end
    
    if test -n "$suggestions"
        __fish_archive_log info "Suggestions: $suggestions"
    end
end

# ============================================================================
# Modern Fish 4.12+ Integration Helpers
# ============================================================================

function __fish_archive_ensure_fish_compatibility --description 'Ensure Fish 4.12+ compatibility'
    if not __fish_archive_is_fish_4_12_plus
        __fish_archive_log warn "Fish version 4.12+ recommended for optimal performance"
        __fish_archive_log info "Current version: "(fish --version | string match -r '\d+\.\d+')
        return 1
    end
    return 0
end

function __fish_archive_optimize_performance --description 'Optimize performance based on system capabilities'
    set -l file_size $argv[1]
    set -l operation $argv[2]  # compress or extract
    
    # Check for parallel tools
    set -l has_pigz (__fish_archive_has_command pigz; and echo 1; or echo 0)
    set -l has_pbzip2 (__fish_archive_has_command pbzip2; and echo 1; or echo 0)
    set -l has_pv (__fish_archive_has_command pv; and echo 1; or echo 0)
    
    # Optimize thread count
    set -l optimal_threads (__fish_archive_optimal_threads $file_size)
    
    # Enable progress for large files
    set -l enable_progress 0
    if test $file_size -gt 10485760; and test $has_pv -eq 1
        set enable_progress 1
    end
    
    echo "$optimal_threads $enable_progress $has_pigz $has_pbzip2 $has_pv"
end