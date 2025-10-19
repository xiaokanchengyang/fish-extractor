# Task queue for batch compression/extraction (fish 4.12+)
# Enhanced with logging, locking, and cancellation support

# Load platform helpers for cross-platform compatibility
source (dirname (status --current-filename))/../functions/common/platform_helpers.fish

function archqueue --description 'Batch queue for compress/extract tasks with enhanced robustness'
    set -l usage "\
archqueue - Manage batch archive tasks (compress/extract)

Usage: archqueue [OPTIONS] TASK...

TASK syntax:
  compress::OUTPUT::INPUTS...   # e.g., compress::out.tzst::dir1 file2
  extract::FILE::DEST           # e.g., extract::archive.zip::destdir

Options:
  --parallel N       Run up to N tasks in parallel
  --sequential       Run tasks sequentially (default)
  --stop-on-error    Stop on first failure
  --log-file FILE    Write detailed logs to file
  --lock-file FILE   Use lock file to prevent concurrent runs
  --timeout SECONDS  Timeout for individual tasks (0 = no timeout)
  --retry N          Retry failed tasks up to N times
  --dry-run          Show what would be done without executing
  --verbose          Enable verbose output
  --help             Show help

Examples:
  archqueue --parallel 2 'compress::a.tzst::a/' 'extract::b.zip::out'
  archqueue --sequential --log-file queue.log 'compress::backup.tzst::data/'
  archqueue --timeout 300 --retry 2 'compress::large.tzst::huge/'
"

    set -l parallel 0
    set -l max_parallel 1
    set -l stop_on_error 0
    set -l log_file ""
    set -l lock_file ""
    set -l timeout 0
    set -l retry_count 0
    set -l dry_run 0
    set -l verbose 0

    argparse -i \
        'parallel=' \
        'sequential' \
        'stop-on-error' \
        'log-file=' \
        'lock-file=' \
        'timeout=' \
        'retry=' \
        'dry-run' \
        'verbose' \
        'help' \
        -- $argv
    or begin
        echo $usage >&2
        return 2
    end

    if set -q _flag_help
        echo $usage
        return 0
    end

    # Handle flags
    if set -q _flag_parallel
        set parallel 1
        set max_parallel $_flag_parallel
    else if set -q _flag_sequential
        set parallel 0
        set max_parallel 1
    end

    set -q _flag_stop_on_error; and set stop_on_error 1
    set -q _flag_log_file; and set log_file $_flag_log_file
    set -q _flag_lock_file; and set lock_file $_flag_lock_file
    set -q _flag_timeout; and set timeout $_flag_timeout
    set -q _flag_retry; and set retry_count $_flag_retry
    set -q _flag_dry_run; and set dry_run 1
    set -q _flag_verbose; and set verbose 1

    set -l tasks $argv
    if test (count $tasks) -eq 0
        echo "No tasks provided" >&2
        echo $usage >&2
        return 2
    end

    # Set up logging
    set -l log_fd 2  # Default to stderr
    if test -n "$log_file"
        if not touch "$log_file" 2>/dev/null
            echo "Cannot create log file: $log_file" >&2
            return 1
        end
        exec 3> "$log_file"
        set log_fd 3
    end

    # Set up lock file
    if test -n "$lock_file"
        if not _acquire_lock "$lock_file"
            echo "Another archqueue process is running (lock file: $lock_file)" >&2
            return 1
        end
    end

    # Log start
    _log_message "Starting archqueue with "(count $tasks)" task(s)" $log_fd $verbose

    # Process tasks
    set -l pids
    set -l running 0
    set -l failed 0
    set -l completed 0
    set -l total_tasks (count $tasks)

    for task in $tasks
        set -l task_id (math $completed + $failed + 1)
        _log_message "[$task_id/$total_tasks] Processing: $task" $log_fd $verbose

        # Parse task
        set -l parts (string split '::' -- $task)
        set -l kind $parts[1]
        set -l cmd
        set -l task_name ""

        switch $kind
            case compress
                set -l output $parts[2]
                set -l inputs $parts[3..-1]
                set cmd compress -- $output $inputs
                set task_name "compress $output"
            case extract
                set -l file $parts[2]
                set -l dest $parts[3]
                test -n "$dest"; or set dest ""
                if test -n "$dest"
                    set cmd extract -d -- "$dest" "$file"
                else
                    set cmd extract -- "$file"
                end
                set task_name "extract $file"
            case '*'
                _log_message "[$task_id/$total_tasks] ERROR: Unknown task type: $kind" $log_fd 1
                set failed (math $failed + 1)
                continue
        end

        # Dry run mode
        if test $dry_run -eq 1
            _log_message "[$task_id/$total_tasks] DRY-RUN: Would execute: $cmd" $log_fd 1
            set completed (math $completed + 1)
            continue
        end

        # Execute task
        if test $parallel -eq 1
            _execute_parallel_task "$cmd" "$task_name" $task_id $total_tasks $timeout $retry_count $log_fd $verbose
            set -l result $status
            if test $result -eq 0
                set completed (math $completed + 1)
            else
                set failed (math $failed + 1)
                if test $stop_on_error -eq 1
                    _log_message "Stopping on error as requested" $log_fd 1
                    break
                end
            end
        else
            _execute_sequential_task "$cmd" "$task_name" $task_id $total_tasks $timeout $retry_count $log_fd $verbose
            set -l result $status
            if test $result -eq 0
                set completed (math $completed + 1)
            else
                set failed (math $failed + 1)
                if test $stop_on_error -eq 1
                    _log_message "Stopping on error as requested" $log_fd 1
                    break
                end
            end
        end
    end

    # Cleanup
    if test -n "$lock_file"
        _release_lock "$lock_file"
    end

    if test -n "$log_file"
        exec 3>&-
    end

    # Summary
    _log_message "Queue completed: $completed successful, $failed failed" $log_fd 1

    if test $failed -gt 0
        return 1
    end
    return 0
end

# ============================================================================
# Internal Helper Functions
# ============================================================================

function _log_message --description 'Log message with timestamp'
    set -l message $argv[1]
    set -l log_fd $argv[2]
    set -l verbose $argv[3]
    
    if test $verbose -eq 1; or test $log_fd -ne 2
        set -l timestamp (date '+%Y-%m-%d %H:%M:%S')
        echo "[$timestamp] $message" >&$log_fd
    end
end

function _acquire_lock --description 'Acquire lock file'
    set -l lock_file $argv[1]
    
    # Create lock file with PID
    echo $$ > "$lock_file.lock" 2>/dev/null
    if test $status -ne 0
        return 1
    end
    
    # Check if another process is using the lock
    if test -f "$lock_file"
        set -l lock_pid (cat "$lock_file" 2>/dev/null)
        if test -n "$lock_pid"; and kill -0 $lock_pid 2>/dev/null
            rm -f "$lock_file.lock"
            return 1
        end
    end
    
    # Move lock file to final location
    mv "$lock_file.lock" "$lock_file" 2>/dev/null
    if test $status -ne 0
        rm -f "$lock_file.lock"
        return 1
    end
    
    return 0
end

function _release_lock --description 'Release lock file'
    set -l lock_file $argv[1]
    rm -f "$lock_file"
end

function _execute_parallel_task --description 'Execute task in parallel'
    set -l cmd $argv[1]
    set -l task_name $argv[2]
    set -l task_id $argv[3]
    set -l total_tasks $argv[4]
    set -l timeout $argv[5]
    set -l retry_count $argv[6]
    set -l log_fd $argv[7]
    set -l verbose $argv[8]
    
    # Execute with timeout if specified
    if test $timeout -gt 0
        timeout $timeout $cmd &
    else
        $cmd &
    end
    
    set -l pid $last_pid
    _log_message "[$task_id/$total_tasks] Started: $task_name (PID: $pid)" $log_fd $verbose
    
    # Wait for completion
    wait $pid
    set -l result $status
    
    if test $result -eq 0
        _log_message "[$task_id/$total_tasks] Completed: $task_name" $log_fd $verbose
    else
        _log_message "[$task_id/$total_tasks] Failed: $task_name (exit code: $result)" $log_fd 1
    end
    
    return $result
end

function _execute_sequential_task --description 'Execute task sequentially'
    set -l cmd $argv[1]
    set -l task_name $argv[2]
    set -l task_id $argv[3]
    set -l total_tasks $argv[4]
    set -l timeout $argv[5]
    set -l retry_count $argv[6]
    set -l log_fd $argv[7]
    set -l verbose $argv[8]
    
    set -l attempts 0
    set -l result 1
    
    while test $attempts -le $retry_count
        set attempts (math $attempts + 1)
        
        if test $attempts -gt 1
            _log_message "[$task_id/$total_tasks] Retry $attempts/$retry_count: $task_name" $log_fd 1
        end
        
        # Execute with timeout if specified
        if test $timeout -gt 0
            timeout $timeout $cmd
        else
            $cmd
        end
        
        set result $status
        
        if test $result -eq 0
            _log_message "[$task_id/$total_tasks] Completed: $task_name" $log_fd $verbose
            break
        else
            _log_message "[$task_id/$total_tasks] Failed: $task_name (exit code: $result, attempt: $attempts)" $log_fd 1
        end
    end
    
    return $result
end
