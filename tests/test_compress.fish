# Test Compress

source functions/compress.fish

# Create a dummy file
echo "test data" > test_file.txt

# Test compression
if compress -q test_file.tar.gz test_file.txt
    if test -f test_file.tar.gz
        echo "✓ compress tar.gz created"
    else
        echo "✗ compress tar.gz failed creation"
        exit 1
    end
else
    echo "✗ compress command failed"
    exit 1
end

# Cleanup
rm test_file.txt test_file.tar.gz

exit 0
