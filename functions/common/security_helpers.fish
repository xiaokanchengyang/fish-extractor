# Security helpers for Fish Pack (fish 4.1.2+)
# Functions for secure handling of sensitive data

function __fish_pack_read_password --description 'Securely read password from user'
    set -l prompt $argv[1]
    test -z "$prompt"; and set prompt "Enter password: "

    # Use read -s for silent input (no echo)
    read -s -P "$prompt" password
    echo # New line after password input

    # Return the password
    echo $password
end

function __fish_pack_secure_temp_file --description 'Create secure temporary file'
    set -l prefix $argv[1]
    test -z "$prefix"; and set prefix fish-pack

    # Create temp file with restricted permissions
    set -l temp_file (mktemp -t "$prefix.XXXXXX")
    chmod 600 "$temp_file"

    echo $temp_file
end

function __fish_pack_secure_temp_dir --description 'Create secure temporary directory'
    set -l prefix $argv[1]
    test -z "$prefix"; and set prefix fish-pack

    # Create temp directory with restricted permissions
    set -l temp_dir (mktemp -d -t "$prefix.XXXXXX")
    chmod 700 "$temp_dir"

    echo $temp_dir
end

function __fish_pack_cleanup_temp --description 'Securely clean up temporary files/directories'
    for item in $argv
        if test -e "$item"
            rm -rf -- "$item" 2>/dev/null
        end
    end
end

function __fish_pack_is_unsafe_path --description 'Check if path is unsafe (path traversal or absolute)'
    set -l path $argv[1]

    # Check for leading slash (absolute path) using regex for precision
    if string match -qr '^/' -- "$path"
        return 0 # True, it is unsafe
    end

    # Check for directory traversal segments (..)
    # Matches: beginning or / followed by .. followed by / or end
    if string match -qr '(^|/)\.\.(/|$)' -- "$path"
        return 0 # True, it is unsafe
    end

    return 1 # False, it is safe
end

function __fish_pack_list_archive_members --description 'List archive members for verification'
    set -l archive $argv[1]
    set -l format $argv[2]

    switch $format
        case tar 'tar.gz' tgz 'tar.bz2' tbz2 'tar.xz' txz 'tar.zst' tzst 'tar.lz4' tlz4
            tar -tf "$archive" 2>/dev/null

        case zip
            # Use zipinfo for simple listing if available
            if command -q zipinfo
                unzip -Z -1 "$archive" 2>/dev/null
            else
                # Fallback: Parse unzip -l output using fish string builtins
                # Matches standard line: "    123  2023-01-01 12:00   filename"
                unzip -l "$archive" 2>/dev/null | string match -r '^\s*[0-9]+\s+[0-9-]+\s+[0-9:]+\s+(.*)$' | string replace -r '^\s*[0-9]+\s+[0-9-]+\s+[0-9:]+\s+' ''
            end

        case 7z
            # 7z l -slt outputs detailed info. We grep Path = 
            7z l -ba -slt "$archive" 2>/dev/null | string match -r '^Path = (.*)' | string replace -r '^Path = ' ''

        case '*'
            return 1
    end
end

function __fish_pack_verify_archive_members --description 'Verify all archive members are safe'
    set -l archive $argv[1]
    set -l format $argv[2]

    set -l members (__fish_pack_list_archive_members "$archive" "$format")

    for member in $members
        if __fish_pack_is_unsafe_path "$member"
            return 1 # Found unsafe path
        end
    end

    return 0 # All safe
end
