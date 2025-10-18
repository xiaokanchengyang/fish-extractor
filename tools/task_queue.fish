# Task queue for batch compression/extraction (fish 4.12+)

function archqueue --description 'Batch queue for compress/extract tasks'
    set -l usage "\
archqueue - Manage batch archive tasks (compress/extract)

Usage: archqueue [--parallel N|--sequential] [--stop-on-error] TASK...

TASK syntax:
  compress::OUTPUT::INPUTS...   # e.g., compress::out.tzst::dir1 file2
  extract::FILE::DEST           # e.g., extract::archive.zip::destdir

Options:
  --parallel N       Run up to N tasks in parallel
  --sequential       Run tasks sequentially (default)
  --stop-on-error    Stop on first failure
  --help             Show help
"

    set -l parallel 0
    set -l max_parallel 1
    set -l stop_on_error 0

    argparse -i 'parallel=' 'sequential' 'stop-on-error' 'help' -- $argv
    or begin
        echo $usage
        return 2
    end

    if set -q _flag_help
        echo $usage
        return 0
    end

    if set -q _flag_parallel
        set parallel 1
        set max_parallel $_flag_parallel
    else if set -q _flag_sequential
        set parallel 0
        set max_parallel 1
    end

    if set -q _flag_stop_on_error
        set stop_on_error 1
    end

    set -l tasks $argv
    if test (count $tasks) -eq 0
        echo "No tasks provided" >&2
        echo $usage
        return 2
    end
    
    set -l pids
    set -l running 0
    set -l failed 0

    for task in $tasks
        set -l parts (string split '::' -- $task)
        set -l kind $parts[1]
        switch $kind
            case compress
                set -l output $parts[2]
                set -l inputs $parts[3..-1]
                set -l cmd compress $output $inputs
            case extract
                set -l file $parts[2]
                set -l dest $parts[3]
                test -n "$dest"; or set dest ""
                if test -n "$dest"
                    set -l cmd extract -d "$dest" "$file"
                else
                    set -l cmd extract "$file"
                end
            case '*'
                echo "Unknown task: $task" >&2
                set failed (math $failed + 1)
                continue
        end

        if test $parallel -eq 1
            eval (string join ' ' $cmd) &
            set -a pids $last_pid
            set running (math $running + 1)
            while test $running -ge $max_parallel
                wait -n
                set -l rc $status
                set running (math $running - 1)
                if test $rc -ne 0
                    set failed (math $failed + 1)
                    if test $stop_on_error -eq 1
                        for pid in $pids
                            kill $pid 2>/dev/null
                        end
                        break
                    end
                end
            end
        else
            eval (string join ' ' $cmd)
            set -l rc $status
            if test $rc -ne 0
                set failed (math $failed + 1)
                if test $stop_on_error -eq 1
                    break
                end
            end
        end
    end

    # Wait for remaining background tasks
    if test $parallel -eq 1
        for pid in $pids
            wait $pid
            test $status -ne 0; and set failed (math $failed + 1)
        end
    end

    if test $failed -gt 0
        echo "Queue completed with $failed failure(s)" >&2
        return 1
    end
    echo "Queue completed successfully"
    return 0
end
