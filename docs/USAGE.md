# Fish Archive Manager - Complete Usage Guide

This comprehensive guide covers all features and usage patterns for Fish Archive Manager, a powerful archive management tool for the Fish shell.

## Table of Contents

- [Quick Start](#quick-start)
- [Command Overview](#command-overview)
- [Extract Command](#extract-command)
- [Compress Command](#compress-command)
- [Diagnostic Tool](#diagnostic-tool)
- [Automatic Format Detection](#automatic-format-detection)
- [Advanced Features](#advanced-features)
- [Configuration](#configuration)
- [Tips & Best Practices](#tips--best-practices)
- [Troubleshooting](#troubleshooting)

## Quick Start

```fish
# Extract an archive (automatic format detection)
extract file.tar.gz

# Create an archive with smart compression
compress backup.tar.zst ./mydata

# Check system capabilities
ext-doctor
```

## Command Overview

Fish Archive Manager provides three main commands:

| Command | Aliases | Purpose |
|---------|---------|---------|
| `extract` | - | Extract archives with smart format detection |
| `compress` | - | Create archives with intelligent compression |
| `doctor` | - | Diagnose system capabilities and configuration |

## Extract Command

The `extract` command intelligently extracts archives with automatic format detection.

### Basic Syntax

```fish
extract [OPTIONS] FILE...
```

### Automatic Format Detection

Fish Archive Manager automatically detects archive formats using:
1. **File extension analysis** - Recognizes .tar.gz, .zip, .7z, etc.
2. **MIME type detection** - Uses the `file` command for accurate identification
3. **Fallback extractors** - Attempts bsdtar or 7z for unknown formats

**Supported formats:**
- Compressed tar: `.tar.gz`, `.tar.bz2`, `.tar.xz`, `.tar.zst`, `.tar.lz4`, `.tar.lz`, `.tar.lzo`, `.tar.br`
- Archives: `.zip`, `.7z`, `.rar`
- Compressed files: `.gz`, `.bz2`, `.xz`, `.zst`, `.lz4`, `.lz`, `.lzo`, `.br`
- Disk images: `.iso`
- Package formats: `.deb`, `.rpm` (with bsdtar)
- Short names: `.tgz`, `.tbz2`, `.txz`, `.tzst`, `.tlz4`

### Options Reference

#### Basic Options

```fish
-d, --dest DIR          # Destination directory (default: derived from archive name)
-f, --force             # Overwrite existing files without prompting
-s, --strip NUM         # Strip NUM leading path components (tar archives)
-p, --password PASS     # Password for encrypted archives
-t, --threads NUM       # Number of threads for decompression
-q, --quiet             # Suppress non-error output
-v, --verbose           # Enable verbose output with detailed progress
-k, --keep              # Keep archive file after extraction (default behavior)
```

#### Advanced Options

```fish
--no-progress           # Disable progress indicators
--list                  # List archive contents without extracting
--test                  # Test archive integrity without extracting
--verify                # Verify archive with checksum if available
--overwrite             # Always overwrite (alias for --force)
--flat                  # Extract without preserving directory structure
--dry-run               # Show what would be done without executing
--backup                # Create backup of existing files before extraction
--checksum              # Generate checksum file after extraction
--help                  # Display help message
```

### Usage Examples

#### Basic Extraction

```fish
# Extract to default location (./filename/)
extract archive.tar.gz

# Extract to specific directory
extract -d /path/to/output archive.zip

# Extract multiple archives
extract *.tar.gz

# Extract with verbose output
extract -v large-archive.tar.xz
```

#### Working with Nested Archives

```fish
# Strip top-level directory (useful for GitHub releases)
extract --strip 1 project-v1.0.tar.gz

# Strip multiple levels
extract --strip 2 deeply/nested/archive.tar.xz
```

#### Encrypted Archives

```fish
# Extract password-protected archive
extract -p "mypassword" secure.zip

# Extract 7z with encryption
extract -p "secret123" encrypted.7z
```

#### Archive Inspection

```fish
# List contents without extracting
extract --list archive.tar.gz

# Test integrity
extract --test backup.zip

# Verify with checksum (looks for .sha256, .md5, .sha1 files)
extract --verify important-data.tar.xz
```

#### Multi-threaded Extraction

```fish
# Use specific thread count
extract -t 8 large-archive.tar.zst

# Use all available CPU cores
extract -t $(nproc) huge-file.tar.xz
```

#### Advanced Extraction

```fish
# Create backup before extracting to existing directory
extract --backup --force archive.zip

# Extract with checksum generation
extract --checksum data.tar.xz

# Dry run to preview extraction
extract --dry-run archive.tar.gz

# Extract without directory structure (flat)
extract --flat nested-archive.zip

# Quiet mode (only errors)
extract -q batch*.tar.gz
```

#### Batch Processing

```fish
# Extract all archives in directory
extract *.tar.gz *.zip

# Extract with progress tracking
for file in *.tar.xz
    extract -v $file
end
```

### Exit Codes

- `0` - Success (all archives extracted successfully)
- `1` - Partial failure (some archives failed)
- `2` - Invalid arguments or usage
- `127` - Missing required tools

## Compress Command

The `compress` command creates archives with smart format selection and optimization.

### Basic Syntax

```fish
compress [OPTIONS] OUTPUT [INPUT...]
```

### Smart Format Selection

Fish Archive Manager can automatically choose the best compression format:

```fish
# Automatically select optimal format
compress --smart output.auto ./mydata

# Detect format from output filename
compress backup.tar.zst ./data
```

**Selection logic:**
- **70%+ text files** → `tar.xz` (maximum compression)
- **30-70% text files** → `tar.gz` (balanced, compatible)
- **< 30% text files** → `tar.zst` (fast, good for binary)

### Options Reference

#### Basic Options

```fish
-F, --format FMT        # Archive format (tar, tar.gz, tar.xz, tar.zst, zip, 7z, auto)
-L, --level NUM         # Compression level (1-9, format-dependent)
-t, --threads NUM       # Number of threads for compression
-e, --encrypt           # Enable encryption (zip/7z only)
-p, --password PASS     # Password for encryption
-C, --chdir DIR         # Change to directory before adding files
-q, --quiet             # Suppress non-error output
-v, --verbose           # Enable verbose output
```

#### Filter Options

```fish
-i, --include-glob PAT  # Include only matching files (can be repeated)
-x, --exclude-glob PAT  # Exclude matching files (can be repeated)
```

#### Advanced Options

```fish
-u, --update            # Update existing archive (add/replace changed files)
-a, --append            # Append to existing archive
--no-progress           # Disable progress indicators
--smart                 # Automatically choose best format
--solid                 # Create solid archive (7z only - better compression)
--checksum              # Generate checksum file after creation
--split SIZE            # Split archive into parts (e.g., 100M, 1G)
--dry-run               # Show what would be done without executing
--help                  # Display help message
```

### Supported Formats

| Format | Description | Best For | Level Range |
|--------|-------------|----------|-------------|
| `tar` | Uncompressed | Preprocessing, piping | N/A |
| `tar.gz`, `tgz` | Gzip (balanced) | General purpose, compatibility | 1-9 |
| `tar.bz2`, `tbz2` | Bzip2 (high compression) | Long-term storage | 1-9 |
| `tar.xz`, `txz` | XZ (best for text) | Source code, logs, text-heavy | 0-9 |
| `tar.zst`, `tzst` | Zstd (fast & efficient) | Large datasets, modern systems | 1-19 |
| `tar.lz4`, `tlz4` | LZ4 (very fast) | Temporary archives, real-time | 1-12 |
| `tar.lz`, `tlz` | Lzip (high compression) | Scientific data | 1-9 |
| `tar.lzo`, `tzo` | LZO (fast) | Real-time compression | 1-9 |
| `tar.br`, `tbr` | Brotli (web-optimized) | Web assets | 1-11 |
| `zip` | Universal compatibility | Cross-platform sharing | 0-9 |
| `7z` | High compression | Secure backups, encryption | 0-9 |

### Usage Examples

#### Basic Compression

```fish
# Create tar.gz archive
compress backup.tar.gz ./mydata

# Create with specific format
compress -F tar.xz output.txz ./source

# Compress current directory
compress archive.tar.zst .
```

#### Smart Compression

```fish
# Auto-detect best format based on content
compress --smart intelligent-archive.auto ./mixed-data

# Let filename extension determine format
compress mybackup.tar.zst ./files
```

#### Compression Levels

```fish
# Fast compression (level 1-3)
compress -L 1 fast.tar.zst ./data

# Balanced compression (level 4-6, default: 6)
compress -L 6 balanced.tar.gz ./project

# Maximum compression (level 7-9)
compress -L 9 maximum.tar.xz ./sources
```

#### Multi-threaded Compression

```fish
# Use specific thread count
compress -t 8 -F tar.zst fast.tzst ./large-dir

# Use all CPU cores for maximum speed
compress -t $(nproc) -F tar.xz parallel.txz ./data

# Automatic parallel compression (pigz/pbzip2)
compress -F tar.gz auto-parallel.tgz ./files  # Uses pigz if available
```

#### Pattern Filtering

```fish
# Include specific patterns
compress -i '*.txt' -i '*.md' docs.zip ./project

# Exclude specific patterns
compress -x '*.tmp' -x '*.log' clean.tar.gz .

# Complex filtering
compress -x '*.cache' -x '.git/*' -x 'node_modules/*' release.tgz ./app

# Multiple exclude patterns
compress \
    -x '*.pyc' \
    -x '__pycache__/*' \
    -x '.git/*' \
    -x '*.log' \
    clean-python.tar.xz ./project
```

#### Encrypted Archives

```fish
# Create encrypted ZIP
compress -e -p "strongpassword" secure.zip ./sensitive

# Create encrypted 7z with solid compression
compress --solid -e -p "secret123" -F 7z backup.7z ./data

# Prompt for password (more secure - not stored in history)
compress -e secure.zip ./files  # Will prompt for password
```

#### Update and Append

```fish
# Update existing archive (replace changed files)
compress -u existing.tar.gz ./newfiles

# Append to existing archive
compress -a archive.tar.gz new-file.txt
```

#### Advanced Features

```fish
# Change directory before compressing
compress -C /var/www -F tar.xz web-backup.txz html/

# Generate checksum after compression
compress --checksum verified.tar.xz ./important-data

# Split large archive into parts
compress --split 100M large.zip ./huge-directory
# Creates: large.zip.parta, large.zip.partb, etc.

# Dry run to preview
compress --dry-run -v output.tar.zst ./data

# Solid 7z archive (better compression ratio)
compress --solid -F 7z -L 9 ultra-compressed.7z ./files
```

#### Practical Workflows

```fish
# Daily backup with date stamp
compress -F tar.zst backup-$(date +%Y%m%d).tzst ~/Documents

# Source code release (exclude development files)
compress -F tar.xz \
    -x '.git/*' \
    -x 'node_modules/*' \
    -x '__pycache__/*' \
    -x '*.pyc' \
    -x '.env' \
    project-v1.0.tar.xz ./project

# Website backup with compression stats
compress -v --checksum -F tar.zst \
    -x '*.log' \
    -x 'cache/*' \
    website-backup.tzst /var/www

# Multi-part backup for DVD burning
compress --split 4G -F 7z dvd-backup.7z ~/large-dataset
```

### Compression Performance Tips

#### By File Type

```fish
# Text-heavy content (source code, logs, configs)
compress -F tar.xz -L 9 -t $(nproc) source.txz ./code

# Binary/multimedia content (images, videos, executables)
compress -F tar.zst -L 3 -t $(nproc) media.tzst ./files

# Mixed content (documents, some images)
compress -F tar.gz -L 6 mixed.tgz ./documents

# Already compressed files (zip, jpg, mp3)
compress -F tar backup.tar ./files  # No additional compression needed
```

#### By Use Case

```fish
# Temporary archives (speed priority)
compress -F tar.lz4 -L 1 temp.tlz4 ./cache

# Long-term storage (compression priority)
compress -F tar.xz -L 9 archive.txz ./oldfiles

# Network transfer (balanced)
compress -F tar.zst -L 6 transfer.tzst ./data

# Cross-platform sharing (compatibility)
compress -F zip -L 6 share.zip ./files
```

## Diagnostic Tool

The `doctor` command checks your system's archive handling capabilities.

### Basic Syntax

```fish
doctor [OPTIONS]
```

### Options

```fish
-v, --verbose           # Show detailed system information
-q, --quiet             # Only show errors
--fix                   # Suggest fixes for missing tools
--export                # Export diagnostic report to file
--help                  # Display help message
```

### Usage Examples

```fish
# Basic system check
doctor

# Detailed diagnostic with all information
doctor -v

# Get installation recommendations
doctor --fix

# Export report to file
doctor --export
# Creates: fish-archive-diagnostic-YYYYMMDD_HHMMSS.txt

# Quiet check (only errors)
doctor -q
```

### Understanding the Output

The diagnostic report includes:

1. **Required Tools** - Core functionality (file, tar, gzip, etc.)
2. **Important Tools** - Extended functionality (7z, lz4, bsdtar)
3. **Optional Tools** - Performance enhancements (pigz, pbzip2, pv)
4. **Configuration** - Current environment variables
5. **System Information** - OS, CPU, fish version (verbose mode)
6. **Format Support** - Available archive formats (verbose mode)
7. **Performance Features** - Parallel compression availability (verbose mode)

## Automatic Format Detection

### How It Works

Fish Archive Manager uses a multi-stage detection process:

#### 1. Extension-Based Detection

```fish
# Recognizes standard extensions
extract file.tar.gz      # → tar.gz format
extract archive.zip      # → zip format
extract data.7z          # → 7z format

# Recognizes short forms
extract backup.tgz       # → tar.gz format
extract logs.tbz2        # → tar.bz2 format
extract source.txz       # → tar.xz format
```

#### 2. MIME Type Detection

When extension is ambiguous or missing:

```fish
# Uses 'file' command for accurate detection
extract mysterious-file  # Analyzes file header
```

#### 3. Fallback Extractors

For unknown formats:

```fish
# Tries bsdtar (supports many formats)
extract unusual.archive

# Falls back to 7z (wide format support)
extract unknown.file
```

### Smart Compression Selection

For the `compress` command with `--smart` or `auto` format:

```fish
# Analyzes input content
compress --smart output.auto ./data

# Selection process:
# 1. Samples files (up to 200 files for performance)
# 2. Checks MIME types (text vs binary)
# 3. Calculates text ratio
# 4. Chooses optimal format:
#    - High text (70%+) → tar.xz (best compression)
#    - Mixed (30-70%) → tar.gz (balanced)
#    - Binary-heavy (<30%) → tar.zst (fast)
```

## Advanced Features

### Progress Indicators

When `pv` is installed, Fish Archive Manager shows real-time progress:

```fish
# Automatic progress bars for large files (>10MB)
extract large-archive.tar.gz
# Output: 45.2MiB 0:00:12 [3.76MiB/s] [=========>  ] 45% ETA 0:00:15

# Control progress display
set -Ux FISH_EXTRACTOR_PROGRESS always  # Always show
set -Ux FISH_EXTRACTOR_PROGRESS never   # Never show
set -Ux FISH_EXTRACTOR_PROGRESS auto    # Auto (default)
```

### Checksum Verification

```fish
# Extract with checksum verification
extract --verify archive.tar.xz
# Looks for: archive.tar.xz.sha256, .md5, or .sha1

# Generate checksum when compressing
compress --checksum backup.tar.xz ./data
# Creates: backup.tar.xz.sha256

# Generate checksum when extracting
extract --checksum archive.tar.gz
# Creates: archive.sha256 with checksums of extracted files
```

### Archive Splitting

```fish
# Split large archive into manageable parts
compress --split 100M large.zip ./huge-directory
# Creates: large.zip.parta, large.zip.partb, large.zip.partc, ...
# Also creates: large.zip.join.sh (script to reassemble)

# Reassemble split archive
cat large.zip.part* > large.zip
# Or use the generated script:
./large.zip.join.sh
```

### Backup Before Extraction

```fish
# Create timestamped backup of existing directory
extract --backup --force archive.zip
# If ./archive/ exists, creates ./archive.backup.20231215_143022/

# Then extracts to ./archive/
```

### Batch Processing

```fish
# Extract multiple archives with summary
extract archive1.tar.gz archive2.zip archive3.7z
# Output:
# Processing 3 archive(s)...
# [1/3] Extracting: archive1.tar.gz
# ✓ Extracted: archive1.tar.gz
# [2/3] Extracting: archive2.zip
# ✓ Extracted: archive2.zip
# [3/3] Extracting: archive3.7z
# ✓ Extracted: archive3.7z
# ✓ All extractions completed successfully (3/3)
```

## Configuration

### Environment Variables

Configure Fish Archive Manager in your `~/.config/fish/config.fish`:

```fish
# Color output: auto (default), always, never
set -Ux FISH_EXTRACTOR_COLOR auto

# Progress indicators: auto (default), always, never
set -Ux FISH_EXTRACTOR_PROGRESS auto

# Default thread count (default: CPU cores)
set -Ux FISH_EXTRACTOR_DEFAULT_THREADS 8

# Logging level: debug, info (default), warn, error
set -Ux FISH_EXTRACTOR_LOG_LEVEL info

# Default format for smart selection: auto (default)
set -Ux FISH_EXTRACTOR_DEFAULT_FORMAT auto
```

### Custom Aliases

Add convenient shortcuts in `~/.config/fish/config.fish`:

```fish
# Short aliases
function x --wraps=extract
    extract $argv
end

function c --wraps=compress
    compress $argv
end

# Specialized aliases
function extract-here --wraps=extract
    extract -d . $argv
end

function compress-max --wraps=compress
    compress -L 9 $argv
end
```

## Tips & Best Practices

### Choosing Compression Format

```fish
# For maximum compression (slower)
compress -F tar.xz -L 9 archive.txz ./data

# For maximum speed (larger file)
compress -F tar.lz4 -L 1 archive.tlz4 ./data

# For balanced performance
compress -F tar.zst -L 6 archive.tzst ./data  # Recommended default

# For compatibility (all systems)
compress -F zip archive.zip ./data
```

### Performance Optimization

```fish
# Use parallel compression tools when available
# Fish Extractor automatically uses:
# - pigz instead of gzip
# - pbzip2 instead of bzip2
# - multi-threaded xz/zstd

# Install for best performance:
# Arch: pacman -S pigz pbzip2 pv
# Debian: apt-get install pigz pbzip2 pv
# macOS: brew install pigz pbzip2 pv

# Verify parallel tools are available
ext-doctor -v
```

### Security Best Practices

```fish
# Don't put passwords in command history
compress -e secure.zip ./files  # Will prompt for password

# For scripts, use environment variable
set -x ARCHIVE_PASSWORD "secret"
compress -p $ARCHIVE_PASSWORD secure.zip ./files
set -e ARCHIVE_PASSWORD

# Verify archive integrity before extraction
extract --test untrusted.tar.gz
extract --verify trusted.tar.gz
```

### Backup Workflows

```fish
# Daily incremental backup
compress -u -F tar.zst daily-backup.tzst ~/Documents

# Weekly full backup with date
compress -F tar.zst weekly-backup-$(date +%Y-W%U).tzst ~/

# Exclude common unnecessary files
compress -F tar.zst \
    -x '*.tmp' \
    -x '*.cache' \
    -x '.git/*' \
    -x 'node_modules/*' \
    -x '__pycache__/*' \
    clean-backup.tzst ~/project
```

### Development Workflows

```fish
# Create release archive
compress -F tar.xz \
    -x '.git/*' \
    -x '*.log' \
    -x '__pycache__/*' \
    -x 'node_modules/*' \
    --checksum \
    project-v1.0.0.tar.xz ./project

# Quick test archive (very fast)
compress -F tar.lz4 -L 1 test.tlz4 ./code

# Extract GitHub release (strip wrapper directory)
extract --strip 1 project-main.tar.gz
```

## Troubleshooting

### Common Issues

#### "Missing required commands"

```fish
# Check what's missing
ext-doctor

# Install missing tools
ext-doctor --fix  # Shows installation commands

# Example for Arch Linux
sudo pacman -S tar gzip bzip2 xz zstd unzip zip p7zip

# Example for Ubuntu/Debian
sudo apt-get install tar gzip bzip2 xz-utils zstd unzip zip p7zip-full
```

#### "Unknown format" or "Failed to extract"

```fish
# Test archive integrity
extract --test problematic.tar.gz

# Try verbose mode for more details
extract -v problematic.tar.gz

# List contents to verify format
extract --list archive.???

# Check if format is supported
ext-doctor -v
```

#### "Permission denied"

```fish
# Extract to writable location
extract -d ~/temp archive.tar.gz

# Check file permissions
ls -la archive.tar.gz

# Extract with verbose output
extract -v archive.tar.gz
```

#### Slow compression

```fish
# Use faster format
compress -F tar.zst -L 3 fast.tzst ./data  # Instead of tar.xz

# Use more threads
compress -t $(nproc) -F tar.zst parallel.tzst ./data

# Install parallel compression tools
ext-doctor --fix
sudo pacman -S pigz pbzip2  # Arch
sudo apt-get install pigz pbzip2  # Ubuntu
```

#### Archive too large

```fish
# Split into smaller parts
compress --split 100M large.zip ./huge-dir

# Use better compression
compress -F tar.xz -L 9 smaller.txz ./data

# Exclude large unnecessary files
compress -x '*.mp4' -x '*.iso' smaller.tar.zst ./mixed
```

### Debug Mode

```fish
# Enable debug logging
set -Ux FISH_EXTRACTOR_LOG_LEVEL debug

# Run command with verbose output
extract -v problematic-archive.tar.gz

# Check command output
extract --dry-run test.tar.gz

# Reset logging level
set -Ux FISH_EXTRACTOR_LOG_LEVEL info
```

### Getting Help

```fish
# Show command help
extract --help
compress --help
ext-doctor --help

# Check system status
ext-doctor -v

# Export diagnostic report
ext-doctor --export

# Check Fish Archive Manager version
cat ~/.config/fish/fish-archive/VERSION
```

## Exit Codes

All commands return standard exit codes:

- `0` - Success
- `1` - General error or partial failure
- `2` - Invalid arguments or usage error
- `127` - Required command not found

```fish
# Use in scripts
if extract archive.tar.gz
    echo "Extraction successful"
else
    echo "Extraction failed with code: $status"
end

# Multiple archives - returns failure if any fail
extract *.tar.gz
or echo "Some extractions failed"
```

---

**For more information:**
- [README.md](README.md) - Overview and installation
- [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md) - Code organization
- [CONTRIBUTING.md](CONTRIBUTING.md) - Development guide
- [Fish shell documentation](https://fishshell.com/docs/current/)
