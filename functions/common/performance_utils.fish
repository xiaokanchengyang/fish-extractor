# Performance utilities for Fish Pack (fish 4.1.2+)
# Common functions for measuring and optimizing performance

function __fish_pack_start_measurement --description 'Start performance measurement'
    # Returns measurement data as a string
    set -l start_ts (date +%s)
    set -l cpu_start ""
    set -l idle_start ""
    
    # Try to get CPU stats on Linux
    if test -f /proc/stat
        set cpu_start (cat /proc/stat 2>/dev/null | head -n1 | awk '{print $2+$3+$4+$5+$6+$7+$8}')
        set idle_start (cat /proc/stat 2>/dev/null | head -n1 | awk '{print $5}')
    end
    
    # Return as space-separated values
    echo "$start_ts $cpu_start $idle_start"
end

function __fish_pack_end_measurement --description 'End performance measurement and calculate stats'
    set -l start_data $argv[1]
    
    # Parse start data
    set -l start_ts (echo $start_data | cut -d' ' -f1)
    set -l cpu_start (echo $start_data | cut -d' ' -f2)
    set -l idle_start (echo $start_data | cut -d' ' -f3)
    
    # Get end measurements
    set -l end_ts (date +%s)
    set -l duration (math "$end_ts - $start_ts")
    
    # Calculate CPU usage if available
    set -l cpu_pct ""
    if test -n "$cpu_start" -a -f /proc/stat
        set -l cpu_end (cat /proc/stat 2>/dev/null | head -n1 | awk '{print $2+$3+$4+$5+$6+$7+$8}')
        set -l idle_end (cat /proc/stat 2>/dev/null | head -n1 | awk '{print $5}')
        
        if test -n "$cpu_end" -a -n "$idle_end"
            set -l cpu_delta (math "$cpu_end - $cpu_start")
            set -l idle_delta (math "$idle_end - $idle_start")
            
            if test $cpu_delta -gt 0
                set -l busy (math "$cpu_delta - $idle_delta")
                set cpu_pct (math -s1 "$busy * 100 / $cpu_delta")
            end
        end
    end
    
    # Return duration and CPU percentage
    echo "$duration $cpu_pct"
end

function __fish_pack_measure_operation --description 'Measure operation performance'
    set -l operation_name $argv[1]
    set -l callback $argv[2]
    set -l args $argv[3..-1]
    
    # Start measurement
    set -l start_data (__fish_pack_start_measurement)
    
    # Run operation
    $callback $args
    set -l result $status
    
    # End measurement
    set -l perf_data (__fish_pack_end_measurement "$start_data")
    set -l duration (echo $perf_data | cut -d' ' -f1)
    set -l cpu_pct (echo $perf_data | cut -d' ' -f2)
    
    # Log performance
    if test -n "$cpu_pct"
        __fish_archive_log debug "$operation_name completed in ${duration}s (CPU: ${cpu_pct}%)"
    else
        __fish_archive_log debug "$operation_name completed in ${duration}s"
    end
    
    return $result
end

function __fish_pack_auto_threads --description 'Automatically determine optimal thread count'
    set -l operation $argv[1]  # 'compress' or 'extract'
    set -l size_mb $argv[2]
    
    # Get CPU count
    set -l cpu_count (nproc 2>/dev/null; or sysctl -n hw.ncpu 2>/dev/null; or echo 4)
    
    # Base thread count on operation and size
    set -l threads $cpu_count
    
    switch $operation
        case compress
            # Compression is CPU intensive
            if test $size_mb -lt 10
                set threads 1  # Small files don't benefit from threading
            else if test $size_mb -lt 100
                set threads (math "min($cpu_count, 4)")
            else if test $size_mb -lt 1000
                set threads (math "min($cpu_count, 8)")
            else
                set threads $cpu_count
            end
            
        case extract
            # Extraction is often I/O bound
            if test $size_mb -lt 50
                set threads 1
            else if test $size_mb -lt 500
                set threads (math "min($cpu_count, 4)")
            else
                set threads (math "min($cpu_count, 8)")
            end
    end
    
    # Respect user settings
    if set -q FISH_PACK_MAX_THREADS
        set threads (math "min($threads, $FISH_PACK_MAX_THREADS)")
    end
    
    # Ensure at least 1 thread
    test $threads -lt 1; and set threads 1
    
    echo $threads
end

function __fish_pack_estimate_time --description 'Estimate operation time'
    set -l size_mb $argv[1]
    set -l operation $argv[2]
    set -l format $argv[3]
    
    # Base rates in MB/s (conservative estimates)
    set -l rate 10  # Default 10 MB/s
    
    switch $operation
        case compress
            switch $format
                case 'tar' 'tar.gz' 'tgz'
                    set rate 30
                case 'tar.bz2' 'tbz2'
                    set rate 5
                case 'tar.xz' 'txz'
                    set rate 3
                case 'tar.zst' 'tzst'
                    set rate 50
                case 'zip'
                    set rate 25
                case '7z'
                    set rate 8
            end
            
        case extract
            switch $format
                case 'tar' 'tar.gz' 'tgz'
                    set rate 50
                case 'tar.bz2' 'tbz2'
                    set rate 15
                case 'tar.xz' 'txz'
                    set rate 20
                case 'tar.zst' 'tzst'
                    set rate 100
                case 'zip'
                    set rate 40
                case '7z'
                    set rate 25
            end
    end
    
    # Calculate estimated seconds
    set -l seconds (math -s0 "$size_mb / $rate")
    test $seconds -lt 1; and set seconds 1
    
    echo $seconds
end

function __fish_pack_format_duration --description 'Format duration in human-readable form'
    set -l seconds $argv[1]
    
    if test $seconds -lt 60
        echo "${seconds}s"
    else if test $seconds -lt 3600
        set -l minutes (math -s0 "$seconds / 60")
        set -l remaining (math "$seconds % 60")
        echo "${minutes}m ${remaining}s"
    else
        set -l hours (math -s0 "$seconds / 3600")
        set -l minutes (math -s0 "($seconds % 3600) / 60")
        echo "${hours}h ${minutes}m"
    end
end

function __fish_pack_format_size --description 'Format size in human-readable form'
    set -l bytes $argv[1]
    
    if test $bytes -lt 1024
        echo "$bytes B"
    else if test $bytes -lt 1048576
        set -l kb (math -s1 "$bytes / 1024")
        echo "$kb KB"
    else if test $bytes -lt 1073741824
        set -l mb (math -s1 "$bytes / 1048576")
        echo "$mb MB"
    else
        set -l gb (math -s2 "$bytes / 1073741824")
        echo "$gb GB"
    end
end