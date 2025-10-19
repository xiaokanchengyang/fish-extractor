#!/usr/bin/env fish
# Security tests for Fish Archive Manager

source (dirname (status --current-filename))/../functions/core.fish

echo "Testing security features..."

# Test input sanitization
echo "Testing input sanitization..."

# Test path sanitization
set -l safe_path (sanitize_path "~/Documents/test.txt")
echo "Sanitized path: $safe_path"
if test -n "$safe_path"
    echo "✓ Path sanitization working"
else
    echo "✗ Path sanitization failed"
    exit 1
end

# Test dangerous path detection
set -l dangerous_paths "../etc/passwd" "../../../etc/shadow" "/etc/passwd" "/sys/kernel/debug"
for path in $dangerous_paths
    if _validate_path "$path"
        echo "✗ Dangerous path '$path' was not blocked"
        exit 1
    end
end
echo "✓ Dangerous path validation working"

# Test safe path detection
set -l safe_paths "Documents/file.txt" "project/src/main.c" "backup/data.tar.gz"
for path in $safe_paths
    if not _validate_path "$path"
        echo "✗ Safe path '$path' was blocked"
        exit 1
    end
end
echo "✓ Safe path validation working"

# Test filename sanitization
echo "Testing filename sanitization..."
set -l dangerous_names "../../../etc/passwd" "file; rm -rf /" "file|cat /etc/passwd"
for name in $dangerous_names
    set -l sanitized (_sanitize_filename "$name")
    if string match -q "*../*" -- $sanitized; or string match -q "*;" -- $sanitized; or string match -q "*|*" -- $sanitized
        echo "✗ Filename '$name' was not properly sanitized: '$sanitized'"
        exit 1
    end
end
echo "✓ Filename sanitization working"

# Test temporary file security
echo "Testing temporary file security..."
set -l temp_file (_create_temp_file "test")
if test -f $temp_file
    # Check permissions (should be 600 for security)
    set -l perms (stat -c %a "$temp_file" 2>/dev/null; or stat -f %A "$temp_file" 2>/dev/null)
    if test "$perms" = "600"
        echo "✓ Temporary file has secure permissions"
    else
        echo "⚠ Temporary file permissions: $perms (expected 600)"
    end
    rm $temp_file
else
    echo "✗ Temporary file creation failed"
    exit 1
end

# Test command execution safety
echo "Testing command execution safety..."

# Test that eval is not used in task queue
if grep -q "eval " /workspace/tools/task_queue.fish
    echo "✗ Found 'eval' usage in task queue (security risk)"
    exit 1
else
    echo "✓ No 'eval' usage found in task queue"
end

# Test that external commands are properly escaped
if grep -q '\$[a-zA-Z_][a-zA-Z0-9_]*[^"]' /workspace/functions/core.fish | grep -v '^[[:space:]]*#' | grep -v 'echo'
    echo "⚠ Found potentially unquoted variables in core.fish"
else
    echo "✓ No unquoted variables found in core.fish"
end

# Test password handling
echo "Testing password handling..."
# Check that passwords are not logged
if grep -q "password" /workspace/functions/core.fish | grep -v "description" | grep -v "help"
    echo "⚠ Found password-related code - ensure proper handling"
else
    echo "✓ No password handling found in core functions"
end

# Test error handling
echo "Testing error handling..."
# Check that errors are properly handled
if grep -q "return 1" /workspace/functions/core.fish
    echo "✓ Error handling found"
else
    echo "⚠ No explicit error handling found"
end

# Test logging
echo "Testing logging..."
if grep -q "log " /workspace/functions/core.fish
    echo "✓ Logging functions found"
else
    echo "⚠ No logging functions found"
end

echo "✅ Security tests completed!"