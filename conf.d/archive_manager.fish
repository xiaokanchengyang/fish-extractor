# Fish Archive Manager - Configuration and Initialization (fish 4.12+)
# Optimized configuration with modern Fish features

# ============================================================================
# Initialization Guard
# ============================================================================

if set -q __fish_archive_manager_initialized
    return
end

set -g __fish_archive_manager_initialized 1

# ============================================================================
# Default Configuration with Modern Fish Features
# ============================================================================

# Color output: auto (default), always, never
if not set -q FISH_ARCHIVE_COLOR
    set -gx FISH_ARCHIVE_COLOR auto
end

# Progress indicators: auto (default), always, never
if not set -q FISH_ARCHIVE_PROGRESS
    set -gx FISH_ARCHIVE_PROGRESS auto
end

# Default thread count (auto-detected)
if not set -q FISH_ARCHIVE_DEFAULT_THREADS
    set -gx FISH_ARCHIVE_DEFAULT_THREADS (nproc 2>/dev/null; or sysctl -n hw.ncpu 2>/dev/null; or echo 4)
end

# Logging level: debug, info (default), warn, error
if not set -q FISH_ARCHIVE_LOG_LEVEL
    set -gx FISH_ARCHIVE_LOG_LEVEL info
end

# Default format for smart selection
if not set -q FISH_ARCHIVE_DEFAULT_FORMAT
    set -gx FISH_ARCHIVE_DEFAULT_FORMAT auto
end

# ============================================================================
# Command Aliases and Wrappers
# ============================================================================

# Main commands
function extract --description 'Extract archives with intelligent format detection'
    source (dirname (status --current-filename))/../functions/archive_manager.fish
    extract $argv
end

function compress --description 'Create archives with intelligent format selection'
    source (dirname (status --current-filename))/../functions/archive_manager.fish
    compress $argv
end

function doctor --description 'Diagnose system capabilities and configuration'
    source (dirname (status --current-filename))/../functions/archive_manager.fish
    doctor $argv
end

# Backward compatibility aliases
function extractor --description 'Alias for extract command'
    extract $argv
end

function compressor --description 'Alias for compress command'
    compress $argv
end

# ============================================================================
# Optional Short Aliases (commented out by default)
# ============================================================================

# Uncomment these lines to enable short aliases
# function x --description 'Short alias for extract'
#     extract $argv
# end

# function c --description 'Short alias for compress'
#     compress $argv
# end

# ============================================================================
# Performance Optimization
# ============================================================================

# Check for Fish 4.12+ features
if not string match -q '4.1[2-9]*' (fish --version | string match -r '\d+\.\d+')
    echo "Warning: Fish Archive Manager works best with Fish 4.12+" >&2
end

# ============================================================================
# Startup Message (optional)
# ============================================================================

# Uncomment to show startup message
# echo "Fish Archive Manager loaded. Use 'extract', 'compress', or 'doctor' commands."