# Special filename handling for Fish Pack (fish 4.1.2+)
# Handles files with spaces, newlines, and special characters safely

function __fish_pack_process_files --description 'Process files safely with special character handling'
    set -l callback $argv[1]
    set -l files $argv[2..-1]
    
    # Process each file safely
    for file in $files
        # Skip if file doesn't exist
        if not test -e "$file"
            __fish_archive_log warn "File not found: $file"
            continue
        end
        
        # Call the callback with properly quoted filename
        $callback "$file"; or return $status
    end
end

function __fish_pack_find_files --description 'Find files safely handling special characters'
    set -l directory $argv[1]
    set -l pattern $argv[2]
    set -l type $argv[3]  # 'f' for files, 'd' for directories, empty for all
    
    # Build find command
    set -l find_args -L "$directory"
    
    if test -n "$type"
        set -a find_args -type "$type"
    end
    
    if test -n "$pattern"
        set -a find_args -name "$pattern"
    end
    
    # Use null-terminated output for safety
    set -l files
    find $find_args -print0 2>/dev/null | while read -z -l file
        set -a files "$file"
    end
    
    # Return the files
    for file in $files
        echo "$file"
    end
end

function __fish_pack_safe_tar_list --description 'List tar contents safely'
    set -l archive $argv[1]
    
    # Use tar with null-terminated output if available
    if tar --version 2>/dev/null | grep -q "GNU tar"
        # GNU tar supports --null
        tar -tf "$archive" --null 2>/dev/null | while read -z -l member
            echo "$member"
        end
    else
        # Fallback for non-GNU tar
        tar -tf "$archive" 2>/dev/null | while read -l member
            echo "$member"
        end
    end
end

function __fish_pack_safe_archive_add --description 'Add files to archive handling special names'
    set -l archive_type $argv[1]
    set -l archive $argv[2]
    set -l files $argv[3..-1]
    
    switch $archive_type
        case 'tar' 'tar.gz' 'tar.bz2' 'tar.xz' 'tar.zst'
            # Create file list safely
            set -l list_file (__fish_pack_secure_temp_file "tar-list")
            
            # Write files to list (one per line)
            for file in $files
                echo "$file" >> "$list_file"
            end
            
            # Use tar with file list
            tar -cf "$archive" --files-from="$list_file" 2>/dev/null
            set -l result $status
            
            # Cleanup
            __fish_pack_cleanup_temp "$list_file"
            return $result
            
        case 'zip'
            # Zip handles special characters better with stdin
            for file in $files
                echo "$file"
            end | zip -@ "$archive" 2>/dev/null
            
        case '7z'
            # 7z handles special characters well
            7z a "$archive" $files 2>/dev/null
    end
end

function __fish_pack_quote_filename --description 'Quote filename for shell safety'
    set -l filename $argv[1]
    
    # Replace problematic characters
    set -l quoted (string escape -- "$filename")
    echo "$quoted"
end

function __fish_pack_validate_filename --description 'Validate filename for safety'
    set -l filename $argv[1]
    set -l allow_absolute $argv[2]
    
    # Check for null bytes (serious security issue)
    if string match -q '*\0*' -- "$filename"
        __fish_archive_log error "Filename contains null byte: $filename"
        return 1
    end
    
    # Check for path traversal
    if string match -q '*../*' -- "$filename"; or string match -q '*..*' -- "$filename"
        __fish_archive_log error "Filename contains path traversal: $filename"
        return 1
    end
    
    # Check for absolute paths if not allowed
    if test "$allow_absolute" != "yes"; and string match -q '/*' -- "$filename"
        __fish_archive_log error "Absolute path not allowed: $filename"
        return 1
    end
    
    # Check for control characters
    if string match -r '[\x00-\x1f\x7f]' -- "$filename" >/dev/null
        __fish_archive_log warn "Filename contains control characters: $filename"
    end
    
    return 0
end

function __fish_pack_normalize_path --description 'Normalize path safely'
    set -l path $argv[1]
    set -l base $argv[2]
    
    # Remove duplicate slashes
    set path (string replace -a '//' '/' -- "$path")
    
    # Remove trailing slash unless it's root
    if test "$path" != "/"
        set path (string replace -r '/$' '' -- "$path")
    end
    
    # Make relative to base if provided
    if test -n "$base"
        set path (realpath --relative-to="$base" -- "$path" 2>/dev/null); or return 1
    end
    
    echo "$path"
end

function __fish_pack_batch_process --description 'Process files in batches for performance'
    set -l batch_size $argv[1]
    set -l callback $argv[2]
    set -l files $argv[3..-1]
    
    set -l batch
    set -l count 0
    
    for file in $files
        set -a batch "$file"
        set count (math "$count + 1")
        
        if test $count -eq $batch_size
            # Process batch
            $callback $batch; or return $status
            
            # Reset batch
            set batch
            set count 0
        end
    end
    
    # Process remaining files
    if test (count $batch) -gt 0
        $callback $batch; or return $status
    end
end

function __fish_pack_handle_long_filenames --description 'Handle extremely long filenames'
    set -l filename $argv[1]
    set -l max_length 255  # Most filesystems limit
    
    if test (string length -- "$filename") -gt $max_length
        # Truncate intelligently
        set -l extension (string match -r '\.[^.]+$' -- "$filename")
        set -l base (string replace -r '\.[^.]+$' '' -- "$filename")
        
        set -l truncated_length (math "$max_length - "(string length -- "$extension"))
        set -l truncated_base (string sub -l $truncated_length -- "$base")
        
        set -l new_name "$truncated_base$extension"
        __fish_archive_log warn "Filename too long, truncated: $filename -> $new_name"
        echo "$new_name"
    else
        echo "$filename"
    end
end