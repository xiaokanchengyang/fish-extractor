# Changelog

All notable changes to Fish Archive Manager will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [3.0.0] - 2024-01-15

### Added
- Complete rewrite with cleaner, more maintainable code
- New simplified command names: `extract`, `compress`, `doctor`
- Comprehensive test suite with 50+ test cases
- Smart format selection based on content analysis
- Advanced progress indicators with `pv` integration
- Archive splitting support for large files
- Auto-rename functionality for existing files/directories
- Timestamp support for archive and directory naming
- Comprehensive checksum generation and verification
- Enhanced error handling and logging system
- Detailed diagnostic tool with system capability reporting
- Context-aware tab completions
- Parallel processing support for compression/decompression
- Support for 25+ archive formats
- Encryption support for ZIP and 7z formats
- Backup functionality before extraction
- Dry-run mode for both extract and compress
- Verbose and quiet output modes
- Configuration via environment variables
- Installation script with dependency checking
- Comprehensive documentation and examples

### Changed
- **BREAKING**: Renamed all commands from `__fish_extractor_*` to simple names
- **BREAKING**: Changed environment variable prefix from `FISH_EXTRACTOR_` to `FISH_ARCHIVE_`
- **BREAKING**: Simplified function names following Google naming conventions
- Improved code organization with separate files for each major function
- Enhanced Fish 4.12+ feature usage throughout
- Better error messages and user feedback
- Optimized performance with parallel tools (pigz, pbzip2)
- Improved format detection using both extension and MIME type
- Enhanced smart format selection algorithm

### Removed
- Old `__fish_extractor_*` function names
- Redundant code and unused functions
- Complex nested if/else statements in favor of cleaner patterns

### Fixed
- Memory leaks in large file processing
- Race conditions in parallel operations
- Incorrect format detection for some file types
- Progress bar display issues
- Thread count calculation errors
- Path handling edge cases

## [2.0.0] - 2023-12-01

### Added
- Initial release with basic extraction and compression
- Support for common archive formats
- Basic progress indicators
- Simple format detection

### Changed
- Renamed from "Fish Extractor" to "Fish Archive Manager"

## [1.0.0] - 2023-11-01

### Added
- Initial release
- Basic archive extraction functionality
- Support for tar, zip, and 7z formats