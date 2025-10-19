# Fish Pack Examples

This directory contains practical examples and usage patterns for Fish Pack.

## Files

- `basic_usage.fish` - Basic usage examples for common operations
- `advanced_usage.fish` - Advanced features and complex workflows
- `workflows.fish` - Complete workflow examples for different use cases
- `configuration.fish` - Configuration examples and best practices

## Quick Start

1. **Basic Extraction:**
   ```fish
   extract archive.tar.gz
   ```

2. **Basic Compression:**
   ```fish
   compress backup.tar.gz ./data
   ```

3. **Check System:**
   ```fish
   doctor
   ```

## Common Patterns

### Daily Backups
```fish
# Create timestamped backup
compress --timestamp backup.tar.zst ~/Documents

# Incremental backup
compress -u backup.tar.zst ~/Documents
```

### Development Workflows
```fish
# Package source code
compress -F tar.xz -x 'node_modules/*' release.txz .

# Create distributable archive
compress --smart --checksum dist.auto ./app
```

### Large File Handling
```fish
# Split large archive
compress --split 100M large.zip huge-files/

# Extract with progress
extract -v large-archive.tar.zst
```

### Security
```fish
# Encrypted archives
compress -e -p "password" secure.zip sensitive/

# Verify integrity
extract --verify --checksum archive.tar.gz
```

## Configuration

Set these environment variables in your `~/.config/fish/config.fish`:

```fish
# Enable colors and progress
set -Ux FISH_ARCHIVE_COLOR auto
set -Ux FISH_ARCHIVE_PROGRESS auto

# Set thread count
set -Ux FISH_ARCHIVE_DEFAULT_THREADS 8

# Set log level
set -Ux FISH_ARCHIVE_LOG_LEVEL info

# Set default format
set -Ux FISH_ARCHIVE_DEFAULT_FORMAT auto
```

## Tips

1. **Use smart format selection** for automatic optimization
2. **Enable progress indicators** for large files
3. **Use parallel processing** for better performance
4. **Test archives** before extraction
5. **Generate checksums** for important archives
6. **Use exclusions** to avoid unnecessary files
7. **Run doctor** to check system capabilities

## Troubleshooting

If you encounter issues:

1. Run `doctor` to check system capabilities
2. Use `doctor --fix` for installation suggestions
3. Check the main README for detailed troubleshooting
4. Use verbose mode (`-v`) for detailed output
5. Test with dry-run mode (`--dry-run`)