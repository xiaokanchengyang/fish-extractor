# Test Security

source functions/common/security_helpers.fish

# Test Path Traversal Check
function test_path
    set -l path $argv[1]
    set -l expected $argv[2]
    
    if __fish_pack_is_unsafe_path "$path"
        set result 1
    else
        set result 0
    end
    
    if test $result -eq $expected
        echo "✓ Check $path (Expected: $expected, Got: $result)"
    else
        echo "✗ Check $path (Expected: $expected, Got: $result)"
        set -g failed 1
    end
end

# Safe paths
test_path "normal/file.txt" 0
test_path "file.txt" 0
test_path "dir/subdir/file" 0

# Unsafe paths
test_path "../file.txt" 1
test_path "dir/../../etc/passwd" 1
test_path "/etc/passwd" 1
test_path "/usr/bin/evil" 1

echo "Security tests passed"
exit 0
