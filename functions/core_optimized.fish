# Optimized core utilities for Fish Archive Manager (fish 4.12+)
# Uses modern Fish 4.12+ features for better performance and maintainability

# ============================================================================
# Modern Fish 4.12+ Utilities
# ============================================================================

function __fish_archive_version --description 'Get Fish Archive Manager version'
    if test -f (dirname (status --current-filename))/../VERSION
        cat (dirname (status --current-filename))/../VERSION
    else
        echo "unknown"
    end
end

function __fish_archive_is_fish_4_12_plus --description 'Check if Fish version is 4.12 or higher'
    set -l version (fish --version | string match -r '\d+\.\d+')
    set -l major (string split . -- $version)[1]
    set -l minor (string split . -- $version)[2]
    
    test $major -gt 4; or (test $major -eq 4; and test $minor -ge 12)
end

# ============================================================================
# Enhanced Color and Output Management
# ============================================================================

function __fish_archive_supports_color --description 'Check if colored output is enabled'
    switch "$FISH_ARCHIVE_COLOR"
        case never
            return 1
        case always
            return 0
        case auto '*'
            isatty stdout
    end
end

function __fish_archive_colorize --description 'Apply color to text if enabled'
    set -l color $argv[1]
    set -l text $argv[2..-1]
    
    if __fish_archive_supports_color
        set_color $color
        string join ' ' $text
        set_color normal
    else
        string join ' ' $text
    end
end

# ============================================================================
# Enhanced Logging System with Modern Fish Features
# ============================================================================

function __fish_archive_log --description 'Structured logging with levels and modern Fish features'
    set -l level $argv[1]
    set -l msg $argv[2..-1]
    
    # Use modern Fish string operations
    set -l levels debug info warn error
    set -l current_level (string lower -- $FISH_ARCHIVE_LOG_LEVEL)
    
    # Find current level index
    set -l idx_current (string match -n -- $current_level $levels | head -1)
    or set idx_current 2  # Default to info
    
    # Find message level index
    set -l idx_message (string match -n -- $level $levels | head -1)
    or set idx_message 2
    
    # Skip if message level is below current log level
    test $idx_message -lt $idx_current; and return
    
    # Color mapping using modern Fish features
    set -l color_map debug=cyan info=green warn=yellow error=red
    set -l color normal
    
    for pair in $color_map
        set -l parts (string split = -- $pair)
        if test "$parts[1]" = "$level"
            set color $parts[2]
            break
        end
    end
    
    # Format message with modern string operations
    set -l formatted_msg (string join ' ' -- "[$level]" $msg)
    
    if __fish_archive_supports_color
        set_color $color
        echo $formatted_msg >&2
        set_color normal
    else
        echo $formatted_msg >&2
    end
end

# ============================================================================
# Enhanced Command and Tool Management
# ============================================================================

function __fish_archive_require_commands --description 'Verify required commands exist with better error reporting'
    set -l missing
    set -l available
    
    for cmd in $argv
        if command -q $cmd
            set -a available $cmd
        else
            set -a missing $cmd
        end
    end
    
    if test (count $missing) -gt 0
        __fish_archive_log error "Missing required commands: "(string join ', ' $missing)
        if test (count $available) -gt 0
            __fish_archive_log info "Available commands: "(string join ', ' $available)
        end
        return 1
    end
end

function __fish_archive_best_available --description 'Return first available command from list with fallback info'
    set -l available
    set -l unavailable
    
    for cmd in $argv
        if command -q $cmd
            echo $cmd
            return 0
        else
            set -a unavailable $cmd
        end
    end
    
    __fish_archive_log debug "No commands available from: "(string join ', ' $unavailable)
    return 1
end

function __fish_archive_has_command --description 'Check if command is available'
    command -q $argv[1]
end

# ============================================================================
# Enhanced Progress Display with Modern Features
# ============================================================================

function __fish_archive_can_show_progress --description 'Check if progress display is enabled'
    switch "$FISH_ARCHIVE_PROGRESS"
        case never
            return 1
        case always
            __fish_archive_has_command pv; and return 0
            return 1
        case auto '*'
            if isatty stdout; and __fish_archive_has_command pv
                return 0
            end
            return 1
    end
end

function __fish_archive_show_spinner --description 'Display modern spinner animation'
    set -l pid $argv[1]
    set -l msg $argv[2..-1]
    
    isatty stdout; or begin
        wait $pid
        return
    end
    
    # Modern Unicode spinner frames
    set -l frames '⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏'
    set -l idx 1
    set -l frame_count (count $frames)
    
    while kill -0 $pid 2>/dev/null
        printf '\r%s %s' (__fish_archive_colorize cyan $msg) "$frames[$idx]"
        sleep 0.1
        set idx (math "($idx % $frame_count) + 1")
    end
    
    printf '\r%-60s\r' ' '  # Clear line
end

function __fish_archive_show_progress_bar --description 'Show progress bar with enhanced pv integration'
    set -l size $argv[1]
    
    if __fish_archive_can_show_progress
        # Enhanced pv with better formatting
        pv -p -t -e -r -a -b -s $size --format 'ETA: %E | Rate: %R | Avg: %a | %p%'
    else
        # Passthrough without progress
        cat
    end
end

# ============================================================================
# Enhanced Thread/Concurrency Management
# ============================================================================

function __fish_archive_resolve_threads --description 'Resolve thread count with intelligent defaults'
    set -l requested $argv[1]
    
    if test -n "$requested"; and test "$requested" -gt 0 2>/dev/null
        echo $requested
    else if test -n "$FISH_ARCHIVE_DEFAULT_THREADS"
        echo $FISH_ARCHIVE_DEFAULT_THREADS
    else
        # Try multiple methods to get CPU count
        nproc 2>/dev/null; or sysctl -n hw.ncpu 2>/dev/null; or echo 4
    end
end

function __fish_archive_optimal_threads --description 'Get optimal thread count based on file size and system'
    set -l file_size $argv[1]
    set -l max_threads (__fish_archive_resolve_threads "")
    
    # Intelligent thread scaling based on file size
    if test $file_size -lt 10485760  # < 10MB
        echo (math "min(2, $max_threads)")
    else if test $file_size -lt 104857600  # < 100MB
        echo (math "min(4, $max_threads)")
    else if test $file_size -lt 1073741824  # < 1GB
        echo (math "min(8, $max_threads)")
    else  # >= 1GB
        echo $max_threads
    end
end

# ============================================================================
# Enhanced Path and File Utilities with Modern Fish Features
# ============================================================================

function __fish_archive_sanitize_path --description 'Expand and normalize file path with modern Fish features'
    set -l path $argv[1]
    
    # Use modern Fish path expansion
    set -l expanded (string expand -- $path)
    
    # Normalize path separators
    set -l normalized (string replace -r '//+' '/' -- $expanded)
    
    # Remove trailing slash for directories
    string replace -r '/$' '' -- $normalized
end

function __fish_archive_get_extension --description 'Extract file extension with support for double extensions'
    set -l file $argv[1]
    
    # Use modern Fish string operations
    set -l basename (basename -- $file)
    set -l parts (string split . -- $basename)
    
    if test (count $parts) -ge 2
        # Handle double extensions like .tar.gz
        if test (count $parts) -ge 3; and test "$parts[-2]" = "tar"
            echo "tar.$parts[-1]"
        else
            echo ".$parts[-1]"
        end
    else
        echo ""
    end
end

function __fish_archive_get_mime_type --description 'Get MIME type using modern Fish features'
    set -l file $argv[1]
    
    if __fish_archive_has_command file
        # Use modern Fish string operations
        file -b --mime-type "$file" 2>/dev/null | string trim
    else
        echo ""
    end
end

function __fish_archive_basename_without_ext --description 'Get basename without extension using modern Fish features'
    set -l file $argv[1]
    
    set -l basename (basename -- $file)
    set -l ext (__fish_archive_get_extension $file)
    
    if test -n "$ext"
        string replace -r (string escape -- $ext)'$' '' -- $basename
    else
        echo $basename
    end
end

function __fish_archive_default_extract_dir --description 'Generate default extraction directory name'
    set -l archive $argv[1]
    
    set -l basename (__fish_archive_basename_without_ext $archive)
    echo $basename
end

function __fish_archive_get_file_size --description 'Get file size in bytes with error handling'
    set -l file $argv[1]
    
    if test -f "$file"
        stat -c%s "$file" 2>/dev/null; or stat -f%z "$file" 2>/dev/null; or echo 0
    else
        echo 0
    end
end

function __fish_archive_human_size --description 'Convert bytes to human-readable format'
    set -l bytes $argv[1]
    
    if test $bytes -lt 1024
        echo "${bytes}B"
    else if test $bytes -lt 1048576
        echo (math -s1 "$bytes / 1024")"KB"
    else if test $bytes -lt 1073741824
        echo (math -s1 "$bytes / 1048576")"MB"
    else
        echo (math -s1 "$bytes / 1073741824")"GB"
    end
end

# ============================================================================
# Enhanced Archive Format Detection
# ============================================================================

function __fish_archive_detect_format --description 'Enhanced format detection with modern Fish features'
    set -l file $argv[1]
    
    # Extension-based detection with modern string operations
    set -l ext (__fish_archive_get_extension $file)
    set -l ext_format (__fish_archive_get_format_from_extension $ext)
    
    if test "$ext_format" != "unknown"
        echo $ext_format
        return 0
    end
    
    # MIME type detection
    set -l mime (__fish_archive_get_mime_type $file)
    if test -n "$mime"
        set -l mime_format (__fish_archive_get_format_from_mime $mime)
        if test "$mime_format" != "unknown"
            echo $mime_format
            return 0
        end
    end
    
    # Fallback to unknown
    echo "unknown"
    return 1
end

function __fish_archive_get_format_from_extension --description 'Get format from file extension'
    set -l ext (string lower -- $argv[1])
    
    # Use modern Fish switch with multiple patterns
    switch $ext
        case '.tar.gz' '.tgz'
            echo "tar.gz"
        case '.tar.bz2' '.tbz2' '.tbz'
            echo "tar.bz2"
        case '.tar.xz' '.txz'
            echo "tar.xz"
        case '.tar.zst' '.tzst'
            echo "tar.zst"
        case '.tar.lz4' '.tlz4'
            echo "tar.lz4"
        case '.tar.lz' '.tlz'
            echo "tar.lz"
        case '.tar.lzo' '.tzo'
            echo "tar.lzo"
        case '.tar.br' '.tbr'
            echo "tar.br"
        case '.zip'
            echo "zip"
        case '.7z'
            echo "7z"
        case '.rar'
            echo "rar"
        case '.gz'
            echo "gz"
        case '.bz2'
            echo "bz2"
        case '.xz'
            echo "xz"
        case '.zst'
            echo "zst"
        case '.lz4'
            echo "lz4"
        case '.lz'
            echo "lz"
        case '.lzo'
            echo "lzo"
        case '.br'
            echo "br"
        case '.iso'
            echo "iso"
        case '.deb'
            echo "deb"
        case '.rpm'
            echo "rpm"
        case '*'
            echo "unknown"
    end
end

function __fish_archive_get_format_from_mime --description 'Get format from MIME type'
    set -l mime (string lower -- $argv[1])
    
    switch $mime
        case 'application/gzip' 'application/x-gzip'
            echo "gz"
        case 'application/x-bzip2'
            echo "bz2"
        case 'application/x-xz'
            echo "xz"
        case 'application/zstd'
            echo "zst"
        case 'application/x-lz4'
            echo "lz4"
        case 'application/x-lzip'
            echo "lz"
        case 'application/x-lzop'
            echo "lzo"
        case 'application/x-brotli'
            echo "br"
        case 'application/zip'
            echo "zip"
        case 'application/x-7z-compressed'
            echo "7z"
        case 'application/x-rar'
            echo "rar"
        case 'application/x-iso9660-image'
            echo "iso"
        case 'application/vnd.debian.binary-package'
            echo "deb"
        case 'application/x-rpm'
            echo "rpm"
        case '*'
            echo "unknown"
    end
end

# ============================================================================
# Enhanced Smart Format Selection
# ============================================================================

function __fish_archive_analyze_content --description 'Analyze content to determine optimal compression format'
    set -l inputs $argv
    
    set -l text_files 0
    set -l total_files 0
    set -l text_size 0
    set -l total_size 0
    
    # Sample files for analysis (limit to 200 for performance)
    set -l sample_files (__fish_archive_sample_files $inputs 200)
    
    for file in $sample_files
        set -l mime (__fish_archive_get_mime_type $file)
        set -l size (__fish_archive_get_file_size $file)
        
        set total_files (math "$total_files + 1")
        set total_size (math "$total_size + $size")
        
        # Check if file is text-based
        if string match -q 'text/*' $mime; or string match -q 'application/json' $mime; or string match -q 'application/xml' $mime
            set text_files (math "$text_files + 1")
            set text_size (math "$text_size + $size")
        end
    end
    
    # Calculate ratios
    set -l text_ratio 0
    set -l size_ratio 0
    
    if test $total_files -gt 0
        set text_ratio (math -s2 "$text_files * 100 / $total_files")
    end
    
    if test $total_size -gt 0
        set size_ratio (math -s2 "$text_size * 100 / $total_size")
    end
    
    # Return analysis results
    echo "$text_ratio $size_ratio $total_files $total_size"
end

function __fish_archive_sample_files --description 'Sample files for content analysis'
    set -l inputs $argv[1..-2]
    set -l max_files $argv[-1]
    
    set -l sampled
    set -l count 0
    
    for input in $inputs
        if test $count -ge $max_files
            break
        end
        
        if test -f "$input"
            set -a sampled "$input"
            set count (math "$count + 1")
        else if test -d "$input"
            # Sample files from directory
            for file in (find "$input" -type f | head -n (math "$max_files - $count"))
                set -a sampled "$file"
                set count (math "$count + 1")
            end
        end
    end
    
    echo $sampled
end

function __fish_archive_smart_format --description 'Choose optimal compression format based on content analysis'
    set -l inputs $argv
    
    set -l analysis (__fish_archive_analyze_content $inputs)
    set -l text_ratio (echo $analysis | cut -d' ' -f1)
    set -l size_ratio (echo $analysis | cut -d' ' -f2)
    set -l total_info (__fish_archive_analyze_content $inputs)
    set -l total_files (echo $total_info | awk '{print $3}')
    set -l total_size (echo $total_info | awk '{print $4}')
    set -l has_pigz (__fish_archive_has_command pigz; and echo 1; or echo 0)
    
    # Size thresholds
    set -l HUGE 1073741824     # 1 GiB
    set -l BIG  268435456      # 256 MiB

    # Very large datasets → gzip (pigz if available) for broad compatibility
    if test -n "$total_size"; and test $total_size -ge $HUGE
        if test $has_pigz -eq 1
            echo "tar.gz"
            return
        end
        echo "tar.gz"
        return
    end

    # Content-based selection
    if test (math "$text_ratio >= 70") -eq 1
        echo "tar.xz"  # Maximum compression for text
        return
    end

    if test -n "$total_size"; and test $total_size -ge $BIG
        echo "tar.gz"  # Mixed big datasets → gzip/pigz
        return
    end

    if test (math "$text_ratio >= 30") -eq 1
        echo "tar.gz"  # Balanced compression
        return
    end

    echo "tar.zst"  # Fast compression for binary/small-medium
end

# ============================================================================
# Enhanced Validation Functions
# ============================================================================

function __fish_archive_validate_level --description 'Validate compression level for format'
    set -l level $argv[1]
    set -l format $argv[2]
    
    # Format-specific level ranges
    switch $format
        case 'gz' 'tar.gz' 'tgz'
            test $level -ge 1; and test $level -le 9
        case 'bz2' 'tar.bz2' 'tbz2' 'tbz'
            test $level -ge 1; and test $level -le 9
        case 'xz' 'tar.xz' 'txz'
            test $level -ge 0; and test $level -le 9
        case 'zst' 'tar.zst' 'tzst'
            test $level -ge 1; and test $level -le 19
        case 'lz4' 'tar.lz4' 'tlz4'
            test $level -ge 1; and test $level -le 12
        case 'lz' 'tar.lz' 'tlz'
            test $level -ge 1; and test $level -le 9
        case 'lzo' 'tar.lzo' 'tzo'
            test $level -ge 1; and test $level -le 9
        case 'br' 'tar.br' 'tbr'
            test $level -ge 1; and test $level -le 11
        case 'zip' '7z'
            test $level -ge 0; and test $level -le 9
        case '*'
            return 1
    end
end

function __fish_archive_validate_archive --description 'Validate archive file exists and is readable'
    set -l archive $argv[1]
    
    if not test -f "$archive"
        __fish_archive_log error "Archive file not found: $archive"
        return 1
    end
    
    if not test -r "$archive"
        __fish_archive_log error "Archive file not readable: $archive"
        return 1
    end
    
    return 0
end

# ============================================================================
# Enhanced Hash and Checksum Functions
# ============================================================================

function __fish_archive_calculate_hash --description 'Calculate file hash with multiple algorithms'
    set -l file $argv[1]
    set -l algorithm $argv[2]
    
    switch $algorithm
        case 'md5'
            if __fish_archive_has_command md5sum
                md5sum "$file" | cut -d' ' -f1
            else if __fish_archive_has_command md5
                md5 -q "$file"
            else
                return 1
            end
        case 'sha1'
            if __fish_archive_has_command sha1sum
                sha1sum "$file" | cut -d' ' -f1
            else if __fish_archive_has_command shasum
                shasum -a 1 "$file" | cut -d' ' -f1
            else
                return 1
            end
        case 'sha256'
            if __fish_archive_has_command sha256sum
                sha256sum "$file" | cut -d' ' -f1
            else if __fish_archive_has_command shasum
                shasum -a 256 "$file" | cut -d' ' -f1
            else
                return 1
            end
        case 'sha512'
            if __fish_archive_has_command sha512sum
                sha512sum "$file" | cut -d' ' -f1
            else if __fish_archive_has_command shasum
                shasum -a 512 "$file" | cut -d' ' -f1
            else
                return 1
            end
        case '*'
            return 1
    end
end

# ============================================================================
# Modern Fish 4.12+ Feature Detection
# ============================================================================

function __fish_archive_check_fish_features --description 'Check for modern Fish features'
    if not __fish_archive_is_fish_4_12_plus
        __fish_archive_log warn "Fish version 4.12+ recommended for optimal performance"
        return 1
    end
    return 0
end

# ============================================================================
# Performance Optimization Helpers
# ============================================================================

function __fish_archive_optimize_for_size --description 'Optimize settings for file size'
    set -l file_size $argv[1]
    
    if test $file_size -lt 10485760  # < 10MB
        echo "fast"
    else if test $file_size -lt 104857600  # < 100MB
        echo "balanced"
    else
        echo "thorough"
    end
end

function __fish_archive_should_use_parallel --description 'Determine if parallel processing should be used'
    set -l file_size $argv[1]
    set -l threads $argv[2]
    
    # Use parallel processing for larger files or when explicitly requested
    test $file_size -gt 10485760; or test $threads -gt 1
end