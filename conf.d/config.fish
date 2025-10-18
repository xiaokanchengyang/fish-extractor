# Fish Archive Manager plugin initialization for fish shell (fish 4.12+)
# Sets up default configuration and creates command aliases

# Prevent double initialization
if set -q __fish_archive_initialized
    return
end
set -g __fish_archive_initialized 1

# ============================================================================
# Default Configuration
# ============================================================================

# Color output control: auto (default), always, never
set -q FISH_ARCHIVE_COLOR
or set -gx FISH_ARCHIVE_COLOR auto

# Progress indicator control: auto (default), always, never
set -q FISH_ARCHIVE_PROGRESS
or set -gx FISH_ARCHIVE_PROGRESS auto

# Default thread count for parallel operations
set -q FISH_ARCHIVE_DEFAULT_THREADS
or set -gx FISH_ARCHIVE_DEFAULT_THREADS (nproc 2>/dev/null; or sysctl -n hw.ncpu 2>/dev/null; or echo 4)

# Logging level: debug, info (default), warn, error
set -q FISH_ARCHIVE_LOG_LEVEL
or set -gx FISH_ARCHIVE_LOG_LEVEL info

# Default archive format when auto-selecting
set -q FISH_ARCHIVE_DEFAULT_FORMAT
or set -gx FISH_ARCHIVE_DEFAULT_FORMAT auto

# ============================================================================
# Create Command Aliases
# ============================================================================

# Main extraction command (primary aliases)
if not functions -q extract
    function extract --wraps=extract --description 'Extract archives intelligently'
        extract $argv
    end
end

if not functions -q extractor
    function extractor --wraps=extract --description 'Extract archives intelligently (alias)'
        extract $argv
    end
end

# Main compression command (primary aliases)
if not functions -q compress
    function compress --wraps=compress --description 'Create archives intelligently'
        compress $argv
    end
end

if not functions -q compressor
    function compressor --wraps=compress --description 'Create archives intelligently (alias)'
        compress $argv
    end
end

# Diagnostic command
if not functions -q doctor
    function doctor --wraps=doctor --description 'Check archive tool environment'
        doctor $argv
    end
end

# ============================================================================
# Optional: Convenience Aliases
# ============================================================================

# Short aliases for quick access (uncomment if desired)
# function x --wraps=extract
#     extract $argv
# end
#
# function c --wraps=compress
#     compress $argv
# end

# ============================================================================
# Backwards Compatibility (optional)
# ============================================================================

# Uncomment to provide backwards compatibility with old command names
# function archx --wraps=extract
#     extract $argv
# end
#
# function archc --wraps=compress
#     compress $argv
# end
#
# function archdoctor --wraps=doctor
#     doctor $argv
# end

# ============================================================================
# Startup Messages (Optional)
# ============================================================================

# Uncomment to check environment on shell startup (useful for debugging)
# if not set -q __fish_archive_doctor_run
#     set -g __fish_archive_doctor_run 1
#     if not has_command tar; or not has_command gzip
#         echo "⚠️  Fish Archive Manager: Missing required tools. Run 'doctor' for details." >&2
#     end
# end