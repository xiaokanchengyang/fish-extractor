# Test Integration

source functions/compress.fish
source functions/extract.fish
source functions/check.fish

# 1. Check
if not check -q
    echo "✗ Integration: Check failed"
    exit 1
end

# 2. Compress
mkdir -p int_test_in
echo hello >int_test_in/hello.txt
if not compress -q int_test.tar.gz int_test_in/
    echo "✗ Integration: Compress failed"
    exit 1
end

# 3. Extract
if not extract -q -d int_test_out int_test.tar.gz
    echo "✗ Integration: Extract failed"
    exit 1
end

if test -f int_test_out/int_test_in/hello.txt
    echo "✓ Integration success"
else
    echo "✗ Integration: File missing after extract"
    exit 1
end

# Cleanup
rm -rf int_test_in int_test_out int_test.tar.gz

exit 0
