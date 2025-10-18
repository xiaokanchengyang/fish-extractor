# Comprehensive test suite for Fish Archive Manager
# Tests all functions including common modules

set -l test_dir (dirname (status --current-filename))
set -l project_root (dirname $test_dir)

# Load the functions
source $project_root/functions/core.fish
source $project_root/functions/validation.fish
source $project_root/functions/format_handlers.fish
source $project_root/functions/error_handling.fish
source $project_root/functions/common/archive_operations.fish
source $project_root/functions/common/file_operations.fish
source $project_root/functions/common/format_operations.fish

# Test configuration
set -l test_count 0
set -l pass_count 0
set -l fail_count 0
set -l temp_dir (mktemp -d)

function run_test --description 'Run a single test'
    set -l test_name $argv[1]
    set -l test_command $argv[2..-1]
    
    set test_count (math $test_count + 1)
    printf "Test %d: %s ... " $test_count $test_name
    
    if eval $test_command >/dev/null 2>&1
        set pass_count (math $pass_count + 1)
        echo "PASS"
        return 0
    else
        set fail_count (math $fail_count + 1)
        echo "FAIL"
        return 1
    end
end

function run_test_with_output --description 'Run a test and capture output'
    set -l test_name $argv[1]
    set -l test_command $argv[2..-1]
    set -l expected_output $argv[-1]
    
    set test_count (math $test_count + 1)
    printf "Test %d: %s ... " $test_count $test_name
    
    set -l output (eval $test_command 2>&1)
    if string match -q "*$expected_output*" -- $output
        set pass_count (math $pass_count + 1)
        echo "PASS"
        return 0
    else
        set fail_count (math $fail_count + 1)
        echo "FAIL (expected: $expected_output, got: $output)"
        return 1
    end
end

function cleanup --description 'Clean up test files'
    rm -rf $temp_dir
end

# Setup
echo "Fish Archive Manager - Comprehensive Test Suite"
echo "=============================================="
echo ""

# Test 1: Core Functions
echo "Testing Core Functions..."
echo "------------------------"

run_test "supports_color function" "supports_color"
run_test "colorize function" "colorize red 'test'"
run_test "log function" "log info 'test message'"
run_test "require_commands function" "require_commands echo"
run_test "has_command function" "has_command echo"
run_test "resolve_threads function" "resolve_threads 4"
run_test "sanitize_path function" "sanitize_path '/tmp/test'"
run_test "get_extension function" "get_extension 'test.tar.gz'"
run_test "get_file_size function" "get_file_size '/etc/passwd'"
run_test "human_size function" "human_size 1024"

# Test 2: Validation Functions
echo ""
echo "Testing Validation Functions..."
echo "------------------------------"

run_test "is_flag_set function" "is_flag_set 1"
run_test "is_verbose function" "is_verbose 1"
run_test "is_quiet function" "is_quiet 0"
run_test "is_dry_run function" "is_dry_run 0"
run_test "is_force function" "is_force 0"
run_test "is_backup function" "is_backup 0"
run_test "is_encrypt function" "is_encrypt 0"
run_test "is_smart function" "is_smart 0"
run_test "is_solid function" "is_solid 0"
run_test "is_checksum function" "is_checksum 0"
run_test "is_auto_rename function" "is_auto_rename 0"
run_test "is_timestamp function" "is_timestamp 0"
run_test "is_progress_enabled function" "is_progress_enabled 1"

# Test 3: Format Handler Functions
echo ""
echo "Testing Format Handler Functions..."
echo "----------------------------------"

run_test "normalize_format function" "normalize_format 'tgz'"
run_test "is_tar_format function" "is_tar_format 'tar.gz'"
run_test "is_compressed_format function" "is_compressed_format 'tar.gz'"
run_test "supports_encryption function" "supports_encryption 'zip'"
run_test "supports_threading function" "supports_threading 'tar.xz'"
run_test "supports_solid function" "supports_solid '7z'"
run_test "get_compression_command function" "get_compression_command 'gzip' 0"
run_test "get_decompression_command function" "get_decompression_command 'gzip'"
run_test "get_tar_compression_option function" "get_tar_compression_option 'tar.gz'"
run_test "get_compression_level_range function" "get_compression_level_range 'gzip'"
run_test "validate_format_for_operation function" "validate_format_for_operation 'tar.gz' 'extract'"
run_test "check_format_requirements function" "check_format_requirements 'tar.gz' 'extract'"

# Test 4: Error Handling Functions
echo ""
echo "Testing Error Handling Functions..."
echo "----------------------------------"

run_test "report_error function" "report_error 'TEST_ERROR' 'test message' 1"
run_test "handle_file_error function" "handle_file_error '/etc/passwd' 'test'"
run_test "handle_command_error function" "handle_command_error 'echo' 'test'"
run_test "validate_required_args function" "validate_required_args 'arg1' 'test'"
run_test "validate_file_exists function" "validate_file_exists '/etc/passwd' 'test'"
run_test "validate_directory_exists function" "validate_directory_exists '/tmp' 'test'"
run_test "validate_format_support function" "validate_format_support 'tar.gz' 'extract'"
run_test "safe_execute function" "safe_execute 'echo' 'test' 'hello'"
run_test "suggest_fixes function" "suggest_fixes 'MISSING_DEPENDENCY'"
run_test "cleanup_on_error function" "cleanup_on_error '/tmp/nonexistent'"
run_test "show_error_summary function" "show_error_summary 5 0 5 'test'"

# Test 5: Common Archive Operations
echo ""
echo "Testing Common Archive Operations..."
echo "-----------------------------------"

run_test "prepare_archive_environment function" "prepare_archive_environment 'extract' 'tar.gz' 4 0"
run_test "build_common_tar_options function" "build_common_tar_options 'extract' 'tar.gz' 0 4 1 0 ''"
run_test "validate_archive_common function" "validate_archive_common '/etc/passwd' 'extract' 'tar.gz' '' 0"
run_test "show_operation_progress function" "show_operation_progress 'extract' 'test.tar.gz' 'tar.gz' 1024 0 0 1 1"
run_test "show_operation_summary function" "show_operation_summary 'extract' 5 0 5 0"

# Test 6: Common File Operations
echo ""
echo "Testing Common File Operations..."
echo "--------------------------------"

# Create test files
echo "test content" > $temp_dir/test1.txt
echo "test content 2" > $temp_dir/test2.txt
mkdir -p $temp_dir/test_dir

run_test "collect_input_files function" "collect_input_files '$temp_dir/test1.txt' '$temp_dir/test2.txt' ''"
run_test "apply_file_filters function" "apply_file_filters '$temp_dir/test1.txt' '*.txt' ''"
run_test "validate_file_list function" "validate_file_list '$temp_dir/test1.txt' 'compress'"
run_test "calculate_total_size function" "calculate_total_size '$temp_dir/test1.txt' '$temp_dir/test2.txt'"
run_test "show_file_statistics function" "show_file_statistics '$temp_dir/test1.txt' 1024 0 0"
run_test "prepare_extraction_directory function" "prepare_extraction_directory '$temp_dir/extract' 0 0 0"
run_test "create_output_directory function" "create_output_directory '$temp_dir/output' 0"
run_test "generate_output_path function" "generate_output_path '$temp_dir/test.tar.gz' 0 0"
run_test "generate_extract_directory function" "generate_extract_directory '$temp_dir/test.tar.gz' '' 0 0"
run_test "analyze_archive_content function" "analyze_archive_content '$temp_dir'"
run_test "generate_checksum_file function" "generate_checksum_file '$temp_dir/test1.txt' 'sha256' 0"
run_test "verify_checksum_file function" "verify_checksum_file '$temp_dir/test1.txt' 'sha256'"
run_test "split_archive_file function" "split_archive_file '$temp_dir/test1.txt' '1K' 0"

# Test 7: Common Format Operations
echo ""
echo "Testing Common Format Operations..."
echo "----------------------------------"

run_test "detect_archive_format function" "detect_archive_format '/etc/passwd'"
run_test "validate_format_support function" "validate_format_support 'tar.gz' 'extract'"
run_test "check_format_dependencies function" "check_format_dependencies 'tar.gz' 'extract'"
run_test "select_smart_format function" "select_smart_format '$temp_dir'"
run_test "get_optimal_command function" "get_optimal_command 'gzip' 'extract' 0"
run_test "check_format_capabilities function" "check_format_capabilities 'zip'"
run_test "validate_format_options function" "validate_format_options 'zip' 0 0 4"
run_test "test_format_integrity function" "test_format_integrity '$temp_dir/test1.txt' 'gzip'"
run_test "list_format_contents function" "list_format_contents '$temp_dir/test1.txt' 'gzip'"

# Test 8: Integration Tests
echo ""
echo "Testing Integration Functions..."
echo "-------------------------------"

# Test format detection with real files
run_test_with_output "detect tar.gz format" "detect_format '$temp_dir/test1.txt'" "unknown"
run_test "validate archive with real file" "validate_archive '$temp_dir/test1.txt'"
run_test "get file size of real file" "get_file_size '$temp_dir/test1.txt'"
run_test "human size conversion" "human_size 1024"

# Test error handling with invalid inputs
run_test "handle missing file error" "handle_file_error '/nonexistent/file' 'test'"
run_test "handle missing command error" "handle_command_error 'nonexistent_command' 'test'"

# Test 9: Edge Cases
echo ""
echo "Testing Edge Cases..."
echo "--------------------"

run_test "empty file list validation" "validate_file_list '' 'compress'"
run_test "zero thread count" "resolve_threads 0"
run_test "negative thread count" "resolve_threads -1"
run_test "empty format normalization" "normalize_format ''"
run_test "unknown format detection" "detect_archive_format '/dev/null'"

# Test 10: Performance Tests
echo ""
echo "Testing Performance Functions..."
echo "-------------------------------"

run_test "optimal threads calculation" "optimal_threads 1048576"
run_test "can show progress check" "can_show_progress"
run_test "should show progress logic" "should_show_progress 1 0 10485760"

# Cleanup
cleanup

# Summary
echo ""
echo "Test Summary"
echo "============"
echo "Total tests: $test_count"
echo "Passed: $pass_count"
echo "Failed: $fail_count"

if test $fail_count -eq 0
    echo ""
    echo "🎉 All tests passed!"
    exit 0
else
    echo ""
    echo "❌ $fail_count test(s) failed!"
    exit 1
end