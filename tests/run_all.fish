# Master test runner for Fish Archive Manager
# Run with: fish tests/run_all.fish

set -l test_dir (dirname (status --current-filename))
set -l original_pwd (pwd)

function run_test_suite
    set -l test_file $argv[1]
    set -l test_name $argv[2]
    
    echo "Running $test_name tests..."
    echo "=========================="
    
    if test -f "$test_file"
        fish "$test_file"
        set -l result $status
        
        if test $result -eq 0
            echo "✓ $test_name tests passed!"
        else
            echo "✗ $test_name tests failed!"
        end
        
        echo ""
        return $result
    else
        echo "✗ Test file not found: $test_file"
        echo ""
        return 1
    end
end

function run_all_tests
    echo "Fish Archive Manager Test Suite"
    echo "==============================="
    echo ""
    
    set -l failed_suites 0
    set -l total_suites 0
    
    # Run core tests
    set total_suites (math $total_suites + 1)
    run_test_suite "$test_dir/test_core.fish" "Core"
    or set failed_suites (math $failed_suites + 1)
    
    # Run extract tests
    set total_suites (math $total_suites + 1)
    run_test_suite "$test_dir/test_extract.fish" "Extract"
    or set failed_suites (math $failed_suites + 1)
    
    # Run compress tests
    set total_suites (math $total_suites + 1)
    run_test_suite "$test_dir/test_compress.fish" "Compress"
    or set failed_suites (math $failed_suites + 1)
    
    # Run doctor tests
    set total_suites (math $total_suites + 1)
    run_test_suite "$test_dir/test_doctor.fish" "Doctor"
    or set failed_suites (math $failed_suites + 1)
    
    # Summary
    echo "==============================="
    echo "Test Suite Summary"
    echo "==============================="
    echo "Total test suites: $total_suites"
    echo "Passed: "(math $total_suites - $failed_suites)
    echo "Failed: $failed_suites"
    
    if test $failed_suites -eq 0
        echo ""
        echo "🎉 All test suites passed!"
        return 0
    else
        echo ""
        echo "❌ $failed_suites test suite(s) failed!"
        return 1
    end
end

# Run all tests
run_all_tests
set -l test_result $status

exit $test_result