# Error handling functions for Fish Archive Manager (fish 4.12+)
# Provides unified error handling, logging, and exit code management

# ============================================================================
# Error Types and Codes
# ============================================================================

# Standard exit codes
set -g FISH_ARCHIVE_SUCCESS 0
set -g FISH_ARCHIVE_ERROR 1
set -g FISH_ARCHIVE_INVALID_ARGS 2
set -g FISH_ARCHIVE_MISSING_COMMAND 127

# Error categories
set -g FISH_ARCHIVE_ERROR_FILE_NOT_FOUND "FILE_NOT_FOUND"
set -g FISH_ARCHIVE_ERROR_PERMISSION_DENIED "PERMISSION_DENIED"
set -g FISH_ARCHIVE_ERROR_INVALID_FORMAT "INVALID_FORMAT"
set -g FISH_ARCHIVE_ERROR_MISSING_DEPENDENCY "MISSING_DEPENDENCY"
set -g FISH_ARCHIVE_ERROR_OPERATION_FAILED "OPERATION_FAILED"
set -g FISH_ARCHIVE_ERROR_INVALID_ARGUMENTS "INVALID_ARGUMENTS"

# ============================================================================
# Error Reporting Functions
# ============================================================================

function report_error --description 'Report error with appropriate logging and exit code'
    set -l error_type $argv[1]
    set -l message $argv[2]
    set -l exit_code $argv[3]
    set -l context $argv[4..-1]
    
    # Log error message
    log error "$message"
    
    # Add context if provided
    if test (count $context) -gt 0
        log debug "Context: "(string join ' ' $context)
    end
    
    # Return appropriate exit code
    return $exit_code
end

function handle_file_error --description 'Handle file-related errors'
    set -l file $argv[1]
    set -l operation $argv[2]
    
    if not test -e "$file"
        report_error $FISH_ARCHIVE_ERROR_FILE_NOT_FOUND "File not found: $file" $FISH_ARCHIVE_ERROR "operation:$operation"
    else if not test -r "$file"
        report_error $FISH_ARCHIVE_ERROR_PERMISSION_DENIED "Permission denied: $file" $FISH_ARCHIVE_ERROR "operation:$operation"
    else if not test -f "$file"
        report_error $FISH_ARCHIVE_ERROR_INVALID_FORMAT "Not a regular file: $file" $FISH_ARCHIVE_ERROR "operation:$operation"
    else
        return 0
    end
end

function handle_command_error --description 'Handle missing command errors'
    set -l command $argv[1]
    set -l operation $argv[2]
    
    report_error $FISH_ARCHIVE_ERROR_MISSING_DEPENDENCY "Required command not found: $command" $FISH_ARCHIVE_MISSING_COMMAND "operation:$operation"
end

function handle_operation_error --description 'Handle operation failure errors'
    set -l operation $argv[1]
    set -l target $argv[2]
    set -l exit_code $argv[3]
    
    switch $exit_code
        case 1
            report_error $FISH_ARCHIVE_ERROR_OPERATION_FAILED "$operation failed: $target" $FISH_ARCHIVE_ERROR "exit_code:$exit_code"
        case 2
            report_error $FISH_ARCHIVE_ERROR_INVALID_ARGUMENTS "Invalid arguments for $operation: $target" $FISH_ARCHIVE_INVALID_ARGS "exit_code:$exit_code"
        case 127
            report_error $FISH_ARCHIVE_ERROR_MISSING_DEPENDENCY "Required command not found for $operation: $target" $FISH_ARCHIVE_MISSING_COMMAND "exit_code:$exit_code"
        case '*'
            report_error $FISH_ARCHIVE_ERROR_OPERATION_FAILED "Unknown error ($exit_code) during $operation: $target" $FISH_ARCHIVE_ERROR "exit_code:$exit_code"
    end
end

# ============================================================================
# Validation Error Handling
# ============================================================================

function validate_required_args --description 'Validate required arguments'
    set -l args $argv[1..-2]
    set -l operation $argv[-1]
    
    if test (count $args) -eq 0
        report_error $FISH_ARCHIVE_ERROR_INVALID_ARGUMENTS "No arguments provided for $operation" $FISH_ARCHIVE_INVALID_ARGS "operation:$operation"
    end
end

function validate_file_exists --description 'Validate file exists and is accessible'
    set -l file $argv[1]
    set -l operation $argv[2]
    
    handle_file_error "$file" $operation
end

function validate_directory_exists --description 'Validate directory exists and is accessible'
    set -l dir $argv[1]
    set -l operation $argv[2]
    
    if not test -d "$dir"
        report_error $FISH_ARCHIVE_ERROR_FILE_NOT_FOUND "Directory not found: $dir" $FISH_ARCHIVE_ERROR "operation:$operation"
    else if not test -r "$dir"
        report_error $FISH_ARCHIVE_ERROR_PERMISSION_DENIED "Permission denied: $dir" $FISH_ARCHIVE_ERROR "operation:$operation"
    else
        return 0
    end
end

function validate_format_support --description 'Validate format is supported for operation'
    set -l format $argv[1]
    set -l operation $argv[2]
    
    if not validate_format_for_operation $format $operation
        report_error $FISH_ARCHIVE_ERROR_INVALID_FORMAT "Format $format not supported for $operation" $FISH_ARCHIVE_ERROR "format:$format" "operation:$operation"
    end
end

# ============================================================================
# Command Execution Error Handling
# ============================================================================

function safe_execute --description 'Execute command with error handling'
    set -l command $argv[1]
    set -l operation $argv[2]
    set -l args $argv[3..-1]
    
    # Check if command exists
    if not has_command $command
        handle_command_error $command $operation
    end
    
    # Execute command safely
    $command $args
    set -l exit_code $status
    
    # Handle command failure
    if test $exit_code -ne 0
        handle_operation_error $operation "$command $args" $exit_code
    end
    
    return $exit_code
end

function safe_execute_with_output --description 'Execute command and capture output with error handling'
    set -l command $argv[1]
    set -l operation $argv[2]
    set -l args $argv[3..-1]
    
    # Check if command exists
    if not has_command $command
        handle_command_error $command $operation
    end
    
    # Execute command and capture output safely
    set -l output ($command $args 2>&1)
    set -l exit_code $status
    
    # Handle command failure
    if test $exit_code -ne 0
        log error "Command failed: $command $args"
        log error "Output: $output"
        handle_operation_error $operation "$command $args" $exit_code
    end
    
    echo $output
    return $exit_code
end

# ============================================================================
# Archive-Specific Error Handling
# ============================================================================

function handle_archive_error --description 'Handle archive-specific errors'
    set -l archive $argv[1]
    set -l operation $argv[2]
    set -l exit_code $argv[3]
    
    switch $exit_code
        case 1
            log error "Archive $operation failed: $archive"
            log error "The archive may be corrupted or in an unsupported format"
        case 2
            log error "Invalid arguments for archive $operation: $archive"
        case 127
            log error "Required tool not found for archive $operation: $archive"
            log error "Run 'doctor --fix' to install missing dependencies"
        case '*'
            log error "Unknown error ($exit_code) during archive $operation: $archive"
    end
end

function handle_compression_error --description 'Handle compression-specific errors'
    set -l output $argv[1]
    set -l format $argv[2]
    set -l exit_code $argv[3]
    
    switch $exit_code
        case 1
            log error "Compression failed: $output"
            log error "Check if output directory is writable and has enough space"
        case 2
            log error "Invalid compression arguments for $format: $output"
        case 127
            log error "Required compression tool not found for $format: $output"
            log error "Run 'doctor --fix' to install missing dependencies"
        case '*'
            log error "Unknown error ($exit_code) during compression: $output"
    end
end

function handle_extraction_error --description 'Handle extraction-specific errors'
    set -l archive $argv[1]
    set -l destination $argv[2]
    set -l exit_code $argv[3]
    
    switch $exit_code
        case 1
            log error "Extraction failed: $archive"
            log error "Check if destination directory is writable and has enough space"
        case 2
            log error "Invalid extraction arguments: $archive"
        case 127
            log error "Required extraction tool not found: $archive"
            log error "Run 'doctor --fix' to install missing dependencies"
        case '*'
            log error "Unknown error ($exit_code) during extraction: $archive"
    end
end

# ============================================================================
# Error Recovery Functions
# ============================================================================

function suggest_fixes --description 'Suggest fixes for common errors'
    set -l error_type $argv[1]
    set -l context $argv[2..-1]
    
    switch $error_type
        case $FISH_ARCHIVE_ERROR_MISSING_DEPENDENCY
            log info "To fix missing dependencies:"
            log info "  Run 'doctor --fix' to see installation commands"
            log info "  Or install manually using your package manager"
        case $FISH_ARCHIVE_ERROR_PERMISSION_DENIED
            log info "To fix permission issues:"
            log info "  Check file/directory permissions"
            log info "  Ensure you have write access to the destination"
        case $FISH_ARCHIVE_ERROR_INVALID_FORMAT
            log info "To fix format issues:"
            log info "  Check if the file is a valid archive"
            log info "  Try using a different extraction method"
            log info "  Run 'doctor -v' to see supported formats"
        case $FISH_ARCHIVE_ERROR_OPERATION_FAILED
            log info "To fix operation failures:"
            log info "  Check available disk space"
            log info "  Verify file integrity"
            log info "  Try with verbose mode: -v"
    end
end

function cleanup_on_error --description 'Clean up temporary files on error'
    set -l temp_files $argv
    
    for file in $temp_files
        if test -e "$file"
            rm -rf "$file"
            log debug "Cleaned up temporary file: $file"
        end
    end
end

# ============================================================================
# Error Summary and Reporting
# ============================================================================

function show_error_summary --description 'Show error summary for batch operations'
    set -l success_count $argv[1]
    set -l fail_count $argv[2]
    set -l total $argv[3]
    set -l operation $argv[4]
    
    if test $fail_count -eq 0
        colorize green "✓ All $operation operations completed successfully ($success_count/$total)\n"
    else
        colorize yellow "⚠ $operation summary: $success_count succeeded, $fail_count failed\n"
        if test $fail_count -gt 0
            log info "Run with -v for detailed error information"
        end
    end
end

function export_error_report --description 'Export error report to file'
    set -l errors $argv[1..-2]
    set -l filename $argv[-1]
    
    if test (count $errors) -gt 0
        printf "Fish Archive Manager Error Report\n" > $filename
        printf "Generated: %s\n\n" (date) >> $filename
        printf "Errors:\n" >> $filename
        for error in $errors
            printf "  - %s\n" $error >> $filename
        end
        log info "Error report exported to: $filename"
    end
end