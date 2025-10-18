# Changelog

All notable changes to Fish Extractor will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2025-10-18

### 🎉 Major Changes

#### Renamed Project
- **Project renamed** from "Archivist" to **"Fish Extractor"** for clearer purpose and better discoverability
- All commands renamed for consistency:
  - `archx` → `extractor` (archive extraction)
  - `archc` → `compressor` (archive compression)
  - `archdoctor` → `ext-doctor` (diagnostic tool)

#### Complete Code Rewrite
- **Completely rewritten** with modern fish 4.12+ syntax
- Improved naming conventions throughout codebase
- Better code organization and modularity
- Comprehensive inline documentation and comments

### ✨ New Features

#### Extraction (`extractor`)
- **Checksum verification**: `--verify` flag to check archive integrity with checksums
- **Automatic backup**: `--backup` flag creates backup before extracting
- **Checksum generation**: `--checksum` flag generates SHA256 checksum after extraction
- **Batch processing improvements**: Better handling of multiple archives
- **Enhanced progress display**: Shows file size, format, and detailed statistics
- **Better error messages**: More informative error reporting

#### Compression (`compressor`)
- **Checksum generation**: `--checksum` flag creates SHA256 checksum file
- **Archive splitting**: `--split SIZE` splits large archives (e.g., `--split 100M`)
- **Compression statistics**: Shows compression ratio and space saved
- **Parallel compression**: Automatic use of pigz/pbzip2 when available
- **Improved smart detection**: Better content analysis for format selection
- **Update mode**: Better handling of existing archives with `-u` flag

#### Diagnostics (`ext-doctor`)
- **Export reports**: `--export` flag generates diagnostic report file
- **Package manager detection**: Auto-detects pacman, apt, brew, dnf for install commands
- **Performance assessment**: Checks for parallel compression tools
- **Detailed system info**: More comprehensive system information display

### 🚀 Performance Improvements

- **Parallel processing**: Automatic use of multi-threaded tools
  - `pigz` for parallel gzip compression
  - `pbzip2` for parallel bzip2 compression
  - Multi-threaded xz, zstd, lz4 support
- **Optimized file analysis**: Faster content type detection for smart format selection
- **Better thread management**: Dynamic thread count based on file size
- **Progress optimization**: Efficient progress display with minimal overhead

### 🔧 Improvements

#### Code Quality
- **Better error handling**: Comprehensive error checking and recovery
- **Input validation**: Stricter validation of user inputs
- **Path handling**: Improved path normalization and sanitization
- **Memory efficiency**: Reduced memory footprint for large operations

#### User Experience
- **Clearer command names**: More intuitive and descriptive
- **Better help messages**: More detailed usage examples
- **Improved completions**: Context-aware tab completions
- **Color-coded output**: Better visual distinction of messages
- **Progress indicators**: More informative progress bars

#### Configuration
- **Renamed environment variables**: 
  - `ARCHIVIST_*` → `FISH_EXTRACTOR_*`
  - More descriptive variable names
- **Better defaults**: Smarter default values
- **Backwards compatibility**: Optional aliases for old commands

### 📝 Documentation

- **Complete README rewrite**: Clearer structure and comprehensive examples
- **Chinese translation**: Updated README_CN.md with all new features
- **Enhanced examples**: More real-world usage scenarios
- **Better organization**: Clearer sections and navigation
- **Comparison table**: Added comparison with other tools
- **Troubleshooting guide**: Expanded troubleshooting section

### 🐛 Bug Fixes

- Fixed issue with directory extraction when target exists
- Improved handling of archives with special characters in names
- Fixed thread count resolution on macOS
- Better handling of compressed single files
- Fixed progress bar display issues with small files
- Corrected format detection for some edge cases

### 🔄 Changed

- **Command names**: All commands renamed for clarity
- **Function names**: Internal functions renamed with `__fish_extractor_` prefix
- **File structure**: Reorganized for better maintainability
- **Configuration format**: Updated environment variable names
- **Version numbering**: Bumped to 2.0.0 to reflect major changes

### ⚠️ Breaking Changes

- **Command names changed**: Users must update scripts using old commands
  - Old: `archx`, `archc`, `archdoctor`
  - New: `extractor`, `compressor`, `ext-doctor`
- **Environment variables renamed**: Configuration must be updated
  - Old: `ARCHIVIST_*`
  - New: `FISH_EXTRACTOR_*`
- **Function names changed**: Any custom scripts calling internal functions need updates

### 🔄 Migration Guide

#### Update Commands in Scripts
```fish
# Old commands
archx file.tar.gz
archc backup.tar.zst data/
archdoctor

# New commands
extractor file.tar.gz
compressor backup.tar.zst data/
ext-doctor
```

#### Update Configuration
```fish
# Old environment variables
set -Ux ARCHIVIST_COLOR auto
set -Ux ARCHIVIST_PROGRESS auto
set -Ux ARCHIVIST_DEFAULT_THREADS 8

# New environment variables
set -Ux FISH_EXTRACTOR_COLOR auto
set -Ux FISH_EXTRACTOR_PROGRESS auto
set -Ux FISH_EXTRACTOR_DEFAULT_THREADS 8
```

#### Optional: Add Backwards Compatibility Aliases
```fish
# Add to ~/.config/fish/config.fish
function archx --wraps=extractor
    extractor $argv
end

function archc --wraps=compressor
    compressor $argv
end

function archdoctor --wraps=ext-doctor
    ext-doctor $argv
end
```

---

## [1.0.0] - Previous Release

### Initial Release (as Archivist)

- Basic extraction support for common formats
- Compression with smart format selection
- Multi-threading support
- Progress indicators
- Environment diagnostics
- Tab completions
- Extensive format support

---

## Future Plans

### Planned for v2.1.0
- [ ] Resume partial downloads
- [ ] Archive encryption with GPG
- [ ] Cloud storage integration
- [ ] Archive repair functionality
- [ ] More hash algorithms (SHA512, Blake2)
- [ ] Archive comparison tool
- [ ] Batch rename in archives

### Planned for v2.2.0
- [ ] GUI mode (optional)
- [ ] Archive preview without extraction
- [ ] Incremental backup with snapshots
- [ ] Compression benchmarking tool
- [ ] Archive conversion between formats
- [ ] Duplicate file detection in archives

---

## Support

For issues, questions, or contributions:
- **Issues**: https://github.com/your-username/fish-extractor/issues
- **Discussions**: https://github.com/your-username/fish-extractor/discussions
- **Pull Requests**: https://github.com/your-username/fish-extractor/pulls

---

**Made with ❤️ for fish shell users**
