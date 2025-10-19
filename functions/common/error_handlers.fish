# Enhanced error handling for Fish Pack (fish 4.1.2+)
# Provides robust error handling with proper cleanup

function __fish_pack_set_error_trap --description 'Set up error handling for a function'
    set -l cleanup_func $argv[1]
    
    # Store cleanup function for this context
    set -g __fish_pack_cleanup_$fish_pid $cleanup_func
    
    # Set up exit handler
    function __fish_pack_on_exit_$fish_pid --on-process-exit $fish_pid
        # Run cleanup if it exists
        if set -q __fish_pack_cleanup_$fish_pid
            eval $__fish_pack_cleanup_$fish_pid
            set -e __fish_pack_cleanup_$fish_pid
        end
        
        # Remove this handler
        functions -e __fish_pack_on_exit_$fish_pid
    end
end

function __fish_pack_handle_error --description 'Handle errors with proper cleanup'
    set -l exit_code $argv[1]
    set -l error_msg $argv[2]
    set -l cleanup_func $argv[3]
    
    # Log error
    __fish_archive_log error "$error_msg (exit code: $exit_code)"
    
    # Run cleanup if provided
    if test -n "$cleanup_func"
        eval $cleanup_func
    end
    
    # Return error code
    return $exit_code
end

function __fish_pack_with_cleanup --description 'Execute command with automatic cleanup'
    set -l cleanup_func $argv[1]
    set -l command $argv[2..-1]
    
    # Set up cleanup trap
    __fish_pack_set_error_trap $cleanup_func
    
    # Execute command
    $command
    set -l result $status
    
    # Run cleanup regardless of result
    eval $cleanup_func
    
    # Clear cleanup trap
    set -e __fish_pack_cleanup_$fish_pid
    
    return $result
end

function __fish_pack_safe_operation --description 'Perform operation with rollback on failure'
    set -l operation_name $argv[1]
    set -l pre_check $argv[2]
    set -l main_operation $argv[3]
    set -l rollback $argv[4]
    set -l post_check $argv[5]
    
    __fish_archive_log info "Starting $operation_name..."
    
    # Pre-check
    if test -n "$pre_check"
        eval $pre_check; or begin
            __fish_archive_log error "$operation_name pre-check failed"
            return 1
        end
    end
    
    # Main operation
    eval $main_operation
    set -l result $status
    
    if test $result -ne 0
        __fish_archive_log error "$operation_name failed, rolling back..."
        if test -n "$rollback"
            eval $rollback
        end
        return $result
    end
    
    # Post-check
    if test -n "$post_check"
        eval $post_check; or begin
            __fish_archive_log warn "$operation_name post-check failed"
            if test -n "$rollback"
                eval $rollback
            end
            return 1
        end
    end
    
    __fish_archive_log info "$operation_name completed successfully"
    return 0
end

function __fish_pack_atomic_write --description 'Write file atomically with error handling'
    set -l target_file $argv[1]
    set -l content $argv[2]
    
    # Create temp file
    set -l temp_file (__fish_pack_secure_temp_file "atomic-write")
    
    # Write to temp file
    echo "$content" > "$temp_file"; or begin
        __fish_pack_cleanup_temp "$temp_file"
        return 1
    end
    
    # Move atomically
    mv -f "$temp_file" "$target_file"; or begin
        __fish_pack_cleanup_temp "$temp_file"
        return 1
    end
    
    return 0
end

function __fish_pack_ensure_directory --description 'Ensure directory exists with proper permissions'
    set -l dir $argv[1]
    set -l mode $argv[2]
    test -z "$mode"; and set mode "755"
    
    if not test -d "$dir"
        mkdir -p "$dir" 2>/dev/null; or return 1
        chmod "$mode" "$dir" 2>/dev/null; or return 1
    end
    
    # Verify it's writable
    if not test -w "$dir"
        __fish_archive_log error "Directory not writable: $dir"
        return 1
    end
    
    return 0
end

function __fish_pack_validate_operation --description 'Validate operation prerequisites'
    set -l operation $argv[1]
    set -l requirements $argv[2..-1]
    
    for req in $requirements
        switch $req
            case 'writable:*'
                set -l path (string replace 'writable:' '' -- $req)
                if not test -w "$path"
                    __fish_archive_log error "$operation requires write access to: $path"
                    return 1
                end
                
            case 'readable:*'
                set -l path (string replace 'readable:' '' -- $req)
                if not test -r "$path"
                    __fish_archive_log error "$operation requires read access to: $path"
                    return 1
                end
                
            case 'exists:*'
                set -l path (string replace 'exists:' '' -- $req)
                if not test -e "$path"
                    __fish_archive_log error "$operation requires file/directory to exist: $path"
                    return 1
                end
                
            case 'command:*'
                set -l cmd (string replace 'command:' '' -- $req)
                if not command -q "$cmd"
                    __fish_archive_log error "$operation requires command: $cmd"
                    return 1
                end
                
            case 'space:*'
                set -l required_mb (string replace 'space:' '' -- $req)
                set -l available_mb (df -m . | tail -1 | awk '{print $4}')
                if test $available_mb -lt $required_mb
                    __fish_archive_log error "$operation requires ${required_mb}MB free space (available: ${available_mb}MB)"
                    return 1
                end
        end
    end
    
    return 0
end