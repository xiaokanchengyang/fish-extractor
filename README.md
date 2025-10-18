# Archivist

[![Fish Shell](https://img.shields.io/badge/fish-4.12%2B-blue)](https://fishshell.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**Archivist** is a high-quality, feature-rich archive management plugin for the [fish shell](https://fishshell.com/). It provides intelligent extraction and compression commands with smart format detection, extensive format support, progress indicators, and comprehensive options.

## ✨ Features

- 🎯 **Smart Format Detection**: Automatically detects archive formats and chooses optimal compression
- 🚀 **High Performance**: Multi-threaded compression/decompression where supported
- 📦 **Extensive Format Support**: tar, gzip, bzip2, xz, zstd, lz4, lzip, lzo, brotli, zip, 7z, rar, iso, deb, rpm, and more
- 🎨 **Beautiful Output**: Colorized messages and progress indicators
- 🔐 **Encryption Support**: Password-protected archives (zip, 7z)
- 🧪 **Testing & Verification**: Built-in integrity checking for archives
- 🔧 **Highly Configurable**: Environment variables for customization
- 📝 **Comprehensive Help**: Detailed usage information and examples
- 🎓 **Intelligent Completions**: Context-aware tab completions

## 📋 Requirements

### Minimum (fish 4.12+)
- `fish` >= 4.12
- `file` (MIME type detection)
- `tar`, `gzip` (basic functionality)

### Recommended
```bash
# Arch Linux
pacman -S file tar gzip bzip2 xz zstd lz4 unzip zip p7zip bsdtar

# Optional for enhanced features
pacman -S unrar pv lzip lzop brotli pigz pbzip2
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

### Using [Fisher](https://github.com/jorgebucaran/fisher)

```fish
fisher install your-username/archivist
```

### Manual Installation

```fish
git clone https://github.com/your-username/archivist ~/.config/fish/archivist
ln -s ~/.config/fish/archivist/functions/* ~/.config/fish/functions/
ln -s ~/.config/fish/archivist/completions/* ~/.config/fish/completions/
ln -s ~/.config/fish/archivist/conf.d/* ~/.config/fish/conf.d/
```

### Verify Installation

```fish
archdoctor
```

## 📖 Usage

### Archive Extraction (`archx`)

Extract archives with intelligent format detection:

```fish
# Basic extraction
archx file.tar.gz                    # Extract to ./file/

# Specify destination
archx -d output/ archive.zip         # Extract to ./output/

# Strip leading directories (useful for nested archives)
archx --strip 1 dist.tar.xz          # Remove top-level directory

# Extract encrypted archives
archx -p secret encrypted.7z         # Provide password

# List contents without extracting
archx --list archive.zip             # Preview contents

# Test integrity
archx --test backup.tar.gz           # Verify archive is valid

# Extract multiple archives
archx *.tar.gz                       # Extract all .tar.gz files

# Parallel extraction with custom threads
archx -t 8 large-archive.tar.zst    # Use 8 threads

# Verbose output
archx -v complicated.7z              # Show detailed progress
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
    --flat              Extract without directory structure
    --dry-run           Show what would be done
    --help              Display help
```

### Archive Compression (`archc`)

Create archives with smart format selection:

```fish
# Basic compression
archc backup.tar.zst ./data          # Fast compression with zstd

# Maximum compression
archc -F tar.xz -L 9 logs.tar.xz /var/log

# Smart format (auto-detect best compression)
archc --smart output.auto ./project

# Create encrypted archive
archc -e -p secret secure.zip docs/

# Exclude patterns
archc -x '*.tmp' -x '*.log' clean.tgz .

# Include only specific files
archc -i '*.txt' -i '*.md' docs.zip .

# Update existing archive
archc -u existing.tar.gz newfile.txt

# Multi-threaded compression
archc -t 16 -F tar.zst fast.tzst large-dir/

# Change directory before archiving
archc -C /var/www -F tar.xz web-backup.txz html/

# Solid 7z archive (better compression)
archc --solid -F 7z backup.7z data/

# Verbose with custom level
archc -v -L 7 -F tar.xz archive.txz files/
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

### Environment Diagnostics (`archdoctor`)

Check your system's archive handling capabilities:

```fish
# Basic check
archdoctor

# Detailed system information
archdoctor -v

# Get installation suggestions
archdoctor --fix

# Quiet mode (only errors)
archdoctor -q
```

## ⚙️ Configuration

Configure Archivist by setting environment variables (e.g., in `~/.config/fish/config.fish`):

```fish
# Color output: auto (default), always, never
set -gx ARCHIVIST_COLOR auto

# Progress indicators: auto (default), always, never
set -gx ARCHIVIST_PROGRESS auto

# Default thread count (default: CPU cores)
set -gx ARCHIVIST_DEFAULT_THREADS 8

# Logging level: debug, info (default), warn, error
set -gx ARCHIVIST_LOG_LEVEL info

# Default format for smart selection
set -gx ARCHIVIST_DEFAULT_FORMAT auto

# Smart selection heuristic strength (1-3, default: 2)
set -gx ARCHIVIST_SMART_LEVEL 2

# Paranoid mode for extra safety checks (0=off, 1=on)
set -gx ARCHIVIST_PARANOID 0
```

## 🎯 Smart Format Selection

Archivist can automatically choose the best compression format based on your data:

```fish
archc --smart output.auto ./mydata
```

**Selection Logic:**
- **70%+ text files** → `tar.xz` (maximum compression for text)
- **30-70% text files** → `tar.gz` (balanced, compatible)
- **<30% text files** → `tar.zst` (fast, good for binary data)

## 💡 Tips & Best Practices

### Performance Optimization

```fish
# Use zstd for large binary files (fast)
archc -F tar.zst -t $(nproc) backup.tzst /large/dataset

# Use xz for text-heavy content (best compression)
archc -F tar.xz -t $(nproc) source.txz /code

# Use lz4 for temporary archives (very fast)
archc -F tar.lz4 temp.tlz4 /tmp/data
```

### Compression Level Guide

- **Level 1-3**: Fast compression, larger files (good for temporary archives)
- **Level 4-6**: Balanced (recommended for most use cases)
- **Level 7-9**: Maximum compression, slower (good for long-term storage)

### Secure Archives

```fish
# Create encrypted ZIP
archc -e -p "strong-password" secure.zip sensitive/

# Create encrypted 7z with solid compression
archc --solid -e -p "strong-password" -F 7z backup.7z data/
```

### Working with Large Archives

```fish
# Show progress with pv
archx large-archive.tar.zst  # Progress bar appears automatically

# Use multiple threads
archx -t 16 huge-file.tar.xz

# Test before extracting
archx --test archive.7z && archx archive.7z
```

## 🔧 Troubleshooting

### Missing Tools

```fish
archdoctor --fix  # Shows installation commands
```

### Extraction Fails

```fish
# Test integrity first
archx --test problematic.tar.gz

# Try verbose mode
archx -v problematic.tar.gz

# Check available formats
archdoctor -v
```

### Compression Issues

```fish
# Verify inputs exist
archc --dry-run output.tar.zst input/

# Check format support
archdoctor
```

## 🔄 Comparison with Other Tools

| Feature                | Archivist | `tar` + `*` | `atool` | `dtrx` |
|------------------------|-----------|-------------|---------|--------|
| Smart format detection | ✓         | -           | ✓       | ✓      |
| Multi-threading        | ✓         | Manual      | -       | -      |
| Progress indicators    | ✓         | Manual      | -       | -      |
| Archive testing        | ✓         | Manual      | -       | -      |
| Encryption support     | ✓         | -           | ✓       | -      |
| Fish completions       | ✓         | Basic       | -       | -      |
| Modern fish syntax     | ✓         | N/A         | N/A     | N/A    |

## 📝 Examples

### Backup Workflows

```fish
# Daily backup with date
archc -F tar.zst backup-(date +%Y%m%d).tzst ~/Documents

# Incremental backup (update mode)
archc -u backup.tar.zst ~/Documents

# Exclude cache and temp files
archc -x '*.cache' -x '*.tmp' -x '.git/*' clean-backup.tgz ~/project
```

### Development Workflows

```fish
# Package source code
archc -F tar.xz -x 'node_modules/*' -x '__pycache__/*' release.txz .

# Create distributable archive
archc --smart -x '*.log' -x '.env' dist.auto ./app

# Extract and test
archx --test release.txz && archx release.txz
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit issues, feature requests, or pull requests.

## 📄 License

MIT License - see LICENSE file for details

## 🙏 Acknowledgments

- Inspired by `atool`, `dtrx`, and other archive management tools
- Built for the amazing [fish shell](https://fishshell.com/) community
- Uses modern fish 4.12+ features for optimal performance

## 📚 See Also

- [fish shell documentation](https://fishshell.com/docs/current/)
- [Fisher plugin manager](https://github.com/jorgebucaran/fisher)
- [Arch Linux wiki: Archive tools](https://wiki.archlinux.org/title/Archiving_and_compression)

---

**Made with ❤️ for fish shell users**
