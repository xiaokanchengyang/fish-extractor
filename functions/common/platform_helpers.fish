# Platform detection and system utilities for Fish Archive Manager (fish 4.12+)
# Provides cross-platform compatibility for stat, nproc, and other system commands

# ============================================================================
# Platform Detection
# ============================================================================

function detect_platform --description 'Detect the current platform'
    set -l uname_s (uname -s 2>/dev/null)
    switch $uname_s
        case Linux
            echo "linux"
        case Darwin
            echo "macos"
        case CYGWIN* MINGW* MSYS*
            echo "windows"
        case '*'
            echo "unknown"
    end
end

function is_windows --description 'Check if running on Windows'
    test (detect_platform) = "windows"
end

function is_macos --description 'Check if running on macOS'
    test (detect_platform) = "macos"
end

function is_linux --description 'Check if running on Linux'
    test (detect_platform) = "linux"
end

# ============================================================================
# System Information
# ============================================================================

function _detect_cores --description 'Get number of CPU cores (cross-platform)'
    if is_macos
        sysctl -n hw.ncpu 2>/dev/null; or echo 4
    else if is_linux
        nproc 2>/dev/null; or echo 4
    else if is_windows
        # Windows: try wmic, fallback to environment variable
        wmic cpu get NumberOfCores /value 2>/dev/null | grep "NumberOfCores" | cut -d= -f2 2>/dev/null; or echo 4
    else
        echo 4
    end
end

function _stat_size --description 'Get file size in bytes (cross-platform)'
    set -l file $argv[1]
    
    if is_macos
        stat -f %z -- "$file" 2>/dev/null; or echo 0
    else if is_linux
        stat -c %s -- "$file" 2>/dev/null; or echo 0
    else if is_windows
        # Windows: use PowerShell or wmic
        powershell -Command "(Get-Item '$file').Length" 2>/dev/null; or echo 0
    else
        # Fallback: try both stat formats
        stat -c %s -- "$file" 2>/dev/null; or stat -f %z -- "$file" 2>/dev/null; or echo 0
    end
end

function _which_tool --description 'Find executable with platform-specific extensions'
    set -l tool $argv[1]
    
    # Try the tool directly first
    command -q $tool; and echo $tool; and return 0
    
    if is_windows
        # On Windows, try common extensions
        for ext in .exe .cmd .bat
            command -q "$tool$ext"; and echo "$tool$ext"; and return 0
        end
    end
    
    return 1
end

# ============================================================================
# Path Utilities
# ============================================================================

function _normalize_path --description 'Normalize path for current platform'
    set -l path $argv[1]
    
    if is_windows
        # Convert forward slashes to backslashes for Windows
        string replace -a '/' '\\' -- $path
    else
        # Use forward slashes for Unix-like systems
        string replace -a '\\' '/' -- $path
    end
end

function _path_separator --description 'Get path separator for current platform'
    if is_windows
        echo ';'
    else
        echo ':'
    end
end

# ============================================================================
# Command Execution
# ============================================================================

function _safe_exec --description 'Execute command with proper argument escaping'
    set -l cmd $argv[1]
    set -l args $argv[2..-1]
    
    # Build command array to avoid shell injection
    set -l cmd_array $cmd
    
    for arg in $args
        # Properly escape arguments
        set -a cmd_array -- "$arg"
    end
    
    # Execute the command
    $cmd_array
end

function _exec_with_fallback --description 'Execute command with fallback options'
    set -l primary $argv[1]
    set -l fallbacks $argv[2..-1]
    set -l args $argv[3..-1]
    
    # Try primary command first
    if _which_tool $primary
        _safe_exec $primary $args
        return $status
    end
    
    # Try fallback commands
    for fallback in $fallbacks
        if _which_tool $fallback
            _safe_exec $fallback $args
            return $status
        end
    end
    
    return 1
end

# ============================================================================
# Windows-Specific Utilities
# ============================================================================

function _detect_wsl --description 'Check if running in WSL'
    if is_windows
        test -f /proc/version; and grep -qi microsoft /proc/version 2>/dev/null
    else
        return 1
    end
end

function _get_windows_tools --description 'Get Windows-specific tool recommendations'
    set -l tools
    
    if is_windows
        # Check for 7-Zip
        if not _which_tool 7z
            set -a tools "7z (7-Zip)"
        end
        
        # Check for PowerShell
        if not _which_tool powershell
            set -a tools "PowerShell"
        end
        
        # Check for WSL
        if not _detect_wsl
            set -a tools "WSL (Windows Subsystem for Linux)"
        end
    end
    
    echo $tools
end

# ============================================================================
# Package Manager Detection
# ============================================================================

function _detect_package_manager --description 'Detect available package manager'
    if is_macos
        if has_command brew
            echo "brew"
        else if has_command port
            echo "port"
        else
            echo "unknown"
        end
    else if is_linux
        if has_command pacman
            echo "pacman"
        else if has_command apt-get
            echo "apt"
        else if has_command dnf
            echo "dnf"
        else if has_command yum
            echo "yum"
        else if has_command zypper
            echo "zypper"
        else
            echo "unknown"
        end
    else if is_windows
        if has_command choco
            echo "chocolatey"
        else if has_command winget
            echo "winget"
        else if has_command scoop
            echo "scoop"
        else
            echo "unknown"
        end
    else
        echo "unknown"
    end
end

function _get_install_command --description 'Get installation command for missing tools'
    set -l tools $argv
    set -l pkg_mgr (_detect_package_manager)
    
    switch $pkg_mgr
        case brew
            echo "brew install "(string join ' ' $tools)
        case pacman
            echo "pacman -S "(string join ' ' $tools)
        case apt
            echo "apt-get install "(string join ' ' $tools)
        case dnf
            echo "dnf install "(string join ' ' $tools)
        case yum
            echo "yum install "(string join ' ' $tools)
        case zypper
            echo "zypper install "(string join ' ' $tools)
        case chocolatey
            echo "choco install "(string join ' ' $tools)
        case winget
            echo "winget install "(string join ' ' $tools)
        case scoop
            echo "scoop install "(string join ' ' $tools)
        case '*'
            echo "Use your package manager to install: "(string join ' ' $tools)
    end
end

# ============================================================================
# Temporary File Management
# ============================================================================

function _create_temp_file --description 'Create temporary file with proper permissions'
    set -l prefix $argv[1]
    test -n "$prefix"; or set prefix "fish_archive"
    
    if is_windows
        # Windows: use PowerShell to create temp file
        set -l temp_file (powershell -Command "[System.IO.Path]::GetTempFileName()" 2>/dev/null)
        if test -n "$temp_file"
            echo $temp_file
        else
            # Fallback
            echo "/tmp/$prefix.$$.tmp"
        end
    else
        # Unix-like systems
        mktemp --tmpdir="$prefix.XXXXXX" 2>/dev/null; or echo "/tmp/$prefix.$$.tmp"
    end
end

function _create_temp_dir --description 'Create temporary directory with proper permissions'
    set -l prefix $argv[1]
    test -n "$prefix"; or set prefix "fish_archive"
    
    if is_windows
        # Windows: use PowerShell
        set -l temp_dir (powershell -Command "[System.IO.Path]::GetTempPath()" 2>/dev/null)
        if test -n "$temp_dir"
            set -l dir_name "$temp_dir$prefix.$$"
            mkdir -p "$dir_name" 2>/dev/null; and echo "$dir_name"
        else
            # Fallback
            echo "/tmp/$prefix.$$"
        end
    else
        # Unix-like systems
        mktemp -d --tmpdir="$prefix.XXXXXX" 2>/dev/null; or echo "/tmp/$prefix.$$"
    end
end

# ============================================================================
# Security Utilities
# ============================================================================

function _sanitize_filename --description 'Sanitize filename to prevent path traversal'
    set -l filename $argv[1]
    
    # Remove path traversal attempts
    string replace -a '../' '' -- $filename \
    | string replace -a '..\\' '' -- \
    | string replace -a '..' '' -- \
    | string replace -a '/' '_' -- \
    | string replace -a '\\' '_' -- \
    | string replace -a ' ' '_' --
end

function _validate_path --description 'Validate path for security'
    set -l path $argv[1]
    
    # Check for path traversal
    if string match -q '*../*' -- $path; or string match -q '*..\\*' -- $path
        return 1
    end
    
    # Check for absolute paths in dangerous locations
    if string match -q '/etc/*' -- $path; or string match -q '/sys/*' -- $path; or string match -q '/proc/*' -- $path
        return 1
    end
    
    return 0
end