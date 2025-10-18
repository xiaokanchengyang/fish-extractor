# Fish Extractor plugin initialization for fish shell (fish 4.12+)
# Sets up default configuration and creates command aliases

# Prevent double initialization
if set -q __fish_extractor_initialized
    return
end
set -g __fish_extractor_initialized 1

# ============================================================================
# Default Configuration
# ============================================================================

# Color output control: auto (default), always, never
set -q FISH_EXTRACTOR_COLOR
or set -gx FISH_EXTRACTOR_COLOR auto

# Progress indicator control: auto (default), always, never
set -q FISH_EXTRACTOR_PROGRESS
or set -gx FISH_EXTRACTOR_PROGRESS auto

# Default thread count for parallel operations
set -q FISH_EXTRACTOR_DEFAULT_THREADS
or set -gx FISH_EXTRACTOR_DEFAULT_THREADS (nproc 2>/dev/null; or sysctl -n hw.ncpu 2>/dev/null; or echo 4)

# Logging level: debug, info (default), warn, error
set -q FISH_EXTRACTOR_LOG_LEVEL
or set -gx FISH_EXTRACTOR_LOG_LEVEL info

# Default archive format when auto-selecting
set -q FISH_EXTRACTOR_DEFAULT_FORMAT
or set -gx FISH_EXTRACTOR_DEFAULT_FORMAT auto

# ============================================================================
# Create Command Aliases
# ============================================================================

# Main extraction command (primary aliases)
if not functions -q extract
    function extract --wraps=__fish_extractor_extract --description 'Extract archives intelligently'
        __fish_extractor_extract $argv
    end
end

if not functions -q extractor
    function extractor --wraps=__fish_extractor_extract --description 'Extract archives intelligently (alias)'
        __fish_extractor_extract $argv
    end
end

# Main compression command (primary aliases)
if not functions -q compress
    function compress --wraps=__fish_extractor_compress --description 'Create archives intelligently'
        __fish_extractor_compress $argv
    end
end

if not functions -q compressor
    function compressor --wraps=__fish_extractor_compress --description 'Create archives intelligently (alias)'
        __fish_extractor_compress $argv
    end
end

# Diagnostic command
if not functions -q ext-doctor
    function ext-doctor --wraps=__fish_extractor_doctor --description 'Check archive tool environment'
        __fish_extractor_doctor $argv
    end
end

# ============================================================================
# Optional: Convenience Aliases
# ============================================================================

# Short aliases for quick access (uncomment if desired)
# function x --wraps=extractor
#     extractor $argv
# end
#
# function c --wraps=compressor
#     compressor $argv
# end

# ============================================================================
# Backwards Compatibility (optional)
# ============================================================================

# Uncomment to provide backwards compatibility with old command names
# function archx --wraps=extractor
#     extractor $argv
# end
#
# function archc --wraps=compressor
#     compressor $argv
# end
#
# function archdoctor --wraps=ext-doctor
#     ext-doctor $argv
# end

# ============================================================================
# Startup Messages (Optional)
# ============================================================================

# Uncomment to check environment on shell startup (useful for debugging)
# if not set -q __fish_extractor_doctor_run
#     set -g __fish_extractor_doctor_run 1
#     if not command -q tar; or not command -q gzip
#         echo "⚠️  Fish Extractor: Missing required tools. Run 'ext-doctor' for details." >&2
#     end
# end
