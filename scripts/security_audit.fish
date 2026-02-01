#!/usr/bin/env fish
# Security audit script for Fish Archive Manager
# Checks for common security vulnerabilities and best practices

set -l script_dir (dirname (status --current-filename))
set -l project_root (dirname $script_dir)

echo "🔍 Fish Archive Manager Security Audit"
echo "======================================"
echo ""

set -l issues 0
set -l warnings 0

# Check for eval usage (high risk)
echo "Checking for eval usage..."
if grep -r "eval " --include="*.fish" --exclude-dir="tests" $project_root | grep -v "^[[:space:]]*#"
    echo "❌ CRITICAL: Found 'eval' usage which is a security risk"
    set issues (math $issues + 1)
else
    echo "✅ No eval usage found"
end

# Check for unquoted variables in command substitution
echo ""
echo "Checking for unquoted variables..."
if grep -r '\$[a-zA-Z_][a-zA-Z0-9_]*[^"]' --include="*.fish" --exclude-dir="tests" $project_root | grep -v '^[[:space:]]*#' | grep -v '^[[:space:]]*echo'
    echo "⚠️  WARNING: Found potentially unquoted variables"
    set warnings (math $warnings + 1)
else
    echo "✅ No unquoted variables found"
end

# Check for password handling
echo ""
echo "Checking password handling..."
if grep -r "password" --include="*.fish" --exclude-dir="tests" $project_root | grep -v "^[[:space:]]*#" | grep -v "description"
    echo "⚠️  WARNING: Found password-related code - ensure proper handling"
    set warnings (math $warnings + 1)
else
    echo "✅ No password handling found"
end

# Check for temporary file usage
echo ""
echo "Checking temporary file handling..."
if grep -r "mktemp\|/tmp/" --include="*.fish" --exclude-dir="tests" $project_root | grep -v "^[[:space:]]*#"
    echo "⚠️  WARNING: Found temporary file usage - ensure proper cleanup"
    set warnings (math $warnings + 1)
else
    echo "✅ No temporary file usage found"
end

# Check for external command execution
echo ""
echo "Checking external command execution..."
if grep -r "command\|exec\|system" --include="*.fish" --exclude-dir="tests" $project_root | grep -v "^[[:space:]]*#" | grep -v "has_command\|require_commands"
    echo "⚠️  WARNING: Found external command execution - ensure proper validation"
    set warnings (math $warnings + 1)
else
    echo "✅ External command execution looks safe"
end

# Check for path traversal vulnerabilities
echo ""
echo "Checking for path traversal vulnerabilities..."
if grep -r "\.\./" --include="*.fish" --exclude-dir="tests" $project_root | grep -v "^[[:space:]]*#" | grep -v "string replace"
    echo "❌ CRITICAL: Found potential path traversal vulnerability"
    set issues (math $issues + 1)
else
    echo "✅ No path traversal vulnerabilities found"
end

# Check for proper input validation
echo ""
echo "Checking input validation..."
set -l validation_functions (grep -r "function.*validate" --include="*.fish" --exclude-dir="tests" $project_root | wc -l)
if test $validation_functions -gt 0
    echo "✅ Found $validation_functions validation functions"
else
    echo "⚠️  WARNING: No validation functions found"
    set warnings (math $warnings + 1)
end

# Check for error handling
echo ""
echo "Checking error handling..."
set -l error_functions (grep -r "function.*error" --include="*.fish" --exclude-dir="tests" $project_root | wc -l)
if test $error_functions -gt 0
    echo "✅ Found $error_functions error handling functions"
else
    echo "⚠️  WARNING: No error handling functions found"
    set warnings (math $warnings + 1)
end

# Check for logging
echo ""
echo "Checking logging..."
if grep -r "log " --include="*.fish" --exclude-dir="tests" $project_root | grep -v "^[[:space:]]*#" | head -1
    echo "✅ Logging functions found"
else
    echo "⚠️  WARNING: No logging functions found"
    set warnings (math $warnings + 1)
end

# Summary
echo ""
echo "======================================"
echo "Security Audit Summary"
echo "======================================"
echo "Critical Issues: $issues"
echo "Warnings: $warnings"
echo ""

if test $issues -gt 0
    echo "❌ Security audit FAILED - Critical issues found"
    exit 1
else if test $warnings -gt 0
    echo "⚠️  Security audit PASSED with warnings"
    exit 0
else
    echo "✅ Security audit PASSED - No issues found"
    exit 0
end
