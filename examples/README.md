# Archivist Examples

This directory contains example configurations and use cases for Archivist.

## Configuration

See `config.fish` for example configuration settings. Copy relevant sections to:
- `~/.config/fish/config.fish` (global settings)
- `~/.config/fish/conf.d/archivist_user.fish` (plugin-specific settings)

## Common Use Cases

### 1. Daily Backups

```fish
# Create dated backup
function daily-backup
    set -l date (date +%Y%m%d)
    archc -F tar.zst ~/backups/backup-$date.tzst ~/Documents ~/Pictures
end

# Add to crontab or systemd timer
```

### 2. Project Archives

```fish
# Archive project excluding build artifacts
function archive-project
    set -l name (basename (pwd))
    archc -F tar.xz \
        -x 'node_modules/*' \
        -x '__pycache__/*' \
        -x '*.pyc' \
        -x '.git/*' \
        -x 'target/*' \
        -x 'build/*' \
        -x 'dist/*' \
        "$name.txz" .
end
```

### 3. Secure Archives

```fish
# Create encrypted backup
function secure-backup
    archc -e -F 7z --solid \
        -x '*.tmp' -x '*.cache' \
        secure-backup.7z ~/sensitive-data
end

# Will prompt for password
```

### 4. Log Compression

```fish
# Compress old logs
function compress-logs
    set -l month (date +%Y%m)
    find /var/log -name "*.log" -mtime +7 | while read log
        archc -F tar.xz -L 9 "$log-$month.txz" $log
        and rm $log
    end
end
```

### 5. Multi-Format Distribution

```fish
# Create distribution archives in multiple formats
function create-release
    set -l version $argv[1]
    set -l name "myapp-$version"
    
    # Source tarball (maximum compression)
    archc -F tar.xz -L 9 "$name.tar.xz" ./src
    
    # Binary archive (fast compression)
    archc -F tar.zst "$name.tar.zst" ./dist
    
    # Windows-friendly ZIP
    archc -F zip "$name.zip" ./dist
end
```

### 6. Batch Processing

```fish
# Extract all archives in directory
function extract-all
    for archive in *.tar.gz *.tar.xz *.tar.zst *.zip *.7z
        test -f $archive; and archx $archive
    end
end

# Compress all subdirectories
function compress-subdirs
    for dir in */
        set -l name (basename $dir)
        archc -F tar.zst "$name.tzst" $dir
    end
end
```

### 7. Smart Backup with Rotation

```fish
# Keep last N backups
function rotating-backup
    set -l max_backups 7
    set -l backup_dir ~/backups
    set -l date (date +%Y%m%d)
    
    # Create new backup
    archc -F tar.zst "$backup_dir/backup-$date.tzst" ~/Documents
    
    # Remove old backups
    set -l backups (ls -t $backup_dir/backup-*.tzst)
    if test (count $backups) -gt $max_backups
        rm $backups[$max_backups..-1]
    end
end
```

### 8. Development Workflow

```fish
# Package for distribution
function dist-package
    # Clean build
    make clean
    make build
    
    # Create source archive
    archc -F tar.xz \
        -x '.git/*' \
        -x 'build/*' \
        source.tar.xz .
    
    # Create binary archive
    archc -F tar.zst \
        -C build \
        binary.tar.zst .
end
```

### 9. Testing Archives

```fish
# Test all archives in directory
function test-archives
    set -l passed 0
    set -l failed 0
    
    for archive in *.tar.* *.zip *.7z
        if test -f $archive
            if archx --test $archive 2>/dev/null
                set passed (math $passed + 1)
                echo "✓ $archive"
            else
                set failed (math $failed + 1)
                echo "✗ $archive"
            end
        end
    end
    
    echo ""
    echo "Passed: $passed, Failed: $failed"
end
```

### 10. Web Asset Optimization

```fish
# Compress web assets
function build-web-assets
    # Compress with brotli for web serving
    archc -F tar.br \
        -i '*.html' \
        -i '*.css' \
        -i '*.js' \
        web-assets.tbr ./public
    
    # Also create gzip version for compatibility
    archc -F tar.gz \
        -i '*.html' \
        -i '*.css' \
        -i '*.js' \
        web-assets.tgz ./public
end
```

## Advanced Examples

### Custom Compression Profiles

```fish
# config.fish
function compress-fast --description 'Fast compression (LZ4)'
    archc -F tar.lz4 -L 1 $argv
end

function compress-balanced --description 'Balanced compression (zstd)'
    archc -F tar.zst -L 6 $argv
end

function compress-max --description 'Maximum compression (XZ)'
    archc -F tar.xz -L 9 $argv
end

function compress-text --description 'Text-optimized compression'
    archc -F tar.xz -L 7 $argv
end
```

### Automated Testing

```fish
# Test extraction and integrity
function test-extract
    set -l tmpdir (mktemp -d)
    
    if archx -d $tmpdir $argv[1]
        echo "✓ Extraction successful"
        
        # Verify file count
        set -l count (find $tmpdir -type f | wc -l)
        echo "  Files extracted: $count"
        
        rm -rf $tmpdir
        return 0
    else
        echo "✗ Extraction failed"
        rm -rf $tmpdir
        return 1
    end
end
```

### Integration with Other Tools

```fish
# Compress and upload
function backup-and-upload
    set -l date (date +%Y%m%d)
    set -l archive "backup-$date.tar.zst"
    
    archc -F tar.zst $archive ~/Documents
    and rclone copy $archive remote:backups/
    and rm $archive
end

# Download and extract
function download-and-extract
    curl -L $argv[1] -o /tmp/download.tar.gz
    and archx /tmp/download.tar.gz
    and rm /tmp/download.tar.gz
end
```

## Tips

1. **Use `--dry-run` first** to preview operations
2. **Test archives** with `--test` before relying on them
3. **Use appropriate compression levels** - level 6 is usually optimal
4. **Consider thread count** - more isn't always better for small files
5. **Test encryption** - make sure you can decrypt before relying on it

## More Information

See the main README.md for complete documentation.
