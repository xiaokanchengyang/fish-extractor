# Changelog

All notable changes to Fish Archive Manager will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Common functions module for better code organization
- Enhanced error handling and recovery
- Comprehensive test suite improvements

### Changed
- Refactored compression and extraction functions
- Improved code maintainability
- Better separation of concerns

### Fixed
- Reduced code duplication
- Improved error messages
- Better format detection

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

## Contributing

When adding entries to this changelog, please follow these guidelines:

1. **Use present tense**: "Add feature" not "Added feature"
2. **Group by type**: Group changes by Added, Changed, Fixed, etc.
3. **Be descriptive**: Explain what changed and why
4. **Include links**: Link to issues, PRs, or commits when relevant
5. **Follow format**: Use the established format for consistency

## Links

- [Keep a Changelog](https://keepachangelog.com/)
- [Semantic Versioning](https://semver.org/)
- [Fish Archive Manager Repository](https://github.com/xiaokanchengyang/fish-extractor)