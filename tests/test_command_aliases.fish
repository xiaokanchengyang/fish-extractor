#!/usr/bin/env fish
# Test command aliases and renames for Fish Pack

echo "=== Testing Command Aliases and Renames ==="

# Test 1: check command (renamed from doctor)
echo -n "Test 1: 'check' command exists... "
if functions -q check
    echo "PASS"
else
    echo "FAIL"
    exit 1
end

# Test 2: doctor still works as alias
echo -n "Test 2: 'doctor' alias works... "
if functions -q doctor
    echo "PASS"
else
    echo "FAIL"
    exit 1
end

# Test 3: pack alias for compress
echo -n "Test 3: 'pack' alias exists... "
if functions -q pack
    echo "PASS"
else
    echo "FAIL"
    exit 1
end

# Test 4: unpack alias for extract
echo -n "Test 4: 'unpack' alias exists... "
if functions -q unpack
    echo "PASS"
else
    echo "FAIL"
    exit 1
end

# Test 5: Help commands work
echo -n "Test 5: Help commands work... "
set -l help_output (check --help 2>&1)
if string match -q "*Usage: check*" -- $help_output
    echo "PASS"
else
    echo "FAIL"
    exit 1
end

# Test 6: Deprecation warning for doctor
echo -n "Test 6: Doctor shows deprecation warning... "
set -l doctor_output (doctor --help 2>&1)
if string match -q "*deprecated*" -- $doctor_output
    echo "PASS"
else
    echo "FAIL"
    exit 1
end

echo ""
echo "=== All command alias tests passed! ==="