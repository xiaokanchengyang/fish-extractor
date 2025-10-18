# Archivist plugin initialization for fish shell (fish 4.12+)
# Sets up default configuration and creates command aliases

# Prevent double initialization
if set -q __archivist_initialized
    return
end
set -g __archivist_initialized 1

# ============================================================================
# Default Configuration
# ============================================================================

# Color output control: auto (default), always, never
set -q ARCHIVIST_COLOR
or set -gx ARCHIVIST_COLOR auto

# Progress indicator control: auto (default), always, never
set -q ARCHIVIST_PROGRESS
or set -gx ARCHIVIST_PROGRESS auto

# Default thread count for parallel operations
set -q ARCHIVIST_DEFAULT_THREADS
or set -gx ARCHIVIST_DEFAULT_THREADS (nproc 2>/dev/null; or sysctl -n hw.ncpu 2>/dev/null; or echo 4)

# Logging level: debug, info (default), warn, error
set -q ARCHIVIST_LOG_LEVEL
or set -gx ARCHIVIST_LOG_LEVEL info

# Default archive format when auto-selecting
set -q ARCHIVIST_DEFAULT_FORMAT
or set -gx ARCHIVIST_DEFAULT_FORMAT auto

# Smart format selection heuristic strength (1-3, default 2)
set -q ARCHIVIST_SMART_LEVEL
or set -gx ARCHIVIST_SMART_LEVEL 2

# Paranoid mode: additional safety checks (0=off, 1=on)
set -q ARCHIVIST_PARANOID
or set -gx ARCHIVIST_PARANOID 0

# ============================================================================
# Create Command Aliases
# ============================================================================

# Main extraction command
if not functions -q archx
    function archx --wraps=__archivist_extract --description 'Extract archives intelligently'
        __archivist_extract $argv
    end
end

# Main compression command
if not functions -q archc
    function archc --wraps=__archivist_compress --description 'Create archives intelligently'
        __archivist_compress $argv
    end
end

# Diagnostic command
if not functions -q archdoctor
    function archdoctor --wraps=__archivist_doctor --description 'Check archive tool environment'
        __archivist_doctor $argv
    end
end

# ============================================================================
# Optional: User-Friendly Aliases
# ============================================================================

# Uncomment these if you prefer more explicit names:
# function extract --wraps=archx
#     archx $argv
# end
# 
# function compress --wraps=archc
#     archc $argv
# end

# ============================================================================
# Startup Check (Optional)
# ============================================================================

# Uncomment to check environment on shell startup:
# if not set -q __archivist_doctor_run
#     set -g __archivist_doctor_run 1
#     if not command -q tar; or not command -q gzip
#         echo "⚠️  Archivist: Missing required tools. Run 'archdoctor' for details." >&2
#     end
# end
