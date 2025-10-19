# Security helpers for Fish Pack (fish 4.1.2+)
# Functions for secure handling of sensitive data

function __fish_pack_read_password --description 'Securely read password from user'
    set -l prompt $argv[1]
    test -z "$prompt"; and set prompt "Enter password: "
    
    # Use read -s for silent input (no echo)
    read -s -P "$prompt" password
    echo  # New line after password input
    
    # Return the password
    echo $password
end

function __fish_pack_secure_temp_file --description 'Create secure temporary file'
    set -l prefix $argv[1]
    test -z "$prefix"; and set prefix "fish-pack"
    
    # Create temp file with restricted permissions
    set -l temp_file (mktemp -t "$prefix.XXXXXX")
    chmod 600 "$temp_file"
    
    echo $temp_file
end

function __fish_pack_secure_temp_dir --description 'Create secure temporary directory'
    set -l prefix $argv[1]
    test -z "$prefix"; and set prefix "fish-pack"
    
    # Create temp directory with restricted permissions
    set -l temp_dir (mktemp -d -t "$prefix.XXXXXX")
    chmod 700 "$temp_dir"
    
    echo $temp_dir
end

function __fish_pack_cleanup_temp --description 'Securely clean up temporary files/directories'
    for item in $argv
        if test -e "$item"
            if test -d "$item"
                rm -rf -- "$item" 2>/dev/null
            else
                # Overwrite file content before deletion for security
                if test -w "$item"
                    dd if=/dev/urandom of="$item" bs=1024 count=1 2>/dev/null
                end
                rm -f -- "$item" 2>/dev/null
            end
        end
    end
end

function __fish_pack_check_path_traversal --description 'Check for path traversal attempts'
    set -l path $argv[1]
    
    # Check for dangerous patterns
    if string match -q '*../*' -- "$path"; or string match -q '*..*' -- "$path"
        return 1
    end
    
    # Check for absolute paths when they shouldn't be allowed
    if string match -q '/*' -- "$path"; and not set -q argv[2]
        return 1
    end
    
    return 0
end

function __fish_pack_sanitize_archive_member --description 'Sanitize archive member path'
    set -l member $argv[1]
    set -l base_dir $argv[2]
    
    # Remove leading slashes
    set member (string replace -r '^/+' '' -- "$member")
    
    # Remove ../ sequences
    set member (string replace -r '\.\./+' '' -- "$member")
    
    # Ensure path doesn't escape base directory
    if test -n "$base_dir"
        set -l resolved (realpath -m "$base_dir/$member" 2>/dev/null)
        set -l base_resolved (realpath "$base_dir" 2>/dev/null)
        
        if not string match -q "$base_resolved/*" -- "$resolved"
            return 1
        end
    end
    
    echo $member
    return 0
end

function __fish_pack_verify_archive_members --description 'Verify all archive members are safe'
    set -l archive $argv[1]
    set -l format $argv[2]
    
    set -l unsafe_members
    
    switch $format
        case 'tar' 'tar.gz' 'tgz' 'tar.bz2' 'tbz2' 'tar.xz' 'txz' 'tar.zst' 'tzst' 'tar.lz4' 'tlz4'
            # List tar members
            set -l members (tar -tf "$archive" 2>/dev/null)
            for member in $members
                if not __fish_pack_check_path_traversal "$member"
                    set -a unsafe_members "$member"
                end
            end
            
        case 'zip'
            # List zip members
            set -l members (unzip -l "$archive" 2>/dev/null | awk 'NR>3 && NF>3 {print $NF}')
            for member in $members
                if not __fish_pack_check_path_traversal "$member"
                    set -a unsafe_members "$member"
                end
            end
            
        case '7z'
            # List 7z members
            set -l members (7z l -slt "$archive" 2>/dev/null | grep "^Path = " | cut -d' ' -f3-)
            for member in $members
                if not __fish_pack_check_path_traversal "$member"
                    set -a unsafe_members "$member"
                end
            end
    end
    
    if test (count $unsafe_members) -gt 0
        __fish_archive_log error "Archive contains unsafe paths:"
        for member in $unsafe_members
            __fish_archive_log error "  - $member"
        end
        return 1
    end
    
    return 0
end

function __fish_pack_secure_command --description 'Build secure command avoiding shell injection'
    # This function helps build commands safely without using eval
    # It returns a properly escaped command string
    
    set -l cmd $argv[1]
    set -l args $argv[2..-1]
    
    # Ensure command exists
    if not command -q "$cmd"
        return 1
    end
    
    # Build command with proper quoting
    set -l safe_args
    for arg in $args
        # Escape special characters
        set -l escaped (string escape -- "$arg")
        set -a safe_args "$escaped"
    end
    
    # Return the command and arguments as separate items
    echo "$cmd"
    for arg in $safe_args
        echo "$arg"
    end
end

function __fish_pack_handle_password --description 'Handle password for archives securely'
    set -l format $argv[1]
    set -l password $argv[2]
    set -l operation $argv[3] # 'compress' or 'extract'
    
    # If no password provided, return empty
    if test -z "$password"
        return 0
    end
    
    # Different formats handle passwords differently
    switch $format
        case 'zip'
            if test "$operation" = "compress"
                # For zip compression, we need to use stdin
                # Create a temporary file with restricted permissions
                set -l pass_file (__fish_pack_secure_temp_file "zip-pass")
                echo "$password" > "$pass_file"
                echo "--password-file=$pass_file"
                # Caller must clean up the temp file
            else
                # For extraction, use -P
                echo "-P"
                echo "$password"
            end
            
        case '7z'
            # 7z uses -p flag directly
            echo "-p$password"
            
        case '*'
            # Other formats don't support passwords
            return 1
    end
end