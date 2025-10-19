# Test suite for Fish Archive Manager core functions
# Run with: fish tests/test_core.fish

set -l test_dir (mktemp -d)
set -l original_pwd (pwd)

function test_sanitize_path
    echo "Testing sanitize_path..."
    
    # Test tilde expansion
    set -l result (sanitize_path "~/test")
    if test "$result" = "$HOME/test"
        echo "✓ Tilde expansion works"
    else
        echo "✗ Tilde expansion failed: $result"
        return 1
    end
    
    # Test relative path
    cd /tmp
    set -l result (sanitize_path "test")
    if test "$result" = "/tmp/test"
        echo "✓ Relative path expansion works"
    else
        echo "✗ Relative path expansion failed: $result"
        return 1
    end
    
    cd $original_pwd
end

function test_get_extension
    echo "Testing get_extension..."
    
    # Test tar.gz
    set -l result (get_extension "archive.tar.gz")
    if test "$result" = "tar.gz"
        echo "✓ tar.gz extension detected"
    else
        echo "✗ tar.gz extension failed: $result"
        return 1
    end
    
    # Test zip
    set -l result (get_extension "archive.zip")
    if test "$result" = "zip"
        echo "✓ zip extension detected"
    else
        echo "✗ zip extension failed: $result"
        return 1
    end
end

function test_detect_format
    echo "Testing detect_format..."
    
    # Test tar.gz
    set -l result (detect_format "archive.tar.gz")
    if test "$result" = "tar.gz"
        echo "✓ tar.gz format detected"
    else
        echo "✗ tar.gz format failed: $result"
        return 1
    end
    
    # Test zip
    set -l result (detect_format "archive.zip")
    if test "$result" = "zip"
        echo "✓ zip format detected"
    else
        echo "✗ zip format failed: $result"
        return 1
    end
end

function test_human_size
    echo "Testing human_size..."
    
    # Test bytes
    set -l result (human_size 1023)
    if test "$result" = "1023B"
        echo "✓ Bytes formatting works"
    else
        echo "✗ Bytes formatting failed: $result"
        return 1
    end
    
    # Test KB
    set -l result (human_size 1024)
    if test "$result" = "1.00KB"
        echo "✓ KB formatting works"
    else
        echo "✗ KB formatting failed: $result"
        return 1
    end
    
    # Test MB
    set -l result (human_size 1048576)
    if test "$result" = "1.00MB"
        echo "✓ MB formatting works"
    else
        echo "✗ MB formatting failed: $result"
        return 1
    end
end

function test_validate_level
    echo "Testing validate_level..."
    
    # Test gzip level
    set -l result (validate_level gzip 15)
    if test "$result" = "9"
        echo "✓ Gzip level validation works"
    else
        echo "✗ Gzip level validation failed: $result"
        return 1
    end
    
    # Test xz level
    set -l result (validate_level xz -5)
    if test "$result" = "0"
        echo "✓ XZ level validation works"
    else
        echo "✗ XZ level validation failed: $result"
        return 1
    end
end

function test_smart_format
    echo "Testing smart_format..."
    
    # Create test files
    mkdir -p "$test_dir/text_files"
    mkdir -p "$test_dir/binary_files"
    
    # Create text files
    echo "This is a text file" > "$test_dir/text_files/file1.txt"
    echo "Another text file" > "$test_dir/text_files/file2.txt"
    
    # Create binary file (simulate)
    dd if=/dev/zero of="$test_dir/binary_files/file.bin" bs=1024 count=1 2>/dev/null
    
    # Test text-heavy content
    set -l result (smart_format "$test_dir/text_files")
    if test "$result" = "tar.xz"
        echo "✓ Text content detected correctly"
    else
        echo "✗ Text content detection failed: $result"
        return 1
    end
    
    # Test binary content
    set -l result (smart_format "$test_dir/binary_files")
    if test "$result" = "tar.zst"
        echo "✓ Binary content detected correctly"
    else
        echo "✗ Binary content detection failed: $result"
        return 1
    end
end

function test_resolve_threads
    echo "Testing resolve_threads..."
    
    # Test with custom value
    set -l result (resolve_threads 8)
    if test "$result" = "8"
        echo "✓ Custom thread count works"
    else
        echo "✗ Custom thread count failed: $result"
        return 1
    end
    
    # Test with empty value (should use default)
    set -l result (resolve_threads "")
    if test "$result" -gt 0
        echo "✓ Default thread count works: $result"
    else
        echo "✗ Default thread count failed: $result"
        return 1
    end
end

function test_validate_archive
    echo "Testing validate_archive..."
    
    # Test existing file
    echo "test content" > "$test_dir/test_file.txt"
    if validate_archive "$test_dir/test_file.txt"
        echo "✓ Valid file validation works"
    else
        echo "✗ Valid file validation failed"
        return 1
    end
    
    # Test non-existing file
    if not validate_archive "$test_dir/nonexistent.txt"
        echo "✓ Non-existing file validation works"
    else
        echo "✗ Non-existing file validation failed"
        return 1
    end
end

function test_calculate_hash
    echo "Testing calculate_hash..."
    
    # Create test file
    echo "test content" > "$test_dir/hash_test.txt"
    
    # Test SHA256
    if has_command sha256sum
        set -l result (calculate_hash "$test_dir/hash_test.txt" sha256)
        if test -n "$result"
            echo "✓ SHA256 calculation works"
        else
            echo "✗ SHA256 calculation failed"
            return 1
        end
    else
        echo "⚠ SHA256 not available, skipping test"
    end
end

function run_tests
    echo "Running Fish Archive Manager core tests..."
    echo "=========================================="
    
    set -l failed_tests 0
    
    test_sanitize_path; or set failed_tests (math $failed_tests + 1)
    test_get_extension; or set failed_tests (math $failed_tests + 1)
    test_detect_format; or set failed_tests (math $failed_tests + 1)
    test_human_size; or set failed_tests (math $failed_tests + 1)
    test_validate_level; or set failed_tests (math $failed_tests + 1)
    test_smart_format; or set failed_tests (math $failed_tests + 1)
    test_resolve_threads; or set failed_tests (math $failed_tests + 1)
    test_validate_archive; or set failed_tests (math $failed_tests + 1)
    test_calculate_hash; or set failed_tests (math $failed_tests + 1)
    
    echo "=========================================="
    if test $failed_tests -eq 0
        echo "✓ All tests passed!"
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