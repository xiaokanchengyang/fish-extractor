# Fish Archive Manager

[![Fish Shell](https://img.shields.io/badge/fish-4.12%2B-blue)](https://fishshell.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-3.0.0-green.svg)](https://github.com/xiaokanchengyang/fish-extractor)

**Fish Archive Manager** is a professional-grade archive management tool for the [fish shell](https://fishshell.com/). It provides powerful, intuitive commands for extracting and compressing archives with smart format detection, parallel processing, and comprehensive options.

[English](PROJECT.md) | [简体中文](PROJECT_CN.md)

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
fisher install xiaokanchengyang/fish-extractor
```

### Manual Installation

```fish
git clone https://github.com/xiaokanchengyang/fish-extractor ~/.config/fish/fish-extractor
ln -sf ~/.config/fish/fish-extractor/functions/*.fish ~/.config/fish/functions/
ln -sf ~/.config/fish/fish-extractor/completions/*.fish ~/.config/fish/completions/
ln -sf ~/.config/fish/fish-extractor/conf.d/*.fish ~/.config/fish/conf.d/
```

### Verify Installation

```fish
doctor
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

- [Usage Guide](USAGE.md)
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