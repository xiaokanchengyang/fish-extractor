# Fish Pack - Complete Usage Guide

This comprehensive guide covers all features and usage patterns for Fish Pack, a powerful, professional-grade archive management tool for the Fish shell.

## Table of Contents

- [Quick Start](#quick-start)
- [Command Overview](#command-overview)
- [Extract Command](#extract-command)
- [Compress Command](#compress-command)
- [Task Queue](#task-queue)
- [System Check](#system-check)
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

# Batch queue (parallel)
archqueue --parallel 4 \
  'compress::out.tzst::src/' \
  'extract::dist.zip::./out'

# Check system capabilities
check
```

## Command Overview

Fish Pack provides four main commands:

| Command | Purpose |
|---------|---------|
| `extract` | Extract archives with smart format detection |
| `compress` | Create archives with intelligent compression |
| `archqueue` | Batch queue for compress/extract tasks (parallel/sequential) |
| `check` | Diagnose system capabilities and configuration |

## Extract Command

The `extract` command intelligently extracts archives with automatic format detection.

### Basic Syntax

```fish
extract [OPTIONS] FILE...
```

### Automatic Format Detection

Fish Pack automatically detects archive formats using:
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

## Compress Command

The `compress` command creates archives with smart format selection and optimization.

### Basic Syntax

```fish
compress [OPTIONS] OUTPUT [INPUT...]
```

### Smart Format Selection

Fish Pack can automatically choose the best compression format:

```fish
# Automatically select optimal format
compress --smart output.auto ./mydata

# Detect format from output filename
compress backup.tar.zst ./data
```

**Selection logic:**
- **70%+ text files** → `tar.xz` (maximum compression)
- **30-70% text files or large datasets** → `tar.gz` (pigz if available)
- **Binary-heavy or small/medium datasets** → `tar.zst` (fast, good for binary)

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

## Task Queue (Archqueue)

The `archqueue` tool runs batch compress/extract tasks sequentially or in parallel.

### Syntax

```fish
archqueue [--parallel N|--sequential] [--stop-on-error] TASK...
```

- **compress task**: `compress::OUTPUT::INPUTS...`
- **extract task**: `extract::FILE::DEST`

### Examples

```fish
# Sequential (default)
archqueue \
  'compress::backup.tzst::src/ docs/' \
  'extract::release.zip::dist'

# Parallel with up to 3 concurrent tasks
archqueue --parallel 3 \
  'compress::a.tzst::a/' \
  'compress::b.tzst::b/' \
  'extract::x.zip::xdir' \
  'extract::y.tar.gz::ydir'

# Stop on first error
archqueue --parallel 2 --stop-on-error \
  'compress::ok.tzst::ok/' \
  'extract::maybe-bad.zip::out'
```

Completion support is included for `archqueue` options and task kinds.

## System Check

The `check` command (formerly `doctor`) checks your system's archive handling capabilities.

### Usage Examples

```fish
# Basic system check
check

# Detailed diagnostic with all information
check -v

# Get installation recommendations
check --fix
```

## Configuration

### Environment Variables

Configure Fish Pack in your `~/.config/fish/config.fish`:

```fish
# Color output: auto (default), always, never
set -Ux FISH_ARCHIVE_COLOR auto

# Progress indicators: auto (default), always, never
set -Ux FISH_ARCHIVE_PROGRESS auto

# Default thread count (default: CPU cores)
set -Ux FISH_ARCHIVE_DEFAULT_THREADS 8

# Logging level: debug, info (default), warn, error
set -Ux FISH_ARCHIVE_LOG_LEVEL info

# Default format for smart selection: auto (default)
set -Ux FISH_ARCHIVE_DEFAULT_FORMAT auto
```

---

**Need more help?** Check the [GitHub Issues](https://github.com/xiaokanchengyang/fish-pack/issues).