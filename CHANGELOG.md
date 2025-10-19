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
- **Fish version requirement**: Now supports Fish 4.1.2+ (was 4.12+)
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

## [3.0.0] - Previous Release

See [changelog/v3.0.0.md](changelog/v3.0.0.md) for details.

## [2.0.0] - Legacy

See [changelog/legacy.md](changelog/legacy.md) for historical changes.