# Test Archqueue

# Source the tool directly
source functions/archqueue.fish
# We need compress/extract too
source functions/compress.fish
source functions/extract.fish

# Create dummy files
mkdir -p test_queue_in
echo "data1" > test_queue_in/file1
echo "data2" > test_queue_in/file2
mkdir -p test_queue_out

# Test 1: Sequential Execution
echo "Testing Sequential Queue..."
if archqueue --sequential --stop-on-error \
    "compress::test_queue_out/1.tar.gz::test_queue_in/file1" \
    "compress::test_queue_out/2.tar.gz::test_queue_in/file2"
    
    if test -f test_queue_out/1.tar.gz; and test -f test_queue_out/2.tar.gz
        echo "✓ Sequential queue execution successful"
    else
        echo "✗ Sequential queue missing output files"
        ls -R test_queue_out
        exit 1
    end
else
    echo "✗ Sequential queue command failed"
    exit 1
end

# Cleanup outputs
rm -f test_queue_out/*.tar.gz

# Test 2: Parallel Execution
echo "Testing Parallel Queue..."
if archqueue --parallel 2 \
    "compress::test_queue_out/p1.tar.gz::test_queue_in/file1" \
    "compress::test_queue_out/p2.tar.gz::test_queue_in/file2"

    if test -f test_queue_out/p1.tar.gz; and test -f test_queue_out/p2.tar.gz
        echo "✓ Parallel queue execution successful"
    else
        echo "✗ Parallel queue missing output files"
        ls -R test_queue_out
        exit 1
    end
else
    echo "✗ Parallel queue command failed"
    exit 1
end

# Cleanup
rm -rf test_queue_in test_queue_out

exit 0
