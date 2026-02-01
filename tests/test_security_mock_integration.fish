# Test Security Integration (Mocked)

source functions/extract.fish
source functions/common/security_helpers.fish

# Mock logging to capture output
function __fish_archive_log
    echo "LOG: $argv"
end

# Mock listing to return a malicious file
function __fish_pack_list_archive_members
    echo "safe_file.txt"
    echo "../evil_file.txt"
end

# Mock dependencies
function __fish_archive_get_file_size; echo 100; end
# Validate archive usually checks existence, we will create file but also mock this just in case logic is complex
function __fish_archive_validate_archive; return 0; end
function __fish_archive_detect_format; echo "tar"; end
function __fish_archive_prepare_extraction_args; echo "true"; end
function __fish_pack_safe_exec; echo "EXEC: $argv"; end
function __fish_archive_default_extract_dir; echo "output"; end
function __fish_archive_handle_destination_naming; echo "output"; end
# validate_inputs checks existence. We will create the file.

touch fake_archive.tar

# Run extract against a fake archive
echo "Running extraction..."
# We expect the loop to process 'fake_archive.tar'
extract --dry-run fake_archive.tar > output.log 2>&1

echo "Output log content:"
cat output.log

if grep -q "Archive contains unsafe paths" output.log
    echo "PASS: Detection triggered."
else
    echo "FAIL: Detection missed."
    exit 1
end

rm fake_archive.tar output.log