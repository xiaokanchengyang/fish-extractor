# Test suite for Fish Archive Manager extract functionality
# Run with: fish tests/test_extract.fish

set -l test_dir (mktemp -d)
set -l original_pwd (pwd)

function test_extract_help
    echo "Testing extract help..."
    
    set -l result (extract --help 2>&1)
    if string match -q "*Usage:*" -- $result
        echo "✓ Extract help works"
    else
        echo "✗ Extract help failed"
        return 1
    end
end

function test_extract_dry_run
    echo "Testing extract dry run..."
    
    # Create a test tar.gz file
    cd "$test_dir"
    echo "test content" > test_file.txt
    tar -czf test.tar.gz test_file.txt
    
    set -l result (extract --dry-run test.tar.gz 2>&1)
    if string match -q "*DRY-RUN*" -- $result
        echo "✓ Extract dry run works"
    else
        echo "✗ Extract dry run failed"
        return 1
    end
    
    cd $original_pwd
end

function test_extract_list
    echo "Testing extract list..."
    
    # Create a test tar.gz file
    cd "$test_dir"
    echo "test content" > test_file.txt
    tar -czf test.tar.gz test_file.txt
    
    set -l result (extract --list test.tar.gz 2>&1)
    if string match -q "*test_file.txt*" -- $result
        echo "✓ Extract list works"
    else
        echo "✗ Extract list failed"
        return 1
    end
    
    cd $original_pwd
end

function test_extract_test
    echo "Testing extract test..."
    
    # Create a test tar.gz file
    cd "$test_dir"
    echo "test content" > test_file.txt
    tar -czf test.tar.gz test_file.txt
    
    if extract --test test.tar.gz
        echo "✓ Extract test works"
    else
        echo "✗ Extract test failed"
        return 1
    end
    
    cd $original_pwd
end

function test_extract_actual
    echo "Testing extract actual extraction..."
    
    # Create a test tar.gz file
    cd "$test_dir"
    echo "test content" > test_file.txt
    tar -czf test.tar.gz test_file.txt
    
    # Extract it
    if extract test.tar.gz
        if test -f "test_file.txt"
            echo "✓ Extract actual extraction works"
        else
            echo "✗ Extract actual extraction failed - file not found"
            return 1
        end
    else
        echo "✗ Extract actual extraction failed"
        return 1
    end
    
    cd $original_pwd
end

function test_extract_with_dest
    echo "Testing extract with destination..."
    
    # Create a test tar.gz file
    cd "$test_dir"
    echo "test content" > test_file.txt
    tar -czf test.tar.gz test_file.txt
    
    # Extract to specific destination
    if extract -d extracted test.tar.gz
        if test -f "extracted/test_file.txt"
            echo "✓ Extract with destination works"
        else
            echo "✗ Extract with destination failed - file not found"
            return 1
        end
    else
        echo "✗ Extract with destination failed"
        return 1
    end
    
    cd $original_pwd
end

function test_extract_zip
    echo "Testing extract ZIP files..."
    
    if not has_command zip
        echo "⚠ ZIP not available, skipping test"
        return 0
    end
    
    # Create a test zip file
    cd "$test_dir"
    echo "test content" > test_file.txt
    zip test.zip test_file.txt
    
    # Extract it
    if extract test.zip
        if test -f "test_file.txt"
            echo "✓ Extract ZIP works"
        else
            echo "✗ Extract ZIP failed - file not found"
            return 1
        end
    else
        echo "✗ Extract ZIP failed"
        return 1
    end
    
    cd $original_pwd
end

function test_extract_7z
    echo "Testing extract 7z files..."
    
    if not has_command 7z
        echo "⚠ 7z not available, skipping test"
        return 0
    end
    
    # Create a test 7z file
    cd "$test_dir"
    echo "test content" > test_file.txt
    7z a test.7z test_file.txt >/dev/null
    
    # Extract it
    if extract test.7z
        if test -f "test_file.txt"
            echo "✓ Extract 7z works"
        else
            echo "✗ Extract 7z failed - file not found"
            return 1
        end
    else
        echo "✗ Extract 7z failed"
        return 1
    end
    
    cd $original_pwd
end

function test_extract_multiple
    echo "Testing extract multiple files..."
    
    # Create multiple test tar.gz files
    cd "$test_dir"
    echo "test content 1" > test_file1.txt
    echo "test content 2" > test_file2.txt
    tar -czf test1.tar.gz test_file1.txt
    tar -czf test2.tar.gz test_file2.txt
    
    # Extract both
    if extract test1.tar.gz test2.tar.gz
        if test -f "test_file1.txt" -a -f "test_file2.txt"
            echo "✓ Extract multiple files works"
        else
            echo "✗ Extract multiple files failed - files not found"
            return 1
        end
    else
        echo "✗ Extract multiple files failed"
        return 1
    end
    
    cd $original_pwd
end

function test_extract_auto_rename
    echo "Testing extract auto-rename..."
    
    # Create a test tar.gz file
    cd "$test_dir"
    echo "test content" > test_file.txt
    tar -czf test.tar.gz test_file.txt
    
    # Extract first time
    extract test.tar.gz
    
    # Extract second time with auto-rename
    if extract --auto-rename test.tar.gz
        if test -d "test-1"
            echo "✓ Extract auto-rename works"
        else
            echo "✗ Extract auto-rename failed - directory not found"
            return 1
        end
    else
        echo "✗ Extract auto-rename failed"
        return 1
    end
    
    cd $original_pwd
end

function test_extract_timestamp
    echo "Testing extract timestamp..."
    
    # Create a test tar.gz file
    cd "$test_dir"
    echo "test content" > test_file.txt
    tar -czf test.tar.gz test_file.txt
    
    # Extract with timestamp
    if extract --timestamp test.tar.gz
        if test -d "test-"(date +%Y%m%d_%H%M%S)
            echo "✓ Extract timestamp works"
        else
            echo "✗ Extract timestamp failed - directory not found"
            return 1
        end
    else
        echo "✗ Extract timestamp failed"
        return 1
    end
    
    cd $original_pwd
end

function run_tests
    echo "Running Fish Archive Manager extract tests..."
    echo "============================================="
    
    set -l failed_tests 0
    
    test_extract_help; or set failed_tests (math $failed_tests + 1)
    test_extract_dry_run; or set failed_tests (math $failed_tests + 1)
    test_extract_list; or set failed_tests (math $failed_tests + 1)
    test_extract_test; or set failed_tests (math $failed_tests + 1)
    test_extract_actual; or set failed_tests (math $failed_tests + 1)
    test_extract_with_dest; or set failed_tests (math $failed_tests + 1)
    test_extract_zip; or set failed_tests (math $failed_tests + 1)
    test_extract_7z; or set failed_tests (math $failed_tests + 1)
    test_extract_multiple; or set failed_tests (math $failed_tests + 1)
    test_extract_auto_rename; or set failed_tests (math $failed_tests + 1)
    test_extract_timestamp; or set failed_tests (math $failed_tests + 1)
    
    echo "============================================="
    if test $failed_tests -eq 0
        echo "✓ All extract tests passed!"
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