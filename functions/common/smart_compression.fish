# Smart compression logic for Fish Archive Manager (fish 4.12+)
# Analyzes content to automatically select optimal compression format

# Load platform helpers
source (dirname (status --current-filename))/platform_helpers.fish

# ============================================================================
# Content Analysis
# ============================================================================

function analyze_content_type --description 'Analyze content to determine optimal compression format'
    set -l input_path $argv[1]
    set -l sample_size $argv[2]
    test -n "$sample_size"; or set sample_size 200
    
    # Initialize counters
    set -l total_files 0
    set -l text_files 0
    set -l binary_files 0
    set -l total_size 0
    set -l text_size 0
    set -l binary_size 0
    
    # Sample files for analysis
    set -l sampled_files (_sample_files "$input_path" $sample_size)
    
    for file in $sampled_files
        set total_files (math $total_files + 1)
        set -l file_size (get_file_size "$file")
        set total_size (math $total_size + $file_size)
        
        # Determine if file is text or binary
        if _is_text_file "$file"
            set text_files (math $text_files + 1)
            set text_size (math $text_size + $file_size)
        else
            set binary_files (math $binary_files + 1)
            set binary_size (math $binary_size + $file_size)
        end
    end
    
    # Calculate ratios
    set -l text_ratio 0
    set -l file_text_ratio 0
    
    if test $total_size -gt 0
        set text_ratio (math -s2 "$text_size * 100 / $total_size")
    end
    
    if test $total_files -gt 0
        set file_text_ratio (math -s2 "$text_files * 100 / $total_files")
    end
    
    # Return analysis results
    echo "$text_ratio $file_text_ratio $total_size $total_files"
end

function _sample_files --description 'Sample files from input path for analysis'
    set -l input_path $argv[1]
    set -l max_files $argv[2]
    
    # Find files and sample them
    find "$input_path" -type f 2>/dev/null | head -n $max_files
end

function _is_text_file --description 'Check if file is text or binary'
    set -l file $argv[1]
    
    # Use file command if available
    if has_command file
        set -l mime_type (file -b --mime-type -- "$file" 2>/dev/null)
        if string match -q "text/*" -- $mime_type
            return 0
        else
            return 1
        end
    end
    
    # Fallback: check for null bytes
    if test -r "$file"
        # Check first 1024 bytes for null characters
        dd if="$file" bs=1 count=1024 2>/dev/null | grep -q $'\0'
        if test $status -eq 0
            return 1  # Binary file
        else
            return 0  # Text file
        end
    end
    
    return 1  # Assume binary if can't determine
end

# ============================================================================
# Format Selection Logic
# ============================================================================

function select_optimal_format --description 'Select optimal compression format based on content analysis'
    set -l text_ratio $argv[1]
    set -l file_text_ratio $argv[2]
    set -l total_size $argv[3]
    set -l total_files $argv[4]
    
    # Size thresholds (in bytes)
    set -l small_threshold 10485760    # 10MB
    set -l medium_threshold 104857600  # 100MB
    
    # Text ratio thresholds
    set -l high_text_threshold 70
    set -l medium_text_threshold 30
    
    # Decision logic
    if test $text_ratio -ge $high_text_threshold
        # High text content: use xz for maximum compression
        echo "tar.xz"
        return 0
    else if test $text_ratio -ge $medium_text_threshold; or test $total_size -ge $medium_threshold
        # Medium text content or large files: use gzip for balanced performance
        echo "tar.gz"
        return 0
    else if test $total_size -lt $small_threshold
        # Small files: use zstd for fast compression
        echo "tar.zst"
        return 0
    else
        # Binary-heavy or medium files: use zstd for good compression and speed
        echo "tar.zst"
        return 0
    end
end

function get_compression_recommendation --description 'Get detailed compression recommendation'
    set -l input_path $argv[1]
    set -l sample_size $argv[2]
    test -n "$sample_size"; or set sample_size 200
    
    # Analyze content
    set -l analysis (analyze_content_type "$input_path" $sample_size)
    set -l text_ratio $analysis[1]
    set -l file_text_ratio $analysis[2]
    set -l total_size $analysis[3]
    set -l total_files $analysis[4]
    
    # Select format
    set -l recommended_format (select_optimal_format $text_ratio $file_text_ratio $total_size $total_files)
    
    # Generate recommendation details
    set -l recommendation
    set -a recommendation "Format: $recommended_format"
    set -a recommendation "Text content: $text_ratio%"
    set -a recommendation "Text files: $file_text_ratio%"
    set -a recommendation "Total size: "(human_size $total_size)
    set -a recommendation "Files analyzed: $total_files"
    
    # Add reasoning
    if test $text_ratio -ge 70
        set -a recommendation "Reason: High text content - maximum compression with xz"
    else if test $text_ratio -ge 30; or test $total_size -ge 104857600
        set -a recommendation "Reason: Balanced content or large size - good compression with gzip"
    else
        set -a recommendation "Reason: Binary-heavy or small files - fast compression with zstd"
    end
    
    echo $recommendation
end

# ============================================================================
# Performance Optimization
# ============================================================================

function get_optimal_threads --description 'Get optimal thread count based on file characteristics'
    set -l total_size $argv[1]
    set -l format $argv[2]
    set -l available_cores (_detect_cores)
    
    # Base thread count
    set -l base_threads (math "max(1, min($available_cores - 1, 16))")
    
    # Adjust based on file size
    if test $total_size -lt 10485760  # < 10MB
        set base_threads (math "min(2, $base_threads)")
    else if test $total_size -lt 104857600  # < 100MB
        set base_threads (math "min(4, $base_threads)")
    end
    
    # Adjust based on format
    switch $format
        case tar.xz
            # xz is CPU intensive, use fewer threads
            set base_threads (math "min($base_threads, 4)")
        case tar.gz
            # gzip is balanced, use moderate threads
            set base_threads (math "min($base_threads, 8)")
        case tar.zst
            # zstd is efficient, can use more threads
            set base_threads (math "min($base_threads, 12)")
    end
    
    echo $base_threads
end

function get_optimal_compression_level --description 'Get optimal compression level based on content and use case'
    set -l format $argv[1]
    set -l text_ratio $argv[2]
    set -l total_size $argv[3]
    set -l use_case $argv[4]  # speed, balanced, compression
    
    # Default levels by format
    set -l default_levels
    switch $format
        case tar.xz
            set default_levels "1 3 6 9"
        case tar.gz
            set default_levels "1 3 6 9"
        case tar.zst
            set default_levels "1 3 6 19"
        case tar.lz4
            set default_levels "1 3 6 12"
        case '*'
            set default_levels "1 3 6 9"
    end
    
    # Select level based on use case
    switch $use_case
        case speed
            echo 1
        case balanced
            echo 6
        case compression
            echo 9
        case '*'
            # Auto-select based on content
            if test $text_ratio -ge 70
                echo 9  # High compression for text
            else if test $total_size -ge 104857600
                echo 6  # Balanced for large files
            else
                echo 3  # Fast for small files
            end
    end
end

# ============================================================================
# Format Comparison
# ============================================================================

function compare_compression_formats --description 'Compare compression efficiency across formats'
    set -l input_path $argv[1]
    set -l sample_size $argv[2]
    test -n "$sample_size"; or set sample_size 50
    
    # Get a small sample for testing
    set -l test_files (_sample_files "$input_path" $sample_size)
    if test (count $test_files) -eq 0
        echo "No files found for comparison"
        return 1
    end
    
    # Create temporary directory for testing
    set -l temp_dir (_create_temp_dir "compression_test")
    
    # Test formats
    set -l formats "tar.gz" "tar.xz" "tar.zst" "tar.lz4"
    set -l results
    
    for format in $formats
        set -l test_file "$temp_dir/test.$format"
        set -l start_time (date +%s)
        
        # Create test archive
        compress -F $format -L 6 "$test_file" $test_files >/dev/null 2>&1
        if test $status -eq 0
            set -l end_time (date +%s)
            set -l duration (math $end_time - $start_time)
            set -l size (get_file_size "$test_file")
            set -a results "$format:$size:$duration"
        end
    end
    
    # Cleanup
    rm -rf "$temp_dir"
    
    # Display results
    echo "Compression Format Comparison:"
    echo "Format    Size      Time"
    echo "--------  --------  ----"
    
    for result in $results
        set -l parts (string split ':' -- $result)
        set -l format $parts[1]
        set -l size $parts[2]
        set -l duration $parts[3]
        printf "%-8s  %-8s  %ds\n" $format (human_size $size) $duration
    end
end