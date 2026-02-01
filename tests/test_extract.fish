# Test Extract

source functions/extract.fish
source functions/compress.fish

# Prepare
mkdir -p test_extract_dir
echo "extract me" > test_extract_dir/file.txt
compress -q test_archive.tar.gz test_extract_dir/

# Test extraction
if extract -q -d output_dir test_archive.tar.gz
    if test -f output_dir/test_extract_dir/file.txt
        echo "✓ extract success"
    else
        echo "✗ extract failed (file missing)"
        ls -R output_dir
        exit 1
    end
else
    echo "✗ extract command failed"
    exit 1
end

# Cleanup
rm -rf test_extract_dir output_dir test_archive.tar.gz

exit 0
