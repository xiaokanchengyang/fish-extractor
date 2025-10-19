# Test suite for Fish Archive Manager compress functionality
# Run with: fish tests/test_compress.fish

set -l test_dir (mktemp -d)
set -l original_pwd (pwd)

function test_compress_help
    echo "Testing compress help..."
    
    set -l result (compress --help 2>&1)
    if string match -q "*Usage:*" -- $result
        echo "✓ Compress help works"
    else
        echo "✗ Compress help failed"
        return 1
    end
end

function test_compress_dry_run
    echo "Testing compress dry run..."
    
    # Create test files
    cd "$test_dir"
    echo "test content" > test_file.txt
    mkdir -p test_dir
    echo "nested content" > test_dir/nested_file.txt
    
    set -l result (compress --dry-run test.tar.gz test_file.txt test_dir 2>&1)
    if string match -q "*DRY-RUN*" -- $result
        echo "✓ Compress dry run works"
    else
        echo "✗ Compress dry run failed"
        return 1
    end
    
    cd $original_pwd
end

function test_compress_tar_gz
    echo "Testing compress tar.gz..."
    
    # Create test files
    cd "$test_dir"
    echo "test content" > test_file.txt
    mkdir -p test_dir
    echo "nested content" > test_dir/nested_file.txt
    
    # Compress
    if compress test.tar.gz test_file.txt test_dir
        if test -f "test.tar.gz"
            echo "✓ Compress tar.gz works"
        else
            echo "✗ Compress tar.gz failed - archive not created"
            return 1
        end
    else
        echo "✗ Compress tar.gz failed"
        return 1
    end
    
    cd $original_pwd
end

function test_compress_tar_xz
    echo "Testing compress tar.xz..."
    
    if not has_command xz
        echo "⚠ XZ not available, skipping test"
        return 0
    end
    
    # Create test files
    cd "$test_dir"
    echo "test content" > test_file.txt
    
    # Compress
    if compress -F tar.xz test.tar.xz test_file.txt
        if test -f "test.tar.xz"
            echo "✓ Compress tar.xz works"
        else
            echo "✗ Compress tar.xz failed - archive not created"
            return 1
        end
    else
        echo "✗ Compress tar.xz failed"
        return 1
    end
    
    cd $original_pwd
end

function test_compress_tar_zst
    echo "Testing compress tar.zst..."
    
    if not has_command zstd
        echo "⚠ Zstd not available, skipping test"
        return 0
    end
    
    # Create test files
    cd "$test_dir"
    echo "test content" > test_file.txt
    
    # Compress
    if compress -F tar.zst test.tar.zst test_file.txt
        if test -f "test.tar.zst"
            echo "✓ Compress tar.zst works"
        else
            echo "✗ Compress tar.zst failed - archive not created"
            return 1
        end
    else
        echo "✗ Compress tar.zst failed"
        return 1
    end
    
    cd $original_pwd
end

function test_compress_zip
    echo "Testing compress ZIP..."
    
    if not has_command zip
        echo "⚠ ZIP not available, skipping test"
        return 0
    end
    
    # Create test files
    cd "$test_dir"
    echo "test content" > test_file.txt
    mkdir -p test_dir
    echo "nested content" > test_dir/nested_file.txt
    
    # Compress
    if compress test.zip test_file.txt test_dir
        if test -f "test.zip"
            echo "✓ Compress ZIP works"
        else
            echo "✗ Compress ZIP failed - archive not created"
            return 1
        end
    else
        echo "✗ Compress ZIP failed"
        return 1
    end
    
    cd $original_pwd
end

function test_compress_7z
    echo "Testing compress 7z..."
    
    if not has_command 7z
        echo "⚠ 7z not available, skipping test"
        return 0
    end
    
    # Create test files
    cd "$test_dir"
    echo "test content" > test_file.txt
    mkdir -p test_dir
    echo "nested content" > test_dir/nested_file.txt
    
    # Compress
    if compress -F 7z test.7z test_file.txt test_dir
        if test -f "test.7z"
            echo "✓ Compress 7z works"
        else
            echo "✗ Compress 7z failed - archive not created"
            return 1
        end
    else
        echo "✗ Compress 7z failed"
        return 1
    end
    
    cd $original_pwd
end

function test_compress_smart
    echo "Testing compress smart format..."
    
    # Create test files
    cd "$test_dir"
    echo "test content" > test_file.txt
    mkdir -p test_dir
    echo "nested content" > test_dir/nested_file.txt
    
    # Compress with smart format
    if compress --smart test.auto test_file.txt test_dir
        if test -f "test.auto.tar.gz" -o -f "test.auto.tar.xz" -o -f "test.auto.tar.zst"
            echo "✓ Compress smart format works"
        else
            echo "✗ Compress smart format failed - archive not created"
            return 1
        end
    else
        echo "✗ Compress smart format failed"
        return 1
    end
    
    cd $original_pwd
end

function test_compress_exclude
    echo "Testing compress with exclusions..."
    
    # Create test files
    cd "$test_dir"
    echo "test content" > test_file.txt
    echo "temp content" > test_file.tmp
    echo "log content" > test_file.log
    
    # Compress with exclusions
    if compress -x '*.tmp' -x '*.log' test.tar.gz test_file.txt test_file.tmp test_file.log
        if test -f "test.tar.gz"
            echo "✓ Compress with exclusions works"
        else
            echo "✗ Compress with exclusions failed - archive not created"
            return 1
        end
    else
        echo "✗ Compress with exclusions failed"
        return 1
    end
    
    cd $original_pwd
end

function test_compress_include
    echo "Testing compress with inclusions..."
    
    # Create test files
    cd "$test_dir"
    echo "test content" > test_file.txt
    echo "temp content" > test_file.tmp
    echo "log content" > test_file.log
    
    # Compress with inclusions
    if compress -i '*.txt' test.tar.gz test_file.txt test_file.tmp test_file.log
        if test -f "test.tar.gz"
            echo "✓ Compress with inclusions works"
        else
            echo "✗ Compress with inclusions failed - archive not created"
            return 1
        end
    else
        echo "✗ Compress with inclusions failed"
        return 1
    end
    
    cd $original_pwd
end

function test_compress_checksum
    echo "Testing compress with checksum..."
    
    # Create test files
    cd "$test_dir"
    echo "test content" > test_file.txt
    
    # Compress with checksum
    if compress --checksum test.tar.gz test_file.txt
        if test -f "test.tar.gz" -a -f "test.tar.gz.sha256"
            echo "✓ Compress with checksum works"
        else
            echo "✗ Compress with checksum failed - archive or checksum not created"
            return 1
        end
    else
        echo "✗ Compress with checksum failed"
        return 1
    end
    
    cd $original_pwd
end

function test_compress_auto_rename
    echo "Testing compress auto-rename..."
    
    # Create test files
    cd "$test_dir"
    echo "test content" > test_file.txt
    
    # Compress first time
    compress test.tar.gz test_file.txt
    
    # Compress second time with auto-rename
    if compress --auto-rename test.tar.gz test_file.txt
        if test -f "test-1.tar.gz"
            echo "✓ Compress auto-rename works"
        else
            echo "✗ Compress auto-rename failed - renamed archive not created"
            return 1
        end
    else
        echo "✗ Compress auto-rename failed"
        return 1
    end
    
    cd $original_pwd
end

function test_compress_timestamp
    echo "Testing compress timestamp..."
    
    # Create test files
    cd "$test_dir"
    echo "test content" > test_file.txt
    
    # Compress with timestamp
    if compress --timestamp test.tar.gz test_file.txt
        if test -f "test-"(date +%Y%m%d_%H%M%S)".tar.gz"
            echo "✓ Compress timestamp works"
        else
            echo "✗ Compress timestamp failed - timestamped archive not created"
            return 1
        end
    else
        echo "✗ Compress timestamp failed"
        return 1
    end
    
    cd $original_pwd
end

function test_compress_update
    echo "Testing compress update..."
    
    # Create test files
    cd "$test_dir"
    echo "test content" > test_file.txt
    
    # Compress first time
    compress test.tar.gz test_file.txt
    
    # Create new file
    echo "new content" > new_file.txt
    
    # Update archive
    if compress -u test.tar.gz new_file.txt
        if test -f "test.tar.gz"
            echo "✓ Compress update works"
        else
            echo "✗ Compress update failed - archive not updated"
            return 1
        end
    else
        echo "✗ Compress update failed"
        return 1
    end
    
    cd $original_pwd
end

function run_tests
    echo "Running Fish Archive Manager compress tests..."
    echo "=============================================="
    
    set -l failed_tests 0
    
    test_compress_help; or set failed_tests (math $failed_tests + 1)
    test_compress_dry_run; or set failed_tests (math $failed_tests + 1)
    test_compress_tar_gz; or set failed_tests (math $failed_tests + 1)
    test_compress_tar_xz; or set failed_tests (math $failed_tests + 1)
    test_compress_tar_zst; or set failed_tests (math $failed_tests + 1)
    test_compress_zip; or set failed_tests (math $failed_tests + 1)
    test_compress_7z; or set failed_tests (math $failed_tests + 1)
    test_compress_smart; or set failed_tests (math $failed_tests + 1)
    test_compress_exclude; or set failed_tests (math $failed_tests + 1)
    test_compress_include; or set failed_tests (math $failed_tests + 1)
    test_compress_checksum; or set failed_tests (math $failed_tests + 1)
    test_compress_auto_rename; or set failed_tests (math $failed_tests + 1)
    test_compress_timestamp; or set failed_tests (math $failed_tests + 1)
    test_compress_update; or set failed_tests (math $failed_tests + 1)
    
    echo "=============================================="
    if test $failed_tests -eq 0
        echo "✓ All compress tests passed!"
        return 0
    else
        echo "✗ $failed_tests test(s) failed"
        return 1
    end
end

# Cleanup function
function cleanup
    rm -rf "$test_dir"
end

# Run tests
run_tests
set -l test_result $status

# Cleanup
cleanup

exit $test_result