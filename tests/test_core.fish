# Test Core Functions

source functions/core.fish
source functions/core_optimized.fish

# Test supports_color (mocking tty)
set -x FISH_ARCHIVE_COLOR always
if supports_color
    echo "✓ supports_color (always)"
else
    echo "✗ supports_color (always)"
    exit 1
end

set -x FISH_ARCHIVE_COLOR never
if not supports_color
    echo "✓ supports_color (never)"
else
    echo "✗ supports_color (never)"
    exit 1
end

# Test log
set -x FISH_ARCHIVE_LOG_LEVEL info
# Capture stderr
set output (log info "test message" 2>&1)
if string match -q "*test message*" -- $output
    echo "✓ log output"
else
    echo "✗ log output"
    exit 1
end

exit 0
