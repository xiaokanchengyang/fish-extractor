#!/usr/bin/env fish
# Integration tests for Fish Archive Manager

source (dirname (status --current-filename))/../fish_archive.fish

echo "Running integration tests..."

# Create test directory
set -l test_dir (mktemp -d)
cd $test_dir

echo "Test directory: $test_dir"

# Create test files
echo "Creating test files..."
mkdir -p test_data/subdir
echo "Hello, World!" > test_data/hello.txt
echo "This is a test file" > test_data/subdir/test.txt
echo "Binary content" > test_data/binary.bin
dd if=/dev/zero of=test_data/large.bin bs=1M count=1 2>/dev/null

echo "Test files created:"
find test_data -type f -exec ls -lh {} \;

# Test 1: Basic compression and extraction
echo ""
echo "Test 1: Basic compression and extraction"
compress test.tar.gz test_data/
if test $status -eq 0
    echo "✓ Compression successful"
else
    echo "✗ Compression failed"
    exit 1
end

# Extract and verify
extract test.tar.gz
if test $status -eq 0
    echo "✓ Extraction successful"
else
    echo "✗ Extraction failed"
    exit 1
end

# Verify content
if test -f test_data/hello.txt; and test -f test_data/subdir/test.txt
    echo "✓ Content verification successful"
else
    echo "✗ Content verification failed"
    exit 1
end

# Test 2: Different compression formats
echo ""
echo "Test 2: Different compression formats"

# Test tar.zst
compress test.tar.zst test_data/
if test $status -eq 0; and test -f test.tar.zst
    echo "✓ tar.zst compression successful"
else
    echo "✗ tar.zst compression failed"
    exit 1
end

# Test zip
compress test.zip test_data/
if test $status -eq 0; and test -f test.zip
    echo "✓ zip compression successful"
else
    echo "✗ zip compression failed"
    exit 1
end

# Test 3: Smart compression
echo ""
echo "Test 3: Smart compression"
compress --smart smart.auto test_data/
if test $status -eq 0; and test -f smart.auto
    echo "✓ Smart compression successful"
else
    echo "✗ Smart compression failed"
    exit 1
end

# Test 4: Archive listing
echo ""
echo "Test 4: Archive listing"
extract --list test.tar.gz > /dev/null
if test $status -eq 0
    echo "✓ Archive listing successful"
else
    echo "✗ Archive listing failed"
    exit 1
end

# Test 5: Archive testing
echo ""
echo "Test 5: Archive testing"
extract --test test.tar.gz
if test $status -eq 0
    echo "✓ Archive testing successful"
else
    echo "✗ Archive testing failed"
    exit 1
end

# Test 6: Multi-threaded compression
echo ""
echo "Test 6: Multi-threaded compression"
compress -t 2 threaded.tar.gz test_data/
if test $status -eq 0; and test -f threaded.tar.gz
    echo "✓ Multi-threaded compression successful"
else
    echo "✗ Multi-threaded compression failed"
    exit 1
end

# Test 7: Pattern filtering
echo ""
echo "Test 7: Pattern filtering"
compress -x "*.bin" filtered.tar.gz test_data/
if test $status -eq 0; and test -f filtered.tar.gz
    echo "✓ Pattern filtering successful"
else
    echo "✗ Pattern filtering failed"
    exit 1
end

# Test 8: Dry run
echo ""
echo "Test 8: Dry run"
compress --dry-run dry.tar.gz test_data/ > /dev/null
if test $status -eq 0; and not test -f dry.tar.gz
    echo "✓ Dry run successful"
else
    echo "✗ Dry run failed"
    exit 1
end

# Test 9: Doctor command
echo ""
echo "Test 9: Doctor command"
doctor -q > /dev/null
if test $status -eq 0
    echo "✓ Doctor command successful"
else
    echo "✗ Doctor command failed"
    exit 1
end

# Test 10: Task queue
echo ""
echo "Test 10: Task queue"
# Create test files for queue
mkdir -p queue_test
echo "queue test" > queue_test/file.txt

# Test sequential queue
archqueue --sequential 'compress::queue_out.tar.gz::queue_test/' > /dev/null
if test $status -eq 0; and test -f queue_out.tar.gz
    echo "✓ Sequential queue successful"
else
    echo "✗ Sequential queue failed"
    exit 1
end

# Test parallel queue
archqueue --parallel 2 'compress::queue_par1.tar.gz::queue_test/' 'compress::queue_par2.tar.gz::queue_test/' > /dev/null
if test $status -eq 0; and test -f queue_par1.tar.gz; and test -f queue_par2.tar.gz
    echo "✓ Parallel queue successful"
else
    echo "✗ Parallel queue failed"
    exit 1
end

# Test 11: Error handling
echo ""
echo "Test 11: Error handling"

# Test with non-existent file
compress error.tar.gz /nonexistent/file 2>/dev/null
if test $status -ne 0
    echo "✓ Error handling for non-existent file successful"
else
    echo "✗ Error handling for non-existent file failed"
    exit 1
end

# Test with invalid format
compress -F invalid_format error.tar.gz test_data/ 2>/dev/null
if test $status -ne 0
    echo "✓ Error handling for invalid format successful"
else
    echo "✗ Error handling for invalid format failed"
    exit 1
end

# Test 12: Progress indicators
echo ""
echo "Test 12: Progress indicators"
# This test might not show progress if pv is not available, but should not fail
compress -v progress.tar.gz test_data/ > /dev/null 2>&1
if test $status -eq 0
    echo "✓ Progress indicators test successful"
else
    echo "✗ Progress indicators test failed"
    exit 1
end

# Cleanup
echo ""
echo "Cleaning up..."
cd /
rm -rf $test_dir

echo "✅ All integration tests passed!"