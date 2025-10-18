# Changelog

All notable changes to the Archivist plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-10-18

### Added

#### Core Features
- **Smart Format Detection**: Automatic archive format recognition from file extensions and MIME types
- **Intelligent Compression**: Auto-select optimal compression format based on content analysis
- **Multi-threaded Operations**: Parallel compression/decompression support for compatible formats
- **Progress Indicators**: Visual feedback for long-running operations using `pv`
- **Archive Testing**: Built-in integrity verification for all supported formats

#### Commands
- `archx`: Extract archives with extensive format support and options
- `archc`: Create archives with smart format selection
- `archdoctor`: System diagnostics and capability checking

#### Format Support
- **Tar-based**: tar, tar.gz, tar.bz2, tar.xz, tar.zst, tar.lz4, tar.lz, tar.lzo, tar.br
- **Standalone Archives**: zip, 7z, rar (extraction only)
- **Compressed Files**: gz, bz2, xz, zst, lz4, lz, lzo, br
- **Disk Images**: iso
- **Package Formats**: deb, rpm (extraction via bsdtar)

#### Features
- Password-protected archive support (zip, 7z)
- Include/exclude glob patterns
- Archive update and append modes
- Directory stripping for tar archives
- Flat extraction (no directory structure)
- Dry-run mode for testing operations
- Comprehensive logging with configurable levels
- Colorized output with auto-detection
- Context-aware fish completions

#### Configuration
- `ARCHIVIST_COLOR`: Control colored output
- `ARCHIVIST_PROGRESS`: Control progress indicators
- `ARCHIVIST_DEFAULT_THREADS`: Set default thread count
- `ARCHIVIST_LOG_LEVEL`: Configure logging verbosity
- `ARCHIVIST_DEFAULT_FORMAT`: Set default archive format
- `ARCHIVIST_SMART_LEVEL`: Tune smart selection heuristics
- `ARCHIVIST_PARANOID`: Enable additional safety checks

#### Documentation
- Comprehensive README with examples
- Detailed usage help for all commands
- Format comparison table
- Performance optimization tips
- Troubleshooting guide

### Technical

#### Code Quality
- Modern fish 4.12+ syntax throughout
- Extensive error handling and validation
- Modular function architecture
- No code duplication through helper functions
- Comprehensive input sanitization

#### Performance
- Efficient file processing
- Minimal external command spawning
- Optimized path handling
- Smart fallback mechanisms

#### Compatibility
- Arch Linux optimized
- Works with standard GNU/Linux tools
- Graceful degradation when optional tools missing
- Cross-platform path handling

### Requirements

- fish >= 4.12
- file (for MIME detection)
- tar, gzip (minimum)
- Additional tools for extended format support

---

## Future Roadmap

### Planned Features
- Archive comparison and diff
- Multi-volume archive support
- Archive repair/recovery utilities
- Batch processing improvements
- Custom compression profiles
- Archive conversion between formats
- Integration with cloud storage
- Archive encryption for tar (via GPG)

### Under Consideration
- GUI/TUI interface
- Archive metadata editing
- Checksum verification
- Archive splitting utilities
- Plugin system for custom handlers

---

**Note**: This is the initial release. Please report any issues or feature requests on the project repository.
