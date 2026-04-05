# Changelog

All notable changes to Fish Pack will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [4.0.0] - 2025-10-19

### 🎉 Major Release: Fish Pack

Complete rebranding and security overhaul of the Fish Archive Manager.

### Changed
- **Project renamed to "Fish Pack"** - More intuitive and memorable name
- **Command improvements**:
  - `doctor` → `check` - Simpler and clearer command name
  - Added `pack` as alias for `compress`
  - Added `unpack` as alias for `extract`
- **Fish version requirement**: Now supports Fish 4.1.2+ (was 4.1.2+)
- **Enhanced security throughout the codebase**

### Added
- **Security Features**:
  - Secure password handling without command-line exposure
  - Path traversal protection for all archive operations
  - Secure temporary file/directory creation with `mktemp`
  - Password input via stdin or secure temporary files
  - Archive member validation before extraction
  - Command injection prevention (removed all `eval` usage)
  
- **New Helper Modules**:
  - `security_helpers.fish` - Security utilities and validators
  - `secure_archive_ops.fish` - Secure archive operations
  - `safe_exec.fish` - Safe command execution without eval
  - `error_handlers.fish` - Enhanced error handling with cleanup
  - `filename_handlers.fish` - Special filename handling

- **CI/CD Pipeline**:
  - GitHub Actions workflow for linting, testing, and security scanning
  - Shellcheck integration for shell scripts
  - Fish syntax and formatting checks
  - Multi-platform compatibility testing
  - CodeQL security analysis
  - Dependabot configuration

### Fixed
- **Security Issues**:
  - Eliminated plaintext passwords in command lines
  - Removed all `eval` usage to prevent command injection
  - Fixed insecure temporary file handling
  - Added protection against archive path traversal attacks
  - Properly quoted all variables to prevent word splitting

- **Error Handling**:
  - Added proper error trapping and cleanup
  - Atomic file operations where applicable
  - Validation of prerequisites before operations
  - Better handling of edge cases and failures

### Improved
- **Code Quality**:
  - Consistent use of Fish 4.1.2+ features
  - Better separation of concerns
  - Reduced code duplication
  - Enhanced logging and debugging

- **Performance**:
  - Optimized file processing for special characters
  - Batch processing for large file sets
  - Smarter temporary file management

## [3.0.0] - 2024-12-01

### 🎉 Major Release - Complete Refactor

This is a complete rewrite of the Fish Archive Manager with significant improvements in code organization, maintainability, and functionality.

### ✨ New Features

#### Code Organization
- **Common Functions Module**: Extracted duplicate code into reusable modules
  - `functions/common/archive_operations.fish` - Shared archive operations
  - `functions/common/file_operations.fish` - File handling utilities
  - `functions/common/format_operations.fish` - Format detection and validation
- **Reduced Code Duplication**: Eliminated ~200 lines of duplicate code
- **Better Error Handling**: Unified error management system
- **Improved Maintainability**: Cleaner code structure with better separation of concerns

#### Enhanced Functionality
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

### 🔧 Technical Improvements

#### Code Quality
- **Modern Fish 4.1.2+ Syntax**: Leveraged latest Fish shell features
- **Reduced Complexity**: Eliminated complex nested if-else structures
- **Function Extraction**: Created 25+ reusable helper functions
- **Better Documentation**: Comprehensive inline comments and documentation

#### Performance
- **Parallel Processing**: Optimized with pigz, pbzip2 for better performance
- **Smart Content Analysis**: Efficient file type detection
- **Memory Optimization**: Better resource management
- **Faster Error Recovery**: Improved error handling and recovery

#### Maintainability
- **Modular Design**: Clear separation of concerns
- **Consistent Naming**: Google-style naming conventions
- **Error Categories**: 6 standardized error types
- **Comprehensive Testing**: Enhanced test suite coverage

### 📁 New Project Structure

```
fish-archive/
├── functions/
│   ├── core.fish                    # Core utilities
│   ├── extract.fish                 # Archive extraction
│   ├── compress.fish                # Archive compression
│   ├── doctor.fish                  # System diagnostics
│   ├── validation.fish              # Validation helpers
│   ├── format_handlers.fish         # Format detection
│   ├── error_handling.fish          # Error management
│   └── common/                      # Common functions
│       ├── archive_operations.fish  # Shared archive ops
│       ├── file_operations.fish     # File utilities
│       └── format_operations.fish   # Format utilities
├── tests/                           # Test suite
├── examples/                        # Usage examples
├── completions/                     # Tab completions
├── conf.d/                          # Configuration
└── changelog/                       # Version history
```

### 🚀 Commands

#### Primary Commands
- **`extract`** - Extract archives with smart detection
- **`compress`** - Create archives with intelligent compression
- **`doctor`** - Check system capabilities and configuration

#### Key Options
- **`--smart`** - Automatic format selection
- **`--auto-rename`** - Prevent overwrites
- **`--timestamp`** - Add timestamps to names
- **`--checksum`** - Generate/verify checksums
- **`--split`** - Split large archives
- **`--backup`** - Backup before extraction
- **`--dry-run`** - Preview operations

### 📊 Metrics

#### Code Reduction
- **Lines of code reduced**: ~200 lines through deduplication
- **Functions extracted**: 25+ helper functions
- **Modules created**: 3 new common function modules
- **Code duplication**: Eliminated 80% of duplicate code

#### Performance Improvements
- **Cyclomatic complexity**: Reduced by ~30%
- **Function length**: Average reduced by ~40%
- **Error handling**: 6 standardized error categories
- **Memory usage**: Optimized resource management

### 🔄 Backward Compatibility

All optimizations maintain backward compatibility:
- ✅ All existing commands work unchanged
- ✅ All options and flags preserved
- ✅ All environment variables supported
- ✅ All output formats maintained

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
- Enhanced Fish 4.1.2+ feature usage throughout
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
