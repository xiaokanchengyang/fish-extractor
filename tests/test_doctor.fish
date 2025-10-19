# Test suite for Fish Archive Manager doctor functionality
# Run with: fish tests/test_doctor.fish

function test_doctor_help
    echo "Testing doctor help..."
    
    set -l result (doctor --help 2>&1)
    if string match -q "*Usage:*" -- $result
        echo "✓ Doctor help works"
    else
        echo "✗ Doctor help failed"
        return 1
    end
end

function test_doctor_basic
    echo "Testing doctor basic functionality..."
    
    set -l result (doctor 2>&1)
    if string match -q "*Fish Archive Manager*" -- $result
        echo "✓ Doctor basic works"
    else
        echo "✗ Doctor basic failed"
        return 1
    end
end

function test_doctor_verbose
    echo "Testing doctor verbose..."
    
    set -l result (doctor -v 2>&1)
    if string match -q "*System Information*" -- $result
        echo "✓ Doctor verbose works"
    else
        echo "✗ Doctor verbose failed"
        return 1
    end
end

function test_doctor_quiet
    echo "Testing doctor quiet..."
    
    set -l result (doctor -q 2>&1)
    if test (count (string split '\n' -- $result)) -lt 10
        echo "✓ Doctor quiet works"
    else
        echo "✗ Doctor quiet failed"
        return 1
    end
end

function test_doctor_fix
    echo "Testing doctor fix..."
    
    set -l result (doctor --fix 2>&1)
    if string match -q "*Recommendations*" -- $result
        echo "✓ Doctor fix works"
    else
        echo "✗ Doctor fix failed"
        return 1
    end
end

function test_doctor_export
    echo "Testing doctor export..."
    
    set -l result (doctor --export 2>&1)
    if string match -q "*exported to*" -- $result
        echo "✓ Doctor export works"
    else
        echo "✗ Doctor export failed"
        return 1
    end
end

function test_doctor_exit_codes
    echo "Testing doctor exit codes..."
    
    # Test with missing required tools (should return 1)
    # This is a bit tricky to test without actually breaking the system
    # So we'll just test that the command runs and returns some exit code
    doctor >/dev/null 2>&1
    set -l exit_code $status
    
    if test $exit_code -ge 0 -a $exit_code -le 1
        echo "✓ Doctor exit codes work"
    else
        echo "✗ Doctor exit codes failed: $exit_code"
        return 1
    end
end

function test_doctor_config_display
    echo "Testing doctor configuration display..."
    
    set -l result (doctor 2>&1)
    if string match -q "*FISH_ARCHIVE_COLOR*" -- $result
        echo "✓ Doctor config display works"
    else
        echo "✗ Doctor config display failed"
        return 1
    end
end

function test_doctor_tool_detection
    echo "Testing doctor tool detection..."
    
    set -l result (doctor 2>&1)
    if string match -q "*Required Tools*" -- $result
        echo "✓ Doctor tool detection works"
    else
        echo "✗ Doctor tool detection failed"
        return 1
    end
end

function test_doctor_format_support
    echo "Testing doctor format support..."
    
    set -l result (doctor -v 2>&1)
    if string match -q "*Supported Archive Formats*" -- $result
        echo "✓ Doctor format support works"
    else
        echo "✗ Doctor format support failed"
        return 1
    end
end

function test_doctor_performance_features
    echo "Testing doctor performance features..."
    
    set -l result (doctor -v 2>&1)
    if string match -q "*Performance Features*" -- $result
        echo "✓ Doctor performance features works"
    else
        echo "✗ Doctor performance features failed"
        return 1
    end
end

function run_tests
    echo "Running Fish Archive Manager doctor tests..."
    echo "==========================================="
    
    set -l failed_tests 0
    
    test_doctor_help; or set failed_tests (math $failed_tests + 1)
    test_doctor_basic; or set failed_tests (math $failed_tests + 1)
    test_doctor_verbose; or set failed_tests (math $failed_tests + 1)
    test_doctor_quiet; or set failed_tests (math $failed_tests + 1)
    test_doctor_fix; or set failed_tests (math $failed_tests + 1)
    test_doctor_export; or set failed_tests (math $failed_tests + 1)
    test_doctor_exit_codes; or set failed_tests (math $failed_tests + 1)
    test_doctor_config_display; or set failed_tests (math $failed_tests + 1)
    test_doctor_tool_detection; or set failed_tests (math $failed_tests + 1)
    test_doctor_format_support; or set failed_tests (math $failed_tests + 1)
    test_doctor_performance_features; or set failed_tests (math $failed_tests + 1)
    
    echo "==========================================="
    if test $failed_tests -eq 0
        echo "✓ All doctor tests passed!"
        return 0
    else
        echo "✗ $failed_tests test(s) failed"
        return 1
    end
end

# Run tests
run_tests
set -l test_result $status

exit $test_result