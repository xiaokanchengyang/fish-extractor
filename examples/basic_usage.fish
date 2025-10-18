# Basic Usage Examples for Fish Archive Manager
# This file demonstrates common usage patterns

# ============================================================================
# Basic Extraction Examples
# ============================================================================

# Extract a single archive
extract archive.tar.gz

# Extract to specific directory
extract -d /path/to/destination archive.zip

# Extract multiple archives
extract *.tar.gz

# List contents without extracting
extract --list archive.zip

# Test archive integrity
extract --test backup.tar.gz

# Extract with verbose output
extract -v large-archive.tar.xz

# Extract with progress bar
extract large-file.tar.zst

# ============================================================================
# Basic Compression Examples
# ============================================================================

# Compress current directory
compress backup.tar.gz .

# Compress specific files
compress archive.zip file1.txt file2.txt

# Compress with specific format
compress -F tar.xz logs.tar.xz /var/log

# Compress with maximum compression
compress -L 9 backup.tar.bz2 ./data

# Compress with smart format selection
compress --smart output.auto ./project

# ============================================================================
# Advanced Extraction Examples
# ============================================================================

# Extract with password
extract -p secret encrypted.7z

# Extract and strip top-level directory
extract --strip 1 dist.tar.xz

# Extract with backup
extract --backup --force existing.zip

# Extract with checksum generation
extract --checksum important.tar.gz

# Extract with auto-rename
extract --auto-rename archive.zip

# Extract with timestamp
extract --timestamp backup.tar.gz

# Extract with custom thread count
extract -t 8 large-archive.tar.zst

# ============================================================================
# Advanced Compression Examples
# ============================================================================

# Compress with exclusions
compress -x '*.tmp' -x '*.log' clean.tar.gz .

# Compress with inclusions
compress -i '*.txt' -i '*.md' docs.zip .

# Compress with encryption
compress -e -p password secure.zip sensitive/

# Compress with solid 7z
compress --solid -F 7z backup.7z data/

# Compress with checksum
compress --checksum backup.tar.xz data/

# Compress with splitting
compress --split 100M large.zip huge-files/

# Compress with update
compress -u existing.tar.gz newfile.txt

# Compress with custom thread count
compress -t 16 -F tar.zst fast.tzst large-dir/

# ============================================================================
# Workflow Examples
# ============================================================================

# Daily backup workflow
compress -F tar.zst backup-$(date +%Y%m%d).tzst ~/Documents

# Development package workflow
compress -F tar.xz -x 'node_modules/*' -x '__pycache__/*' release.txz .

# Incremental backup workflow
compress -u backup.tar.zst ~/Documents

# Archive verification workflow
extract --test archive.tar.gz && extract archive.tar.gz

# Batch processing workflow
for file in *.tar.gz
    extract --test "$file" && extract "$file"
end

# ============================================================================
# Configuration Examples
# ============================================================================

# Set environment variables in ~/.config/fish/config.fish
set -Ux FISH_ARCHIVE_COLOR auto
set -Ux FISH_ARCHIVE_PROGRESS auto
set -Ux FISH_ARCHIVE_DEFAULT_THREADS 8
set -Ux FISH_ARCHIVE_LOG_LEVEL info
set -Ux FISH_ARCHIVE_DEFAULT_FORMAT auto

# ============================================================================
# Diagnostic Examples
# ============================================================================

# Check system capabilities
doctor

# Get detailed system information
doctor -v

# Get installation suggestions
doctor --fix

# Export diagnostic report
doctor --export

# Quiet mode (only errors)
doctor -q