# Test Platform Helpers

source functions/common/platform_helpers.fish

set platform (detect_platform)
if test -n "$platform"
    echo "✓ Platform detected: $platform"
else
    echo "✗ Platform detection failed"
    exit 1
end

exit 0
