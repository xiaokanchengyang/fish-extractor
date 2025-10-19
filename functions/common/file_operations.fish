# Common file operations for Fish Archive Manager (fish 4.12+)
# Provides shared functions for file handling, validation, and processing

# Load core utilities
source (dirname (status --current-filename))/../core.fish
# Load error handling
source (dirname (status --current-filename))/../error_handling.fish

# ============================================================================
# File Collection and Filtering
# ============================================================================

function collect_input_files --description 'Collect and validate input files for compression'
    set -l inputs $argv[1..-2]
    set -l chdir $argv[-1]
    
    set -l file_list
    
    # Change directory if needed
    if test -n "$chdir"
        pushd "$chdir" >/dev/null
        or begin
            log error "Failed to change directory to: $chdir"
            return 1
        end
    end
    
    # Collect input files
    for input in $inputs
        if test -e "$input"
            set -a file_list "$input"
        else
            # Try glob expansion safely
            set -l expanded (string match -r '.*' -- $input)
            for item in $expanded
                test -e "$item"; and set -a file_list "$item"
            end
        end
    end
    
    # Restore directory
    if test -n "$chdir"
        popd >/dev/null
    end
    
    echo $file_list
end

function apply_file_filters --description 'Apply include/exclude filters to file list'
    set -l file_list $argv[1..-3]
    set -l include_globs $argv[-2]
    set -l exclude_globs $argv[-1]
    
    set -l filtered $file_list
    
    # Apply include filters
    if test (count $include_globs) -gt 0
        set -l included
        for file in $filtered
            for pattern in $include_globs
                if string match -q -- $pattern $file
                    set -a included $file
                    break
                end
            end
        end
        set filtered $included
    end
    
    # Apply exclude filters
    if test (count $exclude_globs) -gt 0
        set -l excluded
        for file in $filtered
            set -l should_exclude 0
            for pattern in $exclude_globs
                if string match -q -- $pattern $file
                    set should_exclude 1
                    break
                end
            end
            test $should_exclude -eq 0; and set -a excluded $file
        end
        set filtered $excluded
    end
    
    echo $filtered
end

function validate_file_list --description 'Validate file list and check for empty results'
    set -l file_list $argv[1]
    set -l operation $argv[2]  # compress or extract
    
    if test (count $file_list) -eq 0
        log error "No files to $operation"
        return 1
    end
    
    return 0
end

# ============================================================================
# File Size and Statistics
# ============================================================================

function calculate_total_size --description 'Calculate total size of file list'
    set -l file_list $argv
    
    set -l total_size 0
    for file in $file_list
        if test -f "$file"
            set -l fsize (get_file_size "$file")
            set total_size (math $total_size + $fsize)
        end
    end
    
    echo $total_size
end

function show_file_statistics --description 'Show file statistics for operation'
    set -l file_list $argv[1]
    set -l total_size $argv[2]
    set -l verbose $argv[3]
    set -l quiet $argv[4]
    
    if should_show_verbose $verbose $quiet
        log debug "  Files: "(count $file_list)
        log debug "  Total size: "(human_size $total_size)
    end
end

# ============================================================================
# Directory Operations
# ============================================================================

function prepare_extraction_directory --description 'Prepare extraction directory with common logic'
    set -l extract_dir $argv[1]
    set -l force $argv[2]
    set -l backup $argv[3]
    set -l quiet $argv[4]
    
    # Create extraction directory
    if not test -d "$extract_dir"
        mkdir -p "$extract_dir"
        or begin
            log error "Failed to create directory: $extract_dir"
            return 1
        end
    else if not is_force $force
        # Directory exists and no force flag
        if test (count (ls -A "$extract_dir" 2>/dev/null)) -gt 0
            if is_backup $backup
                # Create backup
                set -l backup_dir "$extract_dir.backup."(date +%Y%m%d_%H%M%S)
                log info "Creating backup: $backup_dir"
                mv "$extract_dir" "$backup_dir"
                or begin
                    log error "Failed to create backup"
                    return 1
                end
                mkdir -p "$extract_dir"
            else
                log warn "Directory not empty: $extract_dir (use --force or --backup)"
                return 1
            end
        end
    end
    
    return 0
end

function create_output_directory --description 'Create output directory if needed'
    set -l output_path $argv[1]
    set -l quiet $argv[2]
    
    set -l output_dir (dirname "$output_path")
    if not test -d "$output_dir"
        mkdir -p "$output_dir"
        or begin
            log error "Failed to create output directory: $output_dir"
            return 1
        end
        test $quiet -eq 0; and log info "Created output directory: $output_dir"
    end
    
    return 0
end

# ============================================================================
# File Path Operations
# ============================================================================

function generate_output_path --description 'Generate output path with timestamp and auto-rename'
    set -l base_path $argv[1]
    set -l auto_rename $argv[2]
    set -l add_timestamp $argv[3]
    
    set -l output_path $base_path
    
    # Add timestamp if requested
    if is_timestamp $add_timestamp
        set -l base_name (string replace -r '\.[^.]+$' '' -- (basename $output_path))
        set -l extension (string match -r '\.[^.]+$' -- (basename $output_path))
        set -l dir_name (dirname $output_path)
        set output_path "$dir_name/$base_name-"(date +%Y%m%d_%H%M%S)"$extension"
    end
    
    # Auto-rename if output exists
    if is_auto_rename $auto_rename; and test -e "$output_path"
        set -l counter 1
        set -l base_name (string replace -r '\.[^.]+$' '' -- $output_path)
        set -l extension (string match -r '\.[^.]+$' -- $output_path)
        while test -e "$output_path"
            set output_path "$base_name-$counter$extension"
            set counter (math $counter + 1)
        end
    end
    
    echo $output_path
end

function generate_extract_directory --description 'Generate extraction directory with common logic'
    set -l archive_path $argv[1]
    set -l dest $argv[2]
    set -l auto_rename $argv[3]
    set -l add_timestamp $argv[4]
    
    # Determine extraction directory
    set -l extract_dir $dest
    if test -z "$extract_dir"
        set extract_dir (default_extract_dir "$archive_path")
    end
    
    # Add timestamp if requested
    if is_timestamp $add_timestamp
        set extract_dir "$extract_dir-"(date +%Y%m%d_%H%M%S)
    end
    
    # Auto-rename if destination exists
    if is_auto_rename $auto_rename; and test -e "$extract_dir"
        set -l counter 1
        set -l base_dir $extract_dir
        while test -e "$extract_dir"
            set extract_dir "$base_dir-$counter"
            set counter (math $counter + 1)
        end
    end
    
    echo (sanitize_path $extract_dir)
end

# ============================================================================
# Archive Content Analysis
# ============================================================================

function analyze_archive_content --description 'Analyze archive content for smart format selection'
    set -l inputs $argv
    
    # Counters for content analysis
    set -l total_files 0
    set -l text_files 0
    set -l total_size 0
    set -l compressible_size 0
    
    # Analyze input files
    for item in $inputs
        if test -d "$item"
            # For directories, sample files (limit to 200 for performance)
            set -l samples (find "$item" -type f -not -path '*/\.*' 2>/dev/null | head -n 200)
            for file in $samples
                set total_files (math $total_files + 1)
                
                set -l size (get_file_size "$file")
                set total_size (math $total_size + $size)
                
                set -l mime (get_mime_type "$file")
                if string match -qr '^text/' -- $mime; or string match -q '*json*' '*xml*' '*javascript*' '*script*' -- $mime
                    set text_files (math $text_files + 1)
                    set compressible_size (math $compressible_size + $size)
                end
            end
        else if test -f "$item"
            set total_files (math $total_files + 1)
            
            set -l size (get_file_size "$item")
            set total_size (math $total_size + $size)
            
            set -l mime (get_mime_type "$item")
            if string match -qr '^text/' -- $mime; or string match -q '*json*' '*xml*' '*javascript*' '*script*' -- $mime
                set text_files (math $text_files + 1)
                set compressible_size (math $compressible_size + $size)
            end
        end
    end
    
    # Return analysis results
    echo $total_files
    echo $text_files
    echo $total_size
    echo $compressible_size
end

# ============================================================================
# Checksum Operations
# ============================================================================

function generate_checksum_file --description 'Generate checksum file for archive or directory'
    set -l target $argv[1]  # archive file or directory
    set -l algorithm $argv[2]  # sha256, md5, etc.
    set -l quiet $argv[3]
    
    test -z "$algorithm"; and set algorithm sha256
    
    set -l checksum_file "$target.$algorithm"
    
    if test -f "$target"
        # Single file
        log info "Generating checksum: $checksum_file"
        calculate_hash "$target" $algorithm > "$checksum_file"
    else if test -d "$target"
        # Directory
        log info "Generating checksum: $checksum_file"
        find "$target" -type f -exec $algorithm {} \; > "$checksum_file"
    else
        log error "Cannot generate checksum for: $target"
        return 1
    end
    
    return 0
end

function verify_checksum_file --description 'Verify checksum file if it exists'
    set -l target $argv[1]
    set -l algorithm $argv[2]
    
    test -z "$algorithm"; and set algorithm sha256
    
    set -l checksum_file "$target.$algorithm"
    
    if test -f "$checksum_file"
        log info "Found checksum file: $checksum_file"
        set -l expected (cat "$checksum_file" | awk '{print $1}')
        set -l actual (calculate_hash "$target" $algorithm)
        
        if test "$expected" = "$actual"
            log info "✓ Checksum verified"
            return 0
        else
            log error "✗ Checksum mismatch!"
            log error "  Expected: $expected"
            log error "  Actual:   $actual"
            return 1
        end
    end
    
    log info "No checksum file found, integrity test passed"
    return 0
end

# ============================================================================
# Archive Splitting
# ============================================================================

function split_archive_file --description 'Split archive into smaller parts'
    set -l archive $argv[1]
    set -l size $argv[2]
    set -l quiet $argv[3]
    
    test -f "$archive"; or return 1
    
    if has_command split
        # Convert size to bytes for split command
        set -l size_bytes (string replace -r 'M$' '000000' -- $size)
        set size_bytes (string replace -r 'G$' '000000000' -- $size_bytes)
        set size_bytes (string replace -r 'K$' '000' -- $size_bytes)
        
        split -b $size_bytes "$archive" "$archive.part"
        
        # Create a join script
        echo "#!/bin/sh" > "$archive.join.sh"
        echo "cat $archive.part* > $archive" >> "$archive.join.sh"
        chmod +x "$archive.join.sh"
        
        test $quiet -eq 0; and log info "✓ Archive split complete"
        return 0
    else
        log error "'split' command not found"
        return 1
    end
end