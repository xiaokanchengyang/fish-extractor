# Archivist plugin initialization for fish
# Loads default configuration and exports variables.

# Only initialize once per session
if set -q __archivist_initialized
    return
end
set -g __archivist_initialized 1

# Default config (can be overridden by ~/.config/fish/conf.d/archivist.fish or env)
set -q ARCHIVIST_DEFAULT_THREADS; or set -gx ARCHIVIST_DEFAULT_THREADS (math (nproc 2>/dev/null; or echo 4))
set -q ARCHIVIST_COLOR; or set -gx ARCHIVIST_COLOR auto
set -q ARCHIVIST_PROGRESS; or set -gx ARCHIVIST_PROGRESS auto
set -q ARCHIVIST_SMART_LEVEL; or set -gx ARCHIVIST_SMART_LEVEL 2
set -q ARCHIVIST_DEFAULT_FORMAT; or set -gx ARCHIVIST_DEFAULT_FORMAT auto
set -q ARCHIVIST_PARANOID; or set -gx ARCHIVIST_PARANOID 0
set -q ARCHIVIST_LOG_LEVEL; or set -gx ARCHIVIST_LOG_LEVEL info

# Expose main entrypoints
functions -q archx; or functions -c __archivist_extract archx
functions -q archc; or functions -c __archivist_compress archc
functions -q archdoctor; or functions -c __archivist_doctor archdoctor
