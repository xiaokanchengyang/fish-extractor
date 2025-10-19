# Changelog

All notable changes to Fish Archive Manager will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Intelligent compression strategy: auto-select `tar.zst` for small/medium, `tar.gz` (pigz) for large, `tar.xz` for text-heavy
- Native single-file compression support for `gz`, `bz2`, `xz`, `zst`, `lz4`, `lz`, `lzo`, `br`
- Progress/ETA with enhanced `pv` format; post-run throughput and estimated CPU utilization
- Batch task queue `archqueue` with sequential/parallel modes and stop-on-error
- Cross-platform install hints in docs for Arch/Debian/macOS/Windows (MSYS2)

### Changed
- Smart format selection enhanced to consider total size and available parallel gzip (pigz)
- Progress output format now shows ETA, rate, and average
- Plugin manifest now ships tools from `tools/`

### Docs
- Updated `docs/USAGE.md` with `archqueue`, smarter selection rules, progress/CPU summaries

### Tests
- Planned: add tests for single-file compression helpers and archqueue (pending)

## [3.0.0] - 2024-12-15

### Added
- **Common Functions Module**: Extracted duplicate code into reusable modules
  - `functions/common/archive_operations.fish` - Shared archive operations
  - `functions/common/file_operations.fish` - File handling utilities
  - `functions/common/format_operations.fish` - Format detection and validation
- **Smart Format Selection**: Automatically chooses optimal compression format
- **Advanced Progress Indicators**: Beautiful progress bars with `pv` integration
- **Archive Splitting**: Split large archives into manageable parts
- **Auto-rename and Timestamp**: Automatic file/directory naming
- **Comprehensive Checksum**: Generation and verification support
- **Parallel Processing**: Multi-threaded compression/decompression
- **25+ Format Support**: Extensive archive format compatibility
- **Encryption Support**: Password-protected archives for ZIP and 7z
- **Backup Functionality**: Automatic backup before extraction
- **Dry-run Mode**: Preview operations before executing
- **Changelog System**: Organized version history in `changelog/` folder

### Changed
- **Complete Code Refactor**: Rewritten for better maintainability
- **Reduced Code Duplication**: Eliminated ~200 lines of duplicate code
- **Modern Fish 4.12+ Syntax**: Leveraged latest Fish shell features
- **Better Error Handling**: Unified error management system
- **Improved Documentation**: Comprehensive guides and examples
- **Enhanced Test Suite**: More comprehensive testing coverage

### Fixed
- **Code Organization**: Better separation of concerns
- **Error Messages**: More descriptive and helpful
- **Format Detection**: More reliable and comprehensive
- **Performance**: Optimized resource usage
- **Maintainability**: Cleaner, more readable code

### Removed
- **Duplicate Code**: Eliminated redundant functions
- **Outdated Documentation**: Removed obsolete files
- **Complex Nested Logic**: Simplified control flow

## [2.x.x] - Previous Versions

For historical changes, see [changelog/legacy.md](changelog/legacy.md).

---

## How to Read This Changelog

- **[Unreleased]**: Changes that are not yet released
- **[Version]**: Released versions with dates
- **Added**: New features
- **Changed**: Changes to existing functionality
- **Deprecated**: Soon-to-be removed features
- **Removed**: Removed features
- **Fixed**: Bug fixes
- **Security**: Security improvements

## Links

- [Keep a Changelog](https://keepachangelog.com/)
- [Semantic Versioning](https://semver.org/)
- [Fish Archive Manager Repository](https://github.com/xiaokanchengyang/fish-extractor)
