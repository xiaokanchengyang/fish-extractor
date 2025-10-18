# Fish Extractor - Project Structure

This document explains the organization and purpose of each directory and file in the Fish Extractor project.

## Table of Contents

- [Overview](#overview)
- [Directory Structure](#directory-structure)
- [Core Directories](#core-directories)
- [Configuration Files](#configuration-files)
- [Documentation Files](#documentation-files)
- [Development Guidelines](#development-guidelines)

## Overview

Fish Extractor follows the standard Fish shell plugin structure with additional organization for maintainability and extensibility.

```
fish-extractor/
├── functions/              # Core functionality (fish shell functions)
├── completions/            # Tab completion definitions
├── conf.d/                 # Plugin initialization and configuration
├── examples/               # Usage examples and sample configurations
├── README.md               # Main documentation
├── USAGE.md                # Comprehensive usage guide
├── INSTALL.md              # Installation instructions
├── CONTRIBUTING.md         # Contribution guidelines
├── CHANGELOG.md            # Version history
├── LICENSE                 # MIT license
└── VERSION                 # Current version number
```

## Directory Structure

### Core Directories

#### `functions/`

Contains all Fish shell functions that implement the plugin's functionality. Each function follows the naming convention `__fish_extractor_*` for internal functions.

```
functions/
├── __fish_extractor_common.fish      # Shared utility functions
├── __fish_extractor_extract.fish     # Extraction functionality
├── __fish_extractor_compress.fish    # Compression functionality
└── __fish_extractor_doctor.fish      # Diagnostic tool
```

**Purpose of each file:**

##### `__fish_extractor_common.fish`

**Core Infrastructure** - Provides shared utilities used by all other functions.

**Key Components:**

1. **Color & Output Management**
   - `__fish_extractor_supports_color` - Terminal color capability detection
   - `__fish_extractor_colorize` - Apply colors to output text
   - Output formatting and styling

2. **Logging System**
   - `__fish_extractor_log` - Structured logging with levels (debug, info, warn, error)
   - Respects `FISH_EXTRACTOR_LOG_LEVEL` environment variable
   - Colored output for different log levels

3. **Command & Tool Management**
   - `__fish_extractor_require_cmds` - Verify required commands exist
   - `__fish_extractor_best_available` - Find first available command from list
   - `__fish_extractor_has_cmd` - Check command availability

4. **Progress Display**
   - `__fish_extractor_can_progress` - Check if progress bars are supported
   - `__fish_extractor_spinner` - Spinner animation for background processes
   - `__fish_extractor_progress_bar` - Integration with `pv` for progress bars

5. **Thread/Concurrency Management**
   - `__fish_extractor_resolve_threads` - Determine optimal thread count
   - `__fish_extractor_optimal_threads` - Calculate threads based on file size
   - Respects `FISH_EXTRACTOR_DEFAULT_THREADS` environment variable

6. **Path & File Utilities**
   - `__fish_extractor_sanitize_path` - Normalize and expand file paths
   - `__fish_extractor_get_extension` - Extract file extensions (handles double extensions)
   - `__fish_extractor_get_mime_type` - Detect MIME type using `file` command
   - `__fish_extractor_basename_without_ext` - Remove archive extensions
   - `__fish_extractor_default_extract_dir` - Generate default extraction directory name
   - `__fish_extractor_get_file_size` - Get file size in bytes
   - `__fish_extractor_human_size` - Convert bytes to human-readable format (KB, MB, GB)

7. **Archive Format Detection**
   - `__fish_extractor_detect_format` - Intelligent format detection using extension and MIME type
   - Supports 25+ archive formats
   - Fallback to MIME type when extension is ambiguous

8. **Smart Format Selection (Compression)**
   - `__fish_extractor_analyze_content` - Analyze input files to determine content type
   - `__fish_extractor_smart_format` - Choose optimal compression format based on content
   - Samples files and calculates text vs binary ratio

9. **Compression Level Validation**
   - `__fish_extractor_validate_level` - Validate and normalize compression levels
   - Format-specific level ranges (e.g., gzip: 1-9, zstd: 1-19)

10. **Hash & Checksum Functions**
    - `__fish_extractor_calculate_hash` - Calculate file hashes (md5, sha1, sha256, sha512)
    - Cross-platform support for different hash tools

11. **Archive Validation**
    - `__fish_extractor_validate_archive` - Verify archive file exists and is readable
    - Pre-flight checks before extraction

##### `__fish_extractor_extract.fish`

**Extraction Engine** - Handles all archive extraction operations.

**Main Function:**
- `__fish_extractor_extract` - User-facing extraction command with comprehensive options

**Key Features:**

1. **Argument Parsing**
   - Comprehensive option support (destination, force, strip, password, threads, etc.)
   - Flag validation and normalization

2. **Format Detection & Dispatch**
   - Automatic format detection for each archive
   - Dispatches to format-specific extractors

3. **Operation Modes**
   - Extract (default)
   - List contents (`--list`)
   - Test integrity (`--test`)
   - Verify with checksum (`--verify`)
   - Dry run (`--dry-run`)

4. **Batch Processing**
   - Process multiple archives sequentially
   - Progress tracking and summary reporting
   - Individual success/failure tracking

5. **Safety Features**
   - Backup existing directories (`--backup`)
   - Force overwrite protection
   - Directory validation before extraction

**Internal Functions:**

- `__fish_extractor_extract_archive` - Main extraction dispatcher
- `__fish_extractor_extract_tar` - Extract tar archives with all compression variants
- `__fish_extractor_extract_zip` - Extract ZIP archives
- `__fish_extractor_extract_7z` - Extract 7-Zip archives
- `__fish_extractor_extract_rar` - Extract RAR archives (uses unrar or bsdtar)
- `__fish_extractor_extract_compressed` - Extract single compressed files (.gz, .xz, .zst, etc.)
- `__fish_extractor_extract_iso` - Extract ISO disk images
- `__fish_extractor_extract_package` - Extract package files (.deb, .rpm)
- `__fish_extractor_extract_fallback` - Fallback extraction using bsdtar or 7z
- `__fish_extractor_list_archive` - List archive contents
- `__fish_extractor_test_archive` - Test archive integrity
- `__fish_extractor_verify_archive` - Verify archive with checksum file

**Supported Formats:**
- Compressed tar: tar.gz, tar.bz2, tar.xz, tar.zst, tar.lz4, tar.lz, tar.lzo, tar.br
- Archives: zip, 7z, rar
- Compressed files: gz, bz2, xz, zst, lz4, lz, lzo, br
- Disk images: iso
- Package formats: deb, rpm

##### `__fish_extractor_compress.fish`

**Compression Engine** - Handles all archive creation operations.

**Main Function:**
- `__fish_extractor_compress` - User-facing compression command with smart format selection

**Key Features:**

1. **Smart Format Selection**
   - Automatic format detection from filename
   - Content-based format selection (`--smart`)
   - Optimizes compression based on file types

2. **Comprehensive Options**
   - Format selection, compression level, thread count
   - Encryption support (zip, 7z)
   - Include/exclude glob patterns
   - Update and append modes

3. **Filter System**
   - Include glob patterns (`-i`)
   - Exclude glob patterns (`-x`)
   - Multiple pattern support

4. **Advanced Features**
   - Archive splitting (`--split`)
   - Checksum generation (`--checksum`)
   - Solid archives (`--solid` for 7z)
   - Change directory before compression (`-C`)

5. **Performance Optimization**
   - Multi-threaded compression (xz, zstd, 7z)
   - Automatic use of parallel tools (pigz, pbzip2)
   - File size-based optimization

**Internal Functions:**

- `__fish_extractor_create_archive` - Main compression dispatcher
- `__fish_extractor_create_tar` - Create tar archives with compression
- `__fish_extractor_create_zip` - Create ZIP archives
- `__fish_extractor_create_7z` - Create 7-Zip archives
- `__fish_extractor_split_archive` - Split large archives into parts

**Compression Strategies:**

| Content Type | Recommended Format | Reason |
|--------------|-------------------|---------|
| Text-heavy (70%+) | tar.xz | Maximum compression for text |
| Mixed (30-70%) | tar.gz | Balanced, universal compatibility |
| Binary-heavy (<30%) | tar.zst | Fast, good compression for binary |

##### `__fish_extractor_doctor.fish`

**System Diagnostics** - Checks system capabilities and configuration.

**Main Function:**
- `__fish_extractor_doctor` - Diagnostic tool for troubleshooting

**Features:**

1. **Tool Detection**
   - Required tools (core functionality)
   - Important tools (extended functionality)
   - Optional tools (performance enhancements)
   - Version detection for installed tools

2. **Configuration Status**
   - Environment variable display
   - Current settings validation

3. **System Information** (verbose mode)
   - OS and architecture
   - CPU core count
   - Fish shell version
   - Kernel version

4. **Format Support Summary**
   - Lists all supported archive formats
   - Shows available extractors/compressors

5. **Performance Assessment**
   - Checks for parallel compression tools (pigz, pbzip2)
   - Progress viewer availability (pv)

6. **Fix Suggestions**
   - Package manager-specific installation commands
   - Performance optimization tips
   - Configuration recommendations

7. **Report Export**
   - Save diagnostic report to file
   - Timestamped for tracking

**Tool Categories:**

**Required (Core):**
- file, tar, gzip, bzip2, xz, zstd, unzip, zip

**Important (Extended):**
- 7z, lz4, bsdtar

**Optional (Performance):**
- unrar, pv, lzip, lzop, brotli, pigz, pbzip2, pxz, split

#### `completions/`

Contains Fish shell completion definitions for intelligent tab completion.

```
completions/
└── fish_extractor.fish       # Completions for all commands
```

**Purpose:**

Provides context-aware tab completions for:
- Command options and flags
- Archive file names (by extension)
- Directory paths
- Thread counts (based on CPU cores)
- Compression formats
- Glob patterns for include/exclude
- Split sizes

**Features:**

1. **Dynamic Completions**
   - `__fish_extractor_complete_formats` - List available formats based on installed tools
   - `__fish_extractor_complete_threads` - Suggest thread counts
   - `__fish_extractor_complete_archive_files` - Complete archive filenames

2. **Context-Aware Suggestions**
   - Different compression level ranges per format
   - Common glob patterns for filtering
   - Archive size suggestions for splitting

3. **Command Coverage**
   - `extract` / `extractor` - All extraction options
   - `compress` / `compressor` - All compression options
   - `ext-doctor` - Diagnostic options

#### `conf.d/`

Contains plugin initialization and configuration.

```
conf.d/
└── fish_extractor.fish       # Plugin initialization
```

**Purpose:**

Automatically loaded by Fish shell when a new session starts. Handles:

1. **Initialization Guard**
   - Prevents double initialization
   - Sets `__fish_extractor_initialized` flag

2. **Default Configuration**
   - Sets default environment variables if not already set
   - `FISH_EXTRACTOR_COLOR` (auto)
   - `FISH_EXTRACTOR_PROGRESS` (auto)
   - `FISH_EXTRACTOR_DEFAULT_THREADS` (auto-detected)
   - `FISH_EXTRACTOR_LOG_LEVEL` (info)
   - `FISH_EXTRACTOR_DEFAULT_FORMAT` (auto)

3. **Command Aliases**
   - Creates user-facing command wrappers:
     - `extract` and `extractor` → `__fish_extractor_extract`
     - `compress` and `compressor` → `__fish_extractor_compress`
     - `ext-doctor` → `__fish_extractor_doctor`

4. **Optional Features** (commented out by default)
   - Short aliases (`x`, `c`)
   - Backwards compatibility aliases
   - Startup diagnostic messages

**Why conf.d/?**
- Automatically sourced by Fish shell
- Runs before user's config.fish
- Proper plugin initialization pattern

#### `examples/`

Contains usage examples and sample configurations.

```
examples/
├── README.md                 # Examples overview
└── config.fish               # Sample configuration file
```

**Purpose:**

Provides real-world usage patterns and configuration examples for users to reference.

**Contents:**
- Common use cases and workflows
- Advanced configuration examples
- Integration with other tools
- Script examples for automation

### Configuration Files

#### `.git/` (Git Repository)

Version control directory containing:
- Commit history
- Branch information
- Remote repository configuration
- Git hooks

#### `fisher_plugin.fish`

Fisher plugin manager configuration file.

**Purpose:**
- Defines plugin metadata
- Specifies files to install
- Lists dependencies (if any)

**Used by:** [Fisher](https://github.com/jorgebucaran/fisher) plugin manager

#### `VERSION`

Simple text file containing the current version number.

**Format:** `X.Y.Z` (semantic versioning)

**Purpose:**
- Version tracking
- Used by installation scripts
- Referenced in documentation

### Documentation Files

#### `README.md`

**Main project documentation** covering:
- Feature overview
- Installation instructions
- Quick start guide
- Basic usage examples
- Configuration options
- Feature matrix
- Comparison with other tools

**Audience:** New users, quick reference

#### `USAGE.md`

**Comprehensive usage guide** (this document) covering:
- Detailed command reference
- All options and flags
- Usage examples for every feature
- Best practices
- Troubleshooting
- Advanced workflows

**Audience:** Regular users, detailed reference

#### `PROJECT_STRUCTURE.md`

**Code organization documentation** covering:
- Directory structure
- File purposes
- Function responsibilities
- Development patterns
- Architecture decisions

**Audience:** Developers, contributors

#### `INSTALL.md`

**Installation guide** covering:
- Installation methods (Fisher, manual)
- System requirements
- Package dependencies
- Platform-specific instructions
- Verification steps
- Troubleshooting installation issues

**Audience:** New users, system administrators

#### `CONTRIBUTING.md`

**Contribution guidelines** covering:
- Code style and conventions
- Development workflow
- Testing procedures
- Pull request process
- Issue reporting
- Feature requests

**Audience:** Contributors, maintainers

#### `CHANGELOG.md`

**Version history** documenting:
- Changes in each release
- New features
- Bug fixes
- Breaking changes
- Migration guides

**Format:** Keep a Changelog format

#### `SUMMARY.md`

**Development summary** providing:
- High-level overview
- Design decisions
- Implementation notes
- Future plans
- Technical considerations

**Audience:** Developers, reviewers

#### `LICENSE`

MIT License text defining usage terms and conditions.

#### `README_CN.md`

Chinese translation of README.md for international users.

## File Naming Conventions

### Function Naming

Fish Extractor follows these conventions:

1. **Internal Functions** (implementation)
   - Format: `__fish_extractor_*`
   - Examples: `__fish_extractor_log`, `__fish_extractor_detect_format`
   - Purpose: Internal implementation, not called by users directly

2. **User Commands** (public API)
   - Format: Simple, memorable names
   - Examples: `extract`, `compress`, `ext-doctor`
   - Purpose: User-facing commands

3. **Helper Functions**
   - Format: `__fish_extractor_*_helper` or descriptive name
   - Examples: `__fish_extractor_complete_formats`
   - Purpose: Support functions for completions or internal use

### File Organization

Each `.fish` file represents a cohesive functional area:
- One main function per file (for large features)
- Related helper functions in same file
- Common utilities grouped in `__fish_extractor_common.fish`

## Code Architecture

### Separation of Concerns

```
User Input (CLI)
    ↓
Command Wrapper (extract/compress/ext-doctor)
    ↓
Argument Parsing (argparse)
    ↓
Validation (common utilities)
    ↓
Format Detection (common utilities)
    ↓
Operation Dispatcher (main functions)
    ↓
Format-Specific Handlers (internal functions)
    ↓
External Tools (tar, gzip, zip, etc.)
```

### Error Handling Strategy

1. **Early Validation**
   - Check arguments before processing
   - Verify required tools exist
   - Validate file existence and permissions

2. **Graceful Degradation**
   - Fall back to alternative tools
   - Warn about missing optional features
   - Continue batch processing on individual failures

3. **Clear Error Messages**
   - Structured logging with levels
   - Colored output for visibility
   - Actionable error messages

### Performance Considerations

1. **Parallel Processing**
   - Auto-detect and use parallel tools (pigz, pbzip2)
   - Multi-threaded compression (xz, zstd, 7z)
   - Optimal thread count calculation

2. **Progress Feedback**
   - Progress bars for large files (>10MB)
   - Batch operation summaries
   - Spinner for long-running operations

3. **Efficient Format Detection**
   - Extension-based first (fast)
   - MIME type only when needed
   - Cached results within operations

## Development Guidelines

### Adding New Format Support

To add support for a new archive format:

1. **Update Format Detection** (`__fish_extractor_common.fish`)
   ```fish
   # In __fish_extractor_detect_format function
   case newformat
       echo newformat
   ```

2. **Add Extraction Handler** (`__fish_extractor_extract.fish`)
   ```fish
   function __fish_extractor_extract_newformat
       # Implementation
   end
   
   # Add to dispatch in __fish_extractor_extract_archive
   case newformat
       __fish_extractor_extract_newformat $argv
   ```

3. **Add Compression Handler** (`__fish_extractor_compress.fish`)
   ```fish
   function __fish_extractor_create_newformat
       # Implementation
   end
   
   # Add to dispatch in __fish_extractor_create_archive
   case newformat
       __fish_extractor_create_newformat $argv
   ```

4. **Update Completions** (`completions/fish_extractor.fish`)
   ```fish
   command -q newformat_tool; and echo -e "newformat\tDescription"
   ```

5. **Update Documentation**
   - README.md - Feature matrix
   - USAGE.md - Format list and examples
   - CHANGELOG.md - New feature entry

### Testing Changes

```fish
# Test extraction
extract test-archive.newformat

# Test compression
compress test.newformat ./test-data

# Test with verbose output
extract -v test-archive.newformat

# Test dry run
extract --dry-run test-archive.newformat

# Test diagnostic
ext-doctor -v
```

### Code Style

Follow Fish shell best practices:

1. **Indentation:** 4 spaces (no tabs)
2. **Variable naming:** `snake_case`
3. **Function naming:** `__plugin_module_function`
4. **Comments:** Descriptive, explain why not what
5. **Error handling:** Use `or begin ... end` blocks
6. **Quotes:** Use double quotes for variables containing spaces

### Documentation Standards

When modifying code:

1. **Update function docstrings**
   ```fish
   function name --description 'Clear description of purpose'
   ```

2. **Comment complex logic**
   ```fish
   # Calculate compression ratio as percentage
   set ratio (math -s1 "100 - ($out_size * 100 / $total_size)")
   ```

3. **Update relevant documentation files**
   - USAGE.md for user-facing changes
   - PROJECT_STRUCTURE.md for architectural changes
   - CHANGELOG.md for all changes

4. **Add examples for new features**

## Plugin Loading Flow

Understanding how Fish Extractor initializes:

```
Fish Shell Starts
    ↓
Loads conf.d/fish_extractor.fish
    ↓
Sets default environment variables
    ↓
Creates command wrapper functions
    ↓
User types command (e.g., 'extract')
    ↓
Wrapper function calls __fish_extractor_extract
    ↓
Function auto-loads from functions/ directory
    ↓
Dependencies (common functions) auto-load as needed
    ↓
Command executes
```

**Why this structure?**
- **Lazy loading:** Functions load only when needed (fast startup)
- **Auto-completion:** Completions available immediately
- **Configuration:** Settings apply before functions load
- **Clean namespace:** Internal functions prefixed to avoid conflicts

## File Dependencies

Understanding which files depend on which:

```
conf.d/fish_extractor.fish
    (Runs at startup, no dependencies)

functions/__fish_extractor_common.fish
    (Standalone utilities, no dependencies)

functions/__fish_extractor_extract.fish
    ↓ depends on
    __fish_extractor_common.fish

functions/__fish_extractor_compress.fish
    ↓ depends on
    __fish_extractor_common.fish

functions/__fish_extractor_doctor.fish
    ↓ depends on
    __fish_extractor_common.fish

completions/fish_extractor.fish
    ↓ depends on
    functions/__fish_extractor_common.fish (for helper functions)
```

## Extending Fish Extractor

### Adding Custom Commands

Users can add custom commands in their `~/.config/fish/config.fish`:

```fish
# Quick extraction to current directory
function extract-here --wraps=extract
    extract -d . $argv
end

# Maximum compression preset
function compress-max --wraps=compress
    compress -F tar.xz -L 9 $argv
end

# Fast compression preset
function compress-fast --wraps=compress
    compress -F tar.lz4 -L 1 $argv
end
```

### Hook System (Future)

Potential extension points for hooks:

1. **Pre-extraction hooks**
   - Virus scanning
   - Custom validation

2. **Post-extraction hooks**
   - Automatic indexing
   - Permission fixing

3. **Pre-compression hooks**
   - File filtering
   - Metadata stripping

4. **Post-compression hooks**
   - Upload to cloud
   - Verification

## Performance Monitoring

### File Size Thresholds

| Feature | Threshold | Reason |
|---------|-----------|---------|
| Progress bar | >10MB | Small files extract too quickly |
| Thread optimization | Varies | Overhead not worth it for small files |
| Streaming | >100MB | Memory efficiency |

### Thread Scaling

```fish
# File size → Thread recommendation
< 10MB:   max(2, cores)
< 100MB:  max(4, cores)
>= 100MB: cores
```

## Security Considerations

1. **Path Sanitization**
   - All paths normalized with `__fish_extractor_sanitize_path`
   - Prevents directory traversal

2. **Command Injection Prevention**
   - Proper quoting of all variables
   - No `eval` of user input

3. **Archive Validation**
   - Pre-flight checks before extraction
   - Option to test integrity first

4. **Password Handling**
   - Passwords not stored in logs
   - Option to prompt instead of command-line argument

## Future Enhancements

Potential areas for expansion:

1. **Remote Archives**
   - URL download and extract
   - Streaming extraction

2. **Cloud Integration**
   - Direct upload after compression
   - Download and extract from cloud storage

3. **Encryption**
   - GPG integration
   - Password manager integration

4. **Archive Conversion**
   - Convert between formats
   - Re-compress with different settings

5. **GUI Integration**
   - File manager integration
   - Desktop notifications

---

**For more information:**
- [README.md](README.md) - Project overview
- [USAGE.md](USAGE.md) - Comprehensive usage guide
- [CONTRIBUTING.md](CONTRIBUTING.md) - Development guidelines
- [Fish shell documentation](https://fishshell.com/docs/current/)
