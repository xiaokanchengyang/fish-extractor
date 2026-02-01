# Test Check/Doctor

source functions/check.fish

if check --help >/dev/null
    echo "✓ check --help"
else
    echo "✗ check --help failed"
    exit 1
end

# We can't easily test output without mocking, but we can ensure it runs
if check -q
    echo "✓ check runs"
else
    echo "✗ check failed"
    exit 1
end

exit 0
