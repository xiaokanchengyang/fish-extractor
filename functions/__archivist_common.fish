# Common utilities for Archivist plugin (fish 4.12+)
# Provides shared functions for logging, colors, path handling, format detection, and tool checking

# ============================================================================
# Color and Output Management
# ============================================================================

function __archivist__supports_color --description 'Check if colored output is enabled'
    switch "$ARCHIVIST_COLOR"
        case never
            return 1
        case always
            return 0
        case auto '*'
            isatty stdout
    end
end

function __archivist__colorize --description 'Apply color to text if enabled'
    set -l color $argv[1]
    set -l text $argv[2..-1]
    
    if __archivist__supports_color
        set_color $color
        string join ' ' $text
        set_color normal
    else
        string join ' ' $text
    end
end

# ============================================================================
# Logging System
# ============================================================================

function __archivist__log --description 'Structured logging with levels'
    set -l level $argv[1]
    set -l msg $argv[2..-1]
    
    # Determine if this message should be logged based on log level
    set -l levels debug info warn error
    set -l current_level (string lower -- $ARCHIVIST_LOG_LEVEL)
    
    set -l idx_current (contains --index -- $current_level $levels)
    or set idx_current 2  # Default to info
    
    set -l idx_message (contains --index -- $level $levels)
    or set idx_message 2
    
    # Skip if message level is below current log level
    test $idx_message -lt $idx_current; and return
    
    # Color mapping for log levels
    set -l colors debug=cyan info=green warn=yellow error=red
    set -l color normal
    
    for pair in $colors
        set -l parts (string split = -- $pair)
        if test "$parts[1]" = "$level"
            set color $parts[2]
            break
        end
    end
    
    if __archivist__supports_color
        set_color $color
        echo "[$level] $msg" >&2
        set_color normal
    else
        echo "[$level] $msg" >&2
    end
end

# ============================================================================
# Command and Tool Management
# ============================================================================

function __archivist__require_cmds --description 'Verify required commands exist'
    set -l missing
    
    for cmd in $argv
        command -q $cmd; or set -a missing $cmd
    end
    
    if test (count $missing) -gt 0
        __archivist__log error "Missing required commands: "(string join ', ' $missing)
        __archivist__log info "Install them using: pacman -S "(string join ' ' $missing)
        return 1
    end
end

function __archivist__best_available --description 'Return first available command from list'
    for cmd in $argv
        if command -q $cmd
            echo $cmd
            return 0
        end
    end
    return 1
end

# ============================================================================
# Progress Display
# ============================================================================

function __archivist__can_progress --description 'Check if progress display is enabled'
    switch "$ARCHIVIST_PROGRESS"
        case never
            return 1
        case always
            command -q pv; and return 0
            return 1
        case auto '*'
            if isatty stdout; and command -q pv
                return 0
            end
            return 1
    end
end

function __archivist__spinner --description 'Display spinner animation for background process'
    set -l pid $argv[1]
    set -l msg $argv[2..-1]
    
    isatty stdout; or begin
        wait $pid
        return
    end
    
    set -l frames '⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏'
    set -l idx 1
    
    while kill -0 $pid 2>/dev/null
        printf '\r%s %s' (__archivist__colorize cyan "$msg") "$frames[$idx]"
        sleep 0.1
        set idx (math "($idx % "(count $frames)") + 1")
    end
    
    printf '\r%-60s\r' ' '  # Clear line
end

# ============================================================================
# Thread/Concurrency Management
# ============================================================================

function __archivist__resolve_threads --description 'Resolve thread count from arguments or defaults'
    set -l requested $argv[1]
    
    if test -n "$requested"; and test "$requested" -gt 0 2>/dev/null
        echo $requested
    else if test -n "$ARCHIVIST_DEFAULT_THREADS"
        echo $ARCHIVIST_DEFAULT_THREADS
    else
        nproc 2>/dev/null; or echo 4
    end
end

# ============================================================================
# Path and File Utilities
# ============================================================================

function __archivist__sanitize_path --description 'Expand and normalize file path'
    set -l path $argv[1]
    
    # Expand tilde
    if string match -qr '^~' -- $path
        set path (string replace -r '^~' $HOME -- $path)
    end
    
    # Make absolute if relative
    if not string match -q '/*' -- $path
        set path (pwd)"/$path"
    end
    
    # Normalize (remove .., . etc)
    realpath -m -- $path 2>/dev/null; or echo $path
end

function __archivist__ext --description 'Extract lowercase file extension(s)'
    set -l filename (basename -- $argv[1])
    
    # Handle double extensions like .tar.gz
    if string match -qr '\\.tar\\.(gz|bz2|xz|zst|lz|lz4|lzo|br)$' -- $filename
        string match -r '\\.tar\\.\\w+$' -- $filename | string sub --start 2 | string lower
    else if string match -qr '\\.(tgz|txz|tzst|tbz2?|tlz4?)$' -- $filename
        string match -r '\\.\\w+$' -- $filename | string sub --start 2 | string lower
    else
        string match -r '\\.\\w+$' -- $filename | string sub --start 2 | string lower
    end
end

function __archivist__mime --description 'Detect MIME type using file command'
    command -q file; or return 1
    file -b --mime-type -- $argv[1] 2>/dev/null
end

function __archivist__basename_noext --description 'Get filename without archive extensions'
    set -l filename (basename -- $argv[1])
    
    # Strip common archive extensions
    string replace -r '\\.tar\\.(gz|bz2|xz|zst|lz|lz4|lzo|br)$' '' -- $filename \
    | string replace -r '\\.(tgz|txz|tzst|tbz2?|tlz4?|zip|7z|rar|xz|gz|bz2|zst|lz4|lzo|br|iso)$' '' --
end

function __archivist__default_extract_dir --description 'Generate default extraction directory name'
    set -l archive $argv[1]
    __archivist__basename_noext $archive
end

# ============================================================================
# Archive Format Detection
# ============================================================================

function __archivist__detect_format --description 'Detect archive format from file'
    set -l file $argv[1]
    set -l ext (__archivist__ext $file)
    set -l mime (__archivist__mime $file)
    
    # First try extension
    switch $ext
        case 'tar.gz' tgz
            echo tar.gz
        case 'tar.bz2' tbz2 tbz
            echo tar.bz2
        case 'tar.xz' txz
            echo tar.xz
        case 'tar.zst' tzst
            echo tar.zst
        case 'tar.lz4' tlz4
            echo tar.lz4
        case 'tar.lz' tlz
            echo tar.lz
        case 'tar.lzo' tzo
            echo tar.lzo
        case 'tar.br' tbr
            echo tar.br
        case tar
            echo tar
        case zip
            echo zip
        case '7z' '7zip'
            echo 7z
        case rar
            echo rar
        case gz gzip
            echo gzip
        case bz2 bzip2
            echo bzip2
        case xz
            echo xz
        case zst zstd
            echo zstd
        case lz4
            echo lz4
        case lz lzip
            echo lzip
        case lzo
            echo lzo
        case br
            echo brotli
        case iso
            echo iso
        case deb
            echo deb
        case rpm
            echo rpm
        case dmg
            echo dmg
        case pkg
            echo pkg
        case apk
            echo apk
        case cab
            echo cab
        case '*'
            # Fall back to MIME type
            switch $mime
                case 'application/x-tar'
                    echo tar
                case 'application/gzip' 'application/x-gzip'
                    echo gzip
                case 'application/x-bzip2'
                    echo bzip2
                case 'application/x-xz'
                    echo xz
                case 'application/zstd'
                    echo zstd
                case 'application/x-lz4'
                    echo lz4
                case 'application/zip'
                    echo zip
                case 'application/x-7z-compressed'
                    echo 7z
                case 'application/x-rar' 'application/vnd.rar'
                    echo rar
                case 'application/x-iso9660-image'
                    echo iso
                case '*'
                    echo unknown
            end
    end
end

# ============================================================================
# Smart Format Selection for Compression
# ============================================================================

function __archivist__smart_format --description 'Choose optimal compression format based on input analysis'
    set -l inputs $argv
    
    # Counters for content analysis
    set -l total_files 0
    set -l text_files 0
    set -l total_size 0
    set -l compressible 0
    
    # Analyze input files
    for item in $inputs
        if test -d "$item"
            # For directories, sample some files
            set -l samples (find "$item" -type f -not -path '*/.*' 2>/dev/null | head -n 100)
            for file in $samples
                set total_files (math $total_files + 1)
                
                set -l size (stat -c %s "$file" 2>/dev/null; or echo 0)
                set total_size (math $total_size + $size)
                
                set -l mime (__archivist__mime "$file")
                if string match -qr '^text/' -- $mime; or string match -q '*json*' '*xml*' '*javascript*' '*script*' -- $mime
                    set text_files (math $text_files + 1)
                    set compressible (math $compressible + $size)
                end
            end
        else if test -f "$item"
            set total_files (math $total_files + 1)
            
            set -l size (stat -c %s "$item" 2>/dev/null; or echo 0)
            set total_size (math $total_size + $size)
            
            set -l mime (__archivist__mime "$item")
            if string match -qr '^text/' -- $mime; or string match -q '*json*' '*xml*' '*javascript*' '*script*' -- $mime
                set text_files (math $text_files + 1)
                set compressible (math $compressible + $size)
            end
        end
    end
    
    # Decision logic based on analysis
    if test $total_files -eq 0
        echo tar.zst  # Default
        return
    end
    
    # Calculate text ratio
    set -l text_ratio 0
    if test $total_files -gt 0
        set text_ratio (math -s0 "$text_files * 100 / $total_files")
    end
    
    # Calculate compressible size ratio
    set -l compress_ratio 0
    if test $total_size -gt 0
        set compress_ratio (math -s0 "$compressible * 100 / $total_size")
    end
    
    __archivist__log debug "Analysis: $total_files files, $text_ratio% text files, $compress_ratio% compressible by size"
    
    # Selection heuristics
    if test $text_ratio -ge 70; or test $compress_ratio -ge 70
        # High text content: use xz for maximum compression
        echo tar.xz
    else if test $text_ratio -ge 30; or test $compress_ratio -ge 40
        # Mixed content: use gzip for compatibility and decent compression
        echo tar.gz
    else
        # Binary/multimedia heavy: use zstd for speed and good compression
        echo tar.zst
    end
end

# ============================================================================
# Temporary Directory Management
# ============================================================================

function __archivist__mktemp_dir --description 'Create temporary directory'
    mktemp -d 2>/dev/null; or mktemp -d -t archivist.XXXXXX
end

# ============================================================================
# Archive Validation
# ============================================================================

function __archivist__validate_archive --description 'Perform basic validation on archive file'
    set -l file $argv[1]
    
    # Check existence
    if not test -e "$file"
        __archivist__log error "File not found: $file"
        return 1
    end
    
    # Check if readable
    if not test -r "$file"
        __archivist__log error "File not readable: $file"
        return 1
    end
    
    # Check if regular file
    if not test -f "$file"
        __archivist__log error "Not a regular file: $file"
        return 1
    end
    
    # Check if non-empty
    if not test -s "$file"
        __archivist__log error "File is empty: $file"
        return 1
    end
    
    return 0
end

# ============================================================================
# Compression Level Validation
# ============================================================================

function __archivist__validate_level --description 'Validate compression level for format'
    set -l format $argv[1]
    set -l level $argv[2]
    
    # Return default if not specified
    test -z "$level"; and echo 6; and return 0
    
    # Validate it's a number
    if not string match -qr '^\d+$' -- $level
        __archivist__log warn "Invalid compression level: $level, using default (6)"
        echo 6
        return 0
    end
    
    # Format-specific validation
    switch $format
        case gzip tar.gz
            # gzip: 1-9
            math "max(1, min(9, $level))"
        case bzip2 tar.bz2
            # bzip2: 1-9
            math "max(1, min(9, $level))"
        case xz tar.xz
            # xz: 0-9
            math "max(0, min(9, $level))"
        case zstd tar.zst
            # zstd: 1-19 (ultra), but common is 1-22
            math "max(1, min(19, $level))"
        case lz4 tar.lz4
            # lz4: 1-9 (fast), but supports up to 12
            math "max(1, min(12, $level))"
        case '7z'
            # 7z: 0-9
            math "max(0, min(9, $level))"
        case '*'
            # Default range
            math "max(1, min(9, $level))"
    end
end
