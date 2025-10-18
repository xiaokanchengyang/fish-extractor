# Fish Archive Manager

[![Fish Shell](https://img.shields.io/badge/fish-4.12%2B-blue)](https://fishshell.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-3.0.0-green.svg)](https://github.com/your-username/fish-archive)

**Fish Archive Manager** is a professional-grade archive management tool for the [fish shell](https://fishshell.com/). It provides powerful, intuitive commands for extracting and compressing archives with smart format detection, parallel processing, and comprehensive options.

[English](README.md) | [简体中文](README_CN.md)

## ✨ Features

- 🎯 **Smart Format Detection**: Automatically detects archive formats and chooses optimal compression
- 🚀 **High Performance**: Multi-threaded compression/decompression with optimized algorithms
- 📦 **Extensive Format Support**: 25+ formats including tar, gzip, bzip2, xz, zstd, lz4, zip, 7z, rar, iso, and more
- 🎨 **Beautiful Output**: Colorized messages, progress bars, and detailed statistics
- 🔐 **Encryption Support**: Password-protected archives for zip and 7z formats
- 🧪 **Testing & Verification**: Built-in integrity checking and checksum verification
- 🔧 **Highly Configurable**: Environment variables for customization
- 📝 **Comprehensive Help**: Detailed usage information and examples
- 🎓 **Intelligent Completions**: Context-aware tab completions
- 💾 **Backup Support**: Automatic backup before extraction
- ✂️ **Archive Splitting**: Split large archives into manageable parts
- 📊 **Batch Processing**: Process multiple archives efficiently

## 📋 Requirements

### Minimum Requirements (fish 4.12+)
- `fish` >= 4.12
- `file` (MIME type detection)
- `tar`, `gzip` (basic functionality)

### Recommended Packages
```bash
# Arch Linux / Manjaro
pacman -S file tar gzip bzip2 xz zstd lz4 unzip zip p7zip bsdtar

# Ubuntu / Debian
apt-get install file tar gzip bzip2 xz-utils zstd liblz4-tool unzip zip p7zip-full libarchive-tools

# macOS (Homebrew)
brew install gnu-tar gzip bzip2 xz zstd lz4 p7zip libarchive

# Optional: Enhanced performance
pacman -S unrar pv lzip lzop brotli pigz pbzip2  # Arch
apt-get install unrar pv lzip lzop brotli pigz pbzip2  # Debian/Ubuntu
brew install unrar pv lzip lzop brotli pigz pbzip2  # macOS
```

### Feature Matrix

| Format       | Extract | Compress | Test | Threads | Encryption |
|--------------|---------|----------|------|---------|------------|
| tar          | ✓       | ✓        | ✓    | -       | -          |
| tar.gz/tgz   | ✓       | ✓        | ✓    | pigz    | -          |
| tar.bz2/tbz2 | ✓       | ✓        | ✓    | pbzip2  | -          |
| tar.xz/txz   | ✓       | ✓        | ✓    | ✓       | -          |
| tar.zst/tzst | ✓       | ✓        | ✓    | ✓       | -          |
| tar.lz4/tlz4 | ✓       | ✓        | ✓    | ✓       | -          |
| tar.lz/tlz   | ✓       | ✓        | ✓    | -       | -          |
| tar.lzo/tzo  | ✓       | ✓        | -    | -       | -          |
| tar.br/tbr   | ✓       | ✓        | -    | -       | -          |
| zip          | ✓       | ✓        | ✓    | -       | ✓          |
| 7z           | ✓       | ✓        | ✓    | ✓       | ✓          |
| rar          | ✓       | -        | ✓    | -       | ✓          |
| gz, bz2, xz  | ✓       | -        | ✓    | ✓       | -          |
| zst, lz4     | ✓       | -        | ✓    | ✓       | -          |
| iso          | ✓       | -        | -    | -       | -          |
| deb, rpm     | ✓       | -        | -    | -       | -          |

## 🚀 Installation

### Using [Fisher](https://github.com/jorgebucaran/fisher) (Recommended)

```fish
fisher install your-username/fish-archive
```

### Manual Installation

```fish
git clone https://github.com/your-username/fish-archive ~/.config/fish/fish-archive
ln -sf ~/.config/fish/fish-archive/functions/*.fish ~/.config/fish/functions/
ln -sf ~/.config/fish/fish-archive/completions/*.fish ~/.config/fish/completions/
ln -sf ~/.config/fish/fish-archive/conf.d/*.fish ~/.config/fish/conf.d/
```

### Verify Installation

```fish
doctor
```

## 📖 Usage

### Archive Extraction (`extract`)

Extract archives with intelligent format detection:

```fish
# Basic extraction
extract file.tar.gz                      # Extract to ./file/

# Specify destination
extract -d output/ archive.zip           # Extract to ./output/

# Strip leading directories (useful for nested archives)
extract --strip 1 dist.tar.xz            # Remove top-level directory

# Extract encrypted archives
extract -p secret encrypted.7z           # Provide password

# List contents without extracting
extract --list archive.zip               # Preview contents

# Test integrity
extract --test backup.tar.gz             # Verify archive is valid

# Verify with checksum
extract --verify data.tar.xz             # Check integrity and checksum

# Extract multiple archives
extract *.tar.gz                         # Extract all .tar.gz files

# Parallel extraction with custom threads
extract -t 16 large-archive.tar.zst      # Use 16 threads

# Create backup before extraction
extract --backup --force archive.zip     # Backup existing directory

# Extract with checksum generation
extract --checksum important.txz         # Generate sha256 checksum

# Auto-rename if destination exists
extract --auto-rename archive.zip        # Creates archive-1, archive-2, etc.

# Add timestamp to extraction directory
extract --timestamp backup.tar.gz        # Creates backup-20231215_143022/

# Verbose output
extract -v complicated.7z                # Show detailed progress
```

#### Options

```
-d, --dest DIR          Destination directory (default: derived from archive)
-f, --force             Overwrite existing files
-s, --strip NUM         Strip NUM leading path components
-p, --password PASS     Password for encrypted archives
-t, --threads NUM       Thread count for decompression
-q, --quiet             Suppress non-error output
-v, --verbose           Detailed output
-k, --keep              Keep archive after extraction
    --no-progress       Disable progress indicators
    --list              List contents only
    --test              Test archive integrity
    --verify            Verify with checksum
    --flat              Extract without directory structure
    --backup            Create backup before extraction
    --checksum          Generate checksum file
    --dry-run           Show what would be done
    --help              Display help
```

### Archive Compression (`compress`)

Create archives with smart format selection:

```fish
# Basic compression
compress backup.tar.zst ./data           # Fast compression with zstd

# Maximum compression
compress -F tar.xz -L 9 logs.tar.xz /var/log

# Smart format (auto-detect best compression)
compress --smart output.auto ./project

# Create encrypted archive
compress -e -p secret secure.zip docs/

# Exclude patterns
compress -x '*.tmp' -x '*.log' clean.tgz .

# Include only specific files
compress -i '*.txt' -i '*.md' docs.zip .

# Update existing archive
compress -u existing.tar.gz newfile.txt

# Multi-threaded compression
compress -t 16 -F tar.zst fast.tzst large-dir/

# Change directory before archiving
compress -C /var/www -F tar.xz web-backup.txz html/

# Solid 7z archive (better compression)
compress --solid -F 7z backup.7z data/

# Create with checksum
compress --checksum backup.tar.xz data/

# Split large archive
compress --split 100M large.zip huge-files/

# Add timestamp to archive name
compress --timestamp backup.tar.zst ./data  # Creates backup-20231215_143022.tar.zst

# Auto-rename if file exists
compress --auto-rename backup.tar.gz ./data  # Creates backup-1.tar.gz if backup.tar.gz exists

# Verbose with custom level
compress -v -L 7 -F tar.xz archive.txz files/
```

#### Options

```
-F, --format FMT        Archive format (see formats below)
-L, --level NUM         Compression level (1-9, format-dependent)
-t, --threads NUM       Thread count for compression
-e, --encrypt           Enable encryption (zip/7z)
-p, --password PASS     Encryption password
-C, --chdir DIR         Change to directory before adding files
-i, --include-glob PAT  Include only matching files (repeatable)
-x, --exclude-glob PAT  Exclude matching files (repeatable)
-u, --update            Update existing archive
-a, --append            Append to existing archive
-q, --quiet             Suppress non-error output
-v, --verbose           Detailed output
    --no-progress       Disable progress indicators
    --smart             Auto-select best format
    --solid             Solid archive (7z only)
    --checksum          Generate checksum file
    --split SIZE        Split into parts (e.g., 100M, 1G)
    --dry-run           Show what would be done
    --help              Display help
```

#### Supported Formats

| Format          | Description                                     | Best For                |
|-----------------|-------------------------------------------------|-------------------------|
| `tar`           | Uncompressed tar                                | Preprocessing           |
| `tar.gz`, `tgz` | Gzip compression (balanced)                     | General purpose         |
| `tar.bz2`, `tbz2` | Bzip2 (high compression, slow)                | Long-term storage       |
| `tar.xz`, `txz` | XZ (best compression for text)                  | Source code, logs       |
| `tar.zst`, `tzst` | Zstd (fast, good compression)                 | Large datasets          |
| `tar.lz4`, `tlz4` | LZ4 (very fast, lower compression)            | Temporary archives      |
| `tar.lz`, `tlz` | Lzip (high compression)                         | Scientific data         |
| `tar.lzo`, `tzo` | LZO (fast)                                     | Real-time compression   |
| `tar.br`, `tbr` | Brotli (web-optimized)                          | Web assets              |
| `zip`           | ZIP (universal compatibility)                   | Cross-platform sharing  |
| `7z`            | 7-Zip (high compression, encryption)            | Secure backups          |
| `auto`          | Automatically choose best                       | Smart default           |

### Environment Diagnostics (`doctor`)

Check your system's archive handling capabilities:

```fish
# Basic check
doctor

# Detailed system information
doctor -v

# Get installation suggestions
doctor --fix

# Export diagnostic report
doctor --export

# Quiet mode (only errors)
doctor -q
```

## ⚙️ Configuration

Configure Fish Archive Manager by setting environment variables (e.g., in `~/.config/fish/config.fish`):

```fish
# Color output: auto (default), always, never
set -Ux FISH_ARCHIVE_COLOR auto

# Progress indicators: auto (default), always, never
set -Ux FISH_ARCHIVE_PROGRESS auto

# Default thread count (default: CPU cores)
set -Ux FISH_ARCHIVE_DEFAULT_THREADS 8

# Logging level: debug, info (default), warn, error
set -Ux FISH_ARCHIVE_LOG_LEVEL info

# Default format for smart selection
set -Ux FISH_ARCHIVE_DEFAULT_FORMAT auto
```

## 🎯 Smart Format Selection

Fish Archive Manager can automatically choose the best compression format based on your data:

```fish
compress --smart output.auto ./mydata
```

**Selection Logic:**
- **70%+ text files** → `tar.xz` (maximum compression for text)
- **30-70% text files** → `tar.gz` (balanced, compatible)
- **<30% text files** → `tar.zst` (fast, good for binary data)

## 💡 Tips & Best Practices

### Performance Optimization

```fish
# Use zstd for large binary files (fast)
compress -F tar.zst -t $(nproc) backup.tzst /large/dataset

# Use xz for text-heavy content (best compression)
compress -F tar.xz -t $(nproc) source.txz /code

# Use lz4 for temporary archives (very fast)
compress -F tar.lz4 temp.tlz4 /tmp/data
```

### Compression Level Guide

- **Level 1-3**: Fast compression, larger files (good for temporary archives)
- **Level 4-6**: Balanced (recommended for most use cases)
- **Level 7-9**: Maximum compression, slower (good for long-term storage)

### Secure Archives

```fish
# Create encrypted ZIP
compress -e -p "strong-password" secure.zip sensitive/

# Create encrypted 7z with solid compression
compress --solid -e -p "strong-password" -F 7z backup.7z data/
```

### Working with Large Archives

```fish
# Show progress with pv
extract large-archive.tar.zst  # Progress bar appears automatically

# Use multiple threads
extract -t 16 huge-file.tar.xz

# Test before extracting
extract --test archive.7z && extract archive.7z

# Split large archive
compress --split 100M large.zip huge-files/
```

### Backup Workflows

```fish
# Daily backup with date
compress -F tar.zst backup-$(date +%Y%m%d).tzst ~/Documents

# Incremental backup (update mode)
compress -u backup.tar.zst ~/Documents

# Exclude cache and temp files
compress -x '*.cache' -x '*.tmp' -x '.git/*' clean-backup.tgz ~/project
```

### Development Workflows

```fish
# Package source code
compress -F tar.xz -x 'node_modules/*' -x '__pycache__/*' release.txz .

# Create distributable archive with checksum
compress --smart --checksum -x '*.log' -x '.env' dist.auto ./app

# Extract and verify
extract --verify --test release.txz && extract release.txz
```

## 🔧 Troubleshooting

### Missing Tools

```fish
doctor --fix  # Shows installation commands
```

### Extraction Fails

```fish
# Test integrity first
extract --test problematic.tar.gz

# Try verbose mode
extract -v problematic.tar.gz

# Check available formats
doctor -v
```

### Compression Issues

```fish
# Verify inputs exist
compress --dry-run output.tar.zst input/

# Check format support
doctor
```

## 🔄 Comparison with Other Tools

| Feature                | Fish Archive Manager | `tar` + `*` | `atool` | `dtrx` |
|------------------------|---------------------|-------------|---------|--------|
| Smart format detection | ✓                   | -           | ✓       | ✓      |
| Multi-threading        | ✓                   | Manual      | -       | -      |
| Progress indicators    | ✓                   | Manual      | -       | -      |
| Archive testing        | ✓                   | Manual      | -       | -      |
| Checksum verification  | ✓                   | -           | -       | -      |
| Encryption support     | ✓                   | -           | ✓       | -      |
| Batch processing       | ✓                   | -           | -       | -      |
| Archive splitting      | ✓                   | Manual      | -       | -      |
| Fish completions       | ✓                   | Basic       | -       | -      |
| Modern fish syntax     | ✓                   | N/A         | N/A     | N/A    |

## 🤝 Contributing

Contributions are welcome! Please feel free to submit issues, feature requests, or pull requests.

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## 📄 License

MIT License - see LICENSE file for details

## 🙏 Acknowledgments

- Inspired by `atool`, `dtrx`, and other archive management tools
- Built for the amazing [fish shell](https://fishshell.com/) community
- Uses modern fish 4.12+ features for optimal performance

## 📚 See Also

- [Installation Guide](INSTALL.md)
- [Contributing Guidelines](CONTRIBUTING.md)
- [Usage Examples](examples/README.md)
- [Development Summary](SUMMARY.md)
- [fish shell documentation](https://fishshell.com/docs/current/)
- [Fisher plugin manager](https://github.com/jorgebucaran/fisher)

---

**Made with ❤️ for fish shell users**

## What's New in v3.0.0

- 🎉 **Complete Rewrite**: Cleaner code, better naming conventions, comprehensive comments
- 🔧 **New Commands**: `extract`, `compress`, `doctor` with simplified names
- ✨ **Enhanced Features**:
  - Automatic format detection (extension + MIME type)
  - Checksum verification and generation
  - Automatic backup before extraction
  - Archive splitting support
  - Auto-rename and timestamp options
  - Improved batch processing
  - Better error handling and diagnostics
  - Optimized performance with parallel tools (pigz, pbzip2)
- 📊 **Better Output**: Compression ratios, file sizes, detailed statistics
- 🎯 **Improved Smart Detection**: Better content analysis for format selection
- 📝 **Complete Rewrite**: Cleaner code, better naming conventions, comprehensive comments
- 📚 **Comprehensive Documentation**: Complete usage guide and project structure docs