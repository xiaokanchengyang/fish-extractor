# Fish Pack

[![Fish Shell](https://img.shields.io/badge/fish-4.1.2%2B-blue)](https://fishshell.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-4.0.0-green.svg)](https://github.com/xiaokanchengyang/fish-pack)

**Fish Pack** is a secure, professional-grade archive management tool for the [fish shell](https://fishshell.com/). It provides powerful, intuitive commands for packing and unpacking archives with smart format detection, parallel processing, enhanced security features, and comprehensive options.

[English](README.md) | [简体中文](README_CN.md)

## Installation

### Using [Fisher](https://github.com/jorgebucaran/fisher) (Recommended)

```fish
fisher install xiaokanchengyang/fish-pack
```

> **Note on Name Change**: The project was formerly named `fish-extractor` but has been renamed to `fish-pack`. Ensure you use the updated installation command.

### Requirements

- **fish** >= 4.1.2
- **file** (MIME type detection)
- **tar**, **gzip** (basic functionality)

### Recommended Dependencies

For optimal performance and broad format support, install the following packages:

- **Arch Linux**: `pacman -S file tar gzip bzip2 xz zstd lz4 unzip zip p7zip bsdtar unrar pv pigz pbzip2`
- **Ubuntu / Debian**: `apt-get install file tar gzip bzip2 xz-utils zstd liblz4-tool unzip zip p7zip-full libarchive-tools unrar pv pigz pbzip2`
- **macOS (Homebrew)**: `brew install gnu-tar gzip bzip2 xz zstd lz4 p7zip libarchive unrar pv pigz pbzip2`
- **Windows (MSYS2)**: `pacman -S file tar gzip bzip2 xz zstd lz4 unzip zip p7zip libarchive`

## Key Features

- 🛡️ **Security First** - Strict "Fail-Fast" protection against Path Traversal (ZipSlip) attacks and secure password handling.
- 🎯 **Smart Compression Strategy** - Auto-select zstd (small/medium), pigz/gzip (large), xz (text-heavy).
- 🚀 **High Performance** - Multi-threaded with parallel tools (pigz, pbzip2, zstd, xz).
- 📦 **Modern Formats** - tar.xz, tar.zst, tar.lz4, single-file xz/zst/lz4/gz.
- 🧰 **Cross-platform Consistency** - Auto-detect tools; macOS/Linux/Windows (MSYS2) guidance.
- 📊 **Batch Queue** - `archqueue` runs tasks sequentially or in parallel.

## Usage Guide

Fish Pack provides four main commands: `extract`, `compress`, `archqueue`, and `check`.

### 1. Extract Archives (`extract`)

Intelligently extracts archives with automatic format detection.

```fish
# Extract to default location (./filename/)
extract archive.tar.gz

# Extract to specific directory
extract -d /path/to/output archive.zip

# Extract multiple archives
extract *.tar.gz

# Strip top-level directory (useful for GitHub releases)
extract --strip 1 project-v1.0.tar.gz

# Extract password-protected archive
extract -p "mypassword" secure.zip

# List contents without extracting
extract --list archive.tar.gz
```

### 2. Create Archives (`compress`)

Creates archives with smart format selection and optimization.

```fish
# Automatically select optimal format based on contents
compress --smart output.auto ./mydata

# Detect format from output filename
compress backup.tar.zst ./data

# Maximum compression (tar.xz)
compress -F tar.xz -L 9 logs.tar.xz /var/log

# Create encrypted ZIP
compress -e -p secret secure.zip docs/

# Include/exclude specific files
compress -i '*.txt' -x '*.tmp' docs.zip .
```

### 3. Batch Queue (`archqueue`)

Runs batch compress/extract tasks sequentially or in parallel.

```fish
# Sequential (default)
archqueue \
  'compress::backup.tzst::src/ docs/' \
  'extract::release.zip::dist'

# Parallel with up to 3 concurrent tasks
archqueue --parallel 3 \
  'compress::a.tzst::a/' \
  'compress::b.tzst::b/' \
  'extract::x.zip::xdir'
```

### 4. System Check (`check`)

Diagnoses your system's archive handling capabilities and suggests fixes.

```fish
check        # Basic system check
check -v     # Detailed diagnostic
check --fix  # Get installation recommendations
```

## Configuration

You can customize Fish Pack by setting the following environment variables in your `~/.config/fish/config.fish`:

```fish
# Color output: auto (default), always, never
set -Ux FISH_PACK_COLOR auto

# Progress indicators: auto (default), always, never
set -Ux FISH_PACK_PROGRESS auto

# Default thread count (default: CPU cores)
set -Ux FISH_PACK_DEFAULT_THREADS 8

# Logging level: debug, info (default), warn, error
set -Ux FISH_PACK_LOG_LEVEL info
```

## Contributing

Contributions are welcome! Feel free to submit issues or pull requests.

## License

MIT License - see the LICENSE file for details.
