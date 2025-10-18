# Fish Archive Manager

[![Fish Shell](https://img.shields.io/badge/fish-4.12%2B-blue)](https://fishshell.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-3.0.0-green.svg)](https://github.com/xiaokanchengyang/fish-extractor)

**Fish Archive Manager** is a professional-grade archive management tool for the [fish shell](https://fishshell.com/). It provides powerful, intuitive commands for extracting and compressing archives with smart format detection, parallel processing, and comprehensive options.

[English](README.md) | [简体中文](README_CN.md)

## Quick Start

```fish
# Install using Fisher
fisher install xiaokanchengyang/fish-extractor

# Extract an archive
extract file.tar.gz

# Create an archive
compress backup.tar.zst ./mydata

# Check system capabilities
doctor
```

## Documentation

- **[Project Overview](PROJECT.md)** - Features, requirements, installation, and configuration
- **[Complete Usage Guide](USAGE.md)** - Detailed usage examples and advanced features
- **[Installation Guide](INSTALL.md)** - Step-by-step installation instructions

## Key Features

- 🎯 **Smart Format Detection** - Automatically detects and chooses optimal compression
- 🚀 **High Performance** - Multi-threaded with parallel tools (pigz, pbzip2)
- 📦 **25+ Formats** - tar, gzip, bzip2, xz, zstd, lz4, zip, 7z, rar, iso, and more
- 🎨 **Beautiful Output** - Colorized messages, progress bars, detailed statistics
- 🔐 **Encryption Support** - Password-protected archives for zip and 7z
- 🧪 **Testing & Verification** - Built-in integrity checking and checksum verification
- 💾 **Backup Support** - Automatic backup before extraction
- ✂️ **Archive Splitting** - Split large archives into manageable parts
- 📊 **Batch Processing** - Process multiple archives efficiently

## Commands

- **`extract`** - Extract archives with smart format detection
- **`compress`** - Create archives with intelligent compression
- **`doctor`** - Check system capabilities and configuration

## Quick Examples

```fish
# Extract archives
extract file.tar.gz                    # Extract to ./file/
extract -d output/ archive.zip         # Extract to ./output/
extract --strip 1 dist.tar.xz          # Remove top-level directory
extract -p secret encrypted.7z         # Extract with password

# Create archives
compress backup.tar.zst ./data         # Fast compression with zstd
compress -F tar.xz -L 9 logs.tar.xz    # Maximum compression
compress --smart output.auto ./project # Auto-select best format
compress -e -p secret secure.zip docs/ # Create encrypted archive

# System diagnostics
doctor                                  # Check system capabilities
doctor -v                              # Detailed information
doctor --fix                           # Get installation suggestions
```

## Requirements

- **fish** >= 4.12
- **file** (MIME type detection)
- **tar**, **gzip** (basic functionality)

See [PROJECT.md](PROJECT.md) for complete requirements and installation instructions.

## Configuration

```fish
# Set in ~/.config/fish/config.fish
set -Ux FISH_ARCHIVE_COLOR auto
set -Ux FISH_ARCHIVE_PROGRESS auto
set -Ux FISH_ARCHIVE_DEFAULT_THREADS 8
set -Ux FISH_ARCHIVE_LOG_LEVEL info
```

## What's New in v3.0.0

- 🎉 **Complete Rewrite** - Cleaner code, better naming conventions
- 🔧 **Simplified Commands** - `extract`, `compress`, `doctor`
- ✨ **Enhanced Features** - Smart detection, checksums, backups, splitting
- 📊 **Better Output** - Compression ratios, progress indicators
- 📚 **Comprehensive Docs** - Complete usage guide and examples