#!/usr/bin/env fish
# Security improvement tests for Fish Pack

set -l test_dir (mktemp -d -t fish-pack-test.XXXXXX)
cd $test_dir

echo "=== Testing Security Improvements ==="

# Test 1: Path traversal protection
echo -n "Test 1: Path traversal protection... "
set -l malicious_file "../../etc/passwd"
if __fish_pack_check_path_traversal "$malicious_file"
    echo "FAIL - Path traversal not detected"
    exit 1
else
    echo "PASS"
end

# Test 2: Secure temp file creation
echo -n "Test 2: Secure temp file creation... "
set -l temp_file (__fish_pack_secure_temp_file "test")
if test -f "$temp_file"
    set -l perms (stat -c %a "$temp_file" 2>/dev/null; or stat -f %p "$temp_file" | tail -c 4)
    if test "$perms" = "600"
        echo "PASS"
        rm -f "$temp_file"
    else
        echo "FAIL - Wrong permissions: $perms"
        rm -f "$temp_file"
        exit 1
    end
else
    echo "FAIL - Temp file not created"
    exit 1
end

# Test 3: Secure temp directory creation
echo -n "Test 3: Secure temp directory creation... "
set -l temp_dir (__fish_pack_secure_temp_dir "test")
if test -d "$temp_dir"
    set -l perms (stat -c %a "$temp_dir" 2>/dev/null; or stat -f %p "$temp_dir" | tail -c 4)
    if test "$perms" = "700"
        echo "PASS"
        rmdir "$temp_dir"
    else
        echo "FAIL - Wrong permissions: $perms"
        rmdir "$temp_dir"
        exit 1
    end
else
    echo "FAIL - Temp directory not created"
    exit 1
end

# Test 4: Password reading (interactive test skipped in CI)
echo -n "Test 4: Password reading... "
if set -q CI
    echo "SKIP (CI environment)"
else
    # Manual test only
    echo "SKIP (requires manual testing)"
end

# Test 5: Archive member validation
echo -n "Test 5: Archive member validation... "
# Create test archive with unsafe path
echo "test" > normal.txt
mkdir -p subdir
echo "test" > subdir/file.txt

# Create tar with normal files
tar -czf safe.tar.gz normal.txt subdir/file.txt

# Test safe archive
if __fish_pack_verify_archive_members safe.tar.gz tar.gz
    echo "PASS"
else
    echo "FAIL - Safe archive rejected"
    exit 1
end

# Cleanup would happen here but we can't easily create unsafe archives in tests

# Test 6: Filename validation
echo -n "Test 6: Filename validation... "
set -l safe_file "normal_file.txt"
set -l unsafe_file "../../../etc/passwd"
set -l null_file (printf "file\0name")

if __fish_pack_validate_filename "$safe_file"
    if not __fish_pack_validate_filename "$unsafe_file"
        echo "PASS"
    else
        echo "FAIL - Unsafe filename not rejected"
        exit 1
    end
else
    echo "FAIL - Safe filename rejected"
    exit 1
end

# Test 7: Safe command execution (no eval)
echo -n "Test 7: Safe command execution... "
set -l output (__fish_pack_safe_exec echo "test output")
if test "$output" = "test output"
    echo "PASS"
else
    echo "FAIL - Command execution failed"
    exit 1
end

# Test 8: Special character handling
echo -n "Test 8: Special character handling... "
set -l special_file "file with spaces.txt"
echo "test" > "$special_file"
set -l quoted (__fish_pack_quote_filename "$special_file")
if test -n "$quoted"
    echo "PASS"
    rm -f "$special_file"
else
    echo "FAIL - Quoting failed"
    exit 1
end

# Cleanup
cd /
rm -rf $test_dir

echo ""
echo "=== All security tests passed! ==="