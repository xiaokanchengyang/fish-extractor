#!/usr/bin/env fish
# Test platform helpers for Fish Archive Manager

source (dirname (status --current-filename))/../functions/common/platform_helpers.fish

echo "Testing platform helpers..."

# Test platform detection
echo "Testing platform detection..."
set -l platform (detect_platform)
echo "Detected platform: $platform"

# Test platform-specific functions
if is_linux
    echo "✓ Linux detected correctly"
else if is_macos
    echo "✓ macOS detected correctly"
else if is_windows
    echo "✓ Windows detected correctly"
else
    echo "⚠ Unknown platform: $platform"
end

# Test core detection
echo "Testing core detection..."
set -l cores (_detect_cores)
echo "Detected cores: $cores"
if test $cores -gt 0
    echo "✓ Core detection working"
else
    echo "✗ Core detection failed"
    exit 1
end

# Test file size detection
echo "Testing file size detection..."
set -l test_file (mktemp)
echo "test content" > $test_file
set -l size (_stat_size $test_file)
echo "File size: $size bytes"
if test $size -gt 0
    echo "✓ File size detection working"
else
    echo "✗ File size detection failed"
    exit 1
end
rm $test_file

# Test tool detection
echo "Testing tool detection..."
if _which_tool tar
    echo "✓ tar found: "(_which_tool tar)
else
    echo "✗ tar not found"
    exit 1
end

# Test package manager detection
echo "Testing package manager detection..."
set -l pkg_mgr (_detect_package_manager)
echo "Detected package manager: $pkg_mgr"

# Test temp file creation
echo "Testing temporary file creation..."
set -l temp_file (_create_temp_file "test")
echo "Created temp file: $temp_file"
if test -f $temp_file
    echo "✓ Temp file creation working"
    rm $temp_file
else
    echo "✗ Temp file creation failed"
    exit 1
end

# Test temp directory creation
echo "Testing temporary directory creation..."
set -l temp_dir (_create_temp_dir "test")
echo "Created temp dir: $temp_dir"
if test -d $temp_dir
    echo "✓ Temp directory creation working"
    rmdir $temp_dir
else
    echo "✗ Temp directory creation failed"
    exit 1
end

# Test filename sanitization
echo "Testing filename sanitization..."
set -l sanitized (_sanitize_filename "../../../etc/passwd")
echo "Sanitized filename: $sanitized"
if not string match -q "*../*" -- $sanitized
    echo "✓ Filename sanitization working"
else
    echo "✗ Filename sanitization failed"
    exit 1
end

# Test path validation
echo "Testing path validation..."
if _validate_path "safe/path/file.txt"
    echo "✓ Safe path validation working"
else
    echo "✗ Safe path validation failed"
    exit 1
end

if not _validate_path "../../../etc/passwd"
    echo "✓ Dangerous path validation working"
else
    echo "✗ Dangerous path validation failed"
    exit 1
end

echo "✅ All platform helper tests passed!"