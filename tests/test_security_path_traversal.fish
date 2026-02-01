# Test Security Path Traversal Logic

# Source the security helpers
source functions/common/security_helpers.fish

set -l failures 0

function run_test
    set -l input $argv[1]
    set -l expected $argv[2] # 0 for unsafe, 1 for safe (based on function return)
    
    if __fish_pack_is_unsafe_path "$input"
        set result 0
    else
        set result 1
    end
    
    if test $result -eq $expected
        echo "PASS: '$input'"
    else
        echo "FAIL: '$input' (Expected $expected, got $result)"
        set failures (math $failures + 1)
    end
end

echo "Testing __fish_pack_is_unsafe_path..."

# Absolute paths (Unsafe -> 0)
run_test "/etc/passwd" 0
run_test "/absolute/path" 0
run_test "/" 0

# Traversal paths (Unsafe -> 0)
run_test "../outside" 0
run_test "deep/../../root" 0
run_test "just/.." 0
run_test ".." 0
run_test "../" 0
run_test "a/../b" 0

# Safe paths (Safe -> 1)
run_test "safe/file.txt" 1
run_test "safe..file" 1
run_test "file..." 1
run_test ".config" 1
run_test "./current" 1
run_test "a/b/c" 1
run_test "folder.with.dots/file" 1

if test $failures -gt 0
    echo "FAILED: $failures tests failed"
    exit 1
else
    echo "ALL TESTS PASSED"
    exit 0
end
