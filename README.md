# Fish Pack

[![Fish Shell](https://img.shields.io/badge/fish-4.1.2%2B-blue)](https://fishshell.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-4.0.0-green.svg)](https://github.com/xiaokanchengyang/fish-pack)

**Fish Pack** is a secure, professional-grade archive management tool for the [fish shell](https://fishshell.com/). It provides powerful, intuitive commands for packing and unpacking archives with smart format detection, parallel processing, enhanced security features, and comprehensive options.

[English](README.md) | [简体中文](README_CN.md)

## Quick Start

```fish
# Install using Fisher
fisher install xiaokanchengyang/fish-pack

# Extract an archive
extract file.tar.gz

# Create an archive
compress backup.tar.zst ./mydata

# Check system capabilities
check
```

## Documentation

- **[📚 Complete Documentation](docs/)** - All documentation in organized structure
- **[Complete Usage Guide](docs/USAGE.md)** - Detailed usage examples and advanced features
- **[Installation Guide](docs/INSTALL.md)** - Step-by-step installation instructions
- **[Project Structure](docs/PROJECT_STRUCTURE.md)** - Code organization and development guide
- **[Security Policy](SECURITY.md)** - Security features and policies
- **[Contributing](docs/CONTRIBUTING.md)** - How to contribute to the project

## Key Features

- 🛡️ **Security First** - Strict "Fail-Fast" protection against Path Traversal (ZipSlip) attacks and secure password handling.
- 🎯 **Smart Compression Strategy** - Auto-select zstd (small/medium), pigz/gzip (large), xz (text-heavy).
- 🚀 **High Performance** - Multi-threaded with parallel tools (pigz, pbzip2, zstd, xz).
- 📦 **Modern Formats** - tar.xz, tar.zst, tar.lz4, single-file xz/zst/lz4/gz.
- 🧰 **Cross-platform Consistency** - Auto-detect tools; macOS/Linux/Windows (MSYS2) guidance.
- 🎨 **Beautiful Output** - Progress bars with ETA/rate/avg, CPU utilization summary.
- 🔐 **Encryption Support** - Password-protected archives for zip and 7z.
- 🧪 **Testing & Verification** - Built-in integrity checking and checksum verification.
- 💾 **Backup Support** - Automatic backup before extraction.
- ✂️ **Archive Splitting** - Split large archives into manageable parts.
- 📊 **Batch Queue** - `archqueue` runs tasks sequentially or in parallel.

## Commands

- **`extract`** - Extract archives with smart format detection and security verification.
- **`compress`** - Create archives with intelligent compression.
- **`check`** - (formerly `doctor`) Diagnose system capabilities and missing tools.
- **`archqueue`** - Batch queue for compress/extract tasks.

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
check                                  # Check system capabilities
check -v                               # Detailed information
check --fix                            # Get installation suggestions
```

## Requirements

- **fish** >= 4.12
- **file** (MIME type detection)
- **tar**, **gzip** (basic functionality)

See [docs/INSTALL.md](docs/INSTALL.md) for complete requirements and installation instructions.

## Configuration

```fish
# Set in ~/.config/fish/config.fish
set -Ux FISH_ARCHIVE_COLOR auto
set -Ux FISH_ARCHIVE_PROGRESS auto
set -Ux FISH_ARCHIVE_DEFAULT_THREADS 8
set -Ux FISH_ARCHIVE_LOG_LEVEL info
```

## What's New

- **Strict Security**: Archives with unsafe paths (e.g. `../`) are now skipped by default.
- **Unified Logic**: Core logic split into `common/` for better maintainability.
- **Check Command**: `doctor` renamed to `check` for clarity (alias preserved).
- **Smart compression**: Enhanced auto-selection strategy.