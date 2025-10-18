# Example Archivist Configuration
# Copy relevant settings to your ~/.config/fish/config.fish or conf.d/archivist_user.fish

# ============================================================================
# Display and Output Settings
# ============================================================================

# Color output control
# Values: auto (default), always, never
# auto: colors only when output is to a terminal
set -gx ARCHIVIST_COLOR auto

# Progress indicator control
# Values: auto (default), always, never
# auto: shows progress only when pv is available and output is to a terminal
set -gx ARCHIVIST_PROGRESS auto

# Logging level
# Values: debug, info (default), warn, error
# debug: show all messages including internal operations
# info: show normal operational messages
# warn: show only warnings and errors
# error: show only errors
set -gx ARCHIVIST_LOG_LEVEL info

# ============================================================================
# Performance Settings
# ============================================================================

# Default number of threads for parallel operations
# Set to number of CPU cores for best performance
# Use fewer threads if running on a shared system
set -gx ARCHIVIST_DEFAULT_THREADS (nproc 2>/dev/null; or echo 4)

# Alternative: Set a specific number
# set -gx ARCHIVIST_DEFAULT_THREADS 8

# ============================================================================
# Compression Settings
# ============================================================================

# Default format for auto-selection
# Values: auto (default), tar.gz, tar.xz, tar.zst, tar.bz2, zip, 7z, etc.
# auto: uses smart format selection based on content
set -gx ARCHIVIST_DEFAULT_FORMAT auto

# Smart selection heuristic strength
# Values: 1 (permissive), 2 (default - balanced), 3 (aggressive)
# 1: prefers tar.gz for compatibility
# 2: balanced between compression and speed
# 3: prefers maximum compression (tar.xz) more often
set -gx ARCHIVIST_SMART_LEVEL 2

# ============================================================================
# Safety Settings
# ============================================================================

# Paranoid mode - additional safety checks
# Values: 0 (off, default), 1 (on)
# When enabled, performs extra validation before operations
set -gx ARCHIVIST_PARANOID 0

# ============================================================================
# Custom Aliases (Optional)
# ============================================================================

# Shorter aliases if you prefer
# alias x='archx'
# alias c='archc'

# Common operation shortcuts
# alias extract='archx'
# alias compress='archc'
# alias unpack='archx'
# alias pack='archc'

# Format-specific aliases
# alias tarx='archc -F tar.xz'      # Always use tar.xz
# alias tarz='archc -F tar.zst'     # Always use tar.zst
# alias zipx='archc -F zip'         # Always use zip

# ============================================================================
# Common Patterns
# ============================================================================

# Backup function
# function backup --description 'Create dated backup archive'
#     set -l date (date +%Y%m%d)
#     set -l name (basename $argv[1])
#     archc -F tar.zst "$name-$date.tzst" $argv[1]
# end

# Extract and cd into directory
# function extract-cd --description 'Extract archive and cd into it'
#     set -l dir (__archivist__default_extract_dir $argv[1])
#     archx $argv
#     and cd $dir
# end

# Quick compression with optimal settings
# function quick-compress --description 'Fast compression'
#     archc -F tar.lz4 -L 1 $argv
# end

# function best-compress --description 'Maximum compression'
#     archc -F tar.xz -L 9 $argv
# end

# ============================================================================
# Platform-Specific Settings
# ============================================================================

# macOS specific (if applicable)
# if test (uname) = Darwin
#     set -gx ARCHIVIST_DEFAULT_THREADS (sysctl -n hw.ncpu)
# end

# High-performance system (adjust threads for your system)
# set -l cpu_cores (nproc)
# if test $cpu_cores -ge 16
#     set -gx ARCHIVIST_DEFAULT_THREADS (math "$cpu_cores - 2")  # Leave 2 cores free
# end

# ============================================================================
# Development/Debug Settings
# ============================================================================

# Uncomment for verbose debugging
# set -gx ARCHIVIST_LOG_LEVEL debug
# set -gx ARCHIVIST_COLOR always
# set -gx ARCHIVIST_PROGRESS never  # Disable for cleaner debug output

# ============================================================================
# Integration Examples
# ============================================================================

# Auto-backup before important operations
# function git-archive --description 'Create archive of git repo'
#     set -l branch (git branch --show-current)
#     set -l date (date +%Y%m%d)
#     archc -x '.git/*' -x 'node_modules/*' -F tar.xz \
#         (basename (pwd))-$branch-$date.txz .
# end

# Web assets compression
# function web-compress --description 'Compress web assets with brotli'
#     archc -F tar.br -x '*.tmp' -x '*.log' $argv
# end

# Log archive rotation
# function rotate-logs --description 'Compress and rotate logs'
#     set -l date (date +%Y%m%d)
#     archc -F tar.xz -L 9 logs-$date.txz /var/log
# end
