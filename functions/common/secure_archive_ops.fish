# Secure archive operations for Fish Pack (fish 4.1.2+)
# Provides secure password handling and command execution

# Load security helpers
source (dirname (status --current-filename))/security_helpers.fish
source (dirname (status --current-filename))/optimized_common.fish

function __fish_pack_execute_with_password --description 'Execute archive command with secure password handling'
    set -l command $argv[1]
    set -l format $argv[2]
    set -l password $argv[3]
    set -l operation $argv[4]  # 'compress' or 'extract'
    set -l args $argv[5..-1]
    
    # No password needed
    if test -z "$password"
        $command $args
        return $status
    end
    
    # Handle password based on format and operation
    switch $format
        case 'zip'
            if test "$operation" = "compress"
                # For zip compression with password, we need special handling
                # zip doesn't support password from stdin well
                # Create secure temp file
                set -l pass_file (__fish_pack_secure_temp_file "zip-pass")
                echo -n "$password" > "$pass_file"
                
                # Modify args to use password file
                set -l new_args
                for arg in $args
                    if test "$arg" = "-e"
                        set -a new_args "-e" "--password-file=$pass_file"
                    else if not string match -q -- "-P*" "$arg"
                        set -a new_args "$arg"
                    end
                end
                
                # Execute command
                $command $new_args
                set -l result $status
                
                # Clean up
                __fish_pack_cleanup_temp "$pass_file"
                return $result
                
            else
                # For extraction, unzip needs password on command line
                # We'll use expect if available, otherwise fall back
                if command -q expect
                    # Use expect to provide password interactively
                    set -l expect_script (__fish_pack_secure_temp_file "unzip-expect")
                    echo '#!/usr/bin/expect -f
set password [lindex $argv 0]
set zipfile [lindex $argv 1]
set args [lrange $argv 2 end]
spawn unzip {*}$args $zipfile
expect "password:"
send "$password\r"
expect eof
catch wait result
exit [lindex $result 3]' > "$expect_script"
                    chmod +x "$expect_script"
                    
                    expect "$expect_script" "$password" $args
                    set -l result $status
                    
                    __fish_pack_cleanup_temp "$expect_script"
                    return $result
                else
                    # Fall back to command line (less secure)
                    __fish_archive_log warn "Using command-line password (less secure). Install 'expect' for better security."
                    $command -P "$password" $args
                    return $status
                end
            end
            
        case '7z'
            # 7z can read password from stdin
            echo "$password" | $command -si $args
            return $status
            
        case 'rar'
            # unrar can read password from stdin with -p-
            echo "$password" | $command -p- $args
            return $status
            
        case '*'
            # Other formats don't support passwords
            __fish_archive_log error "Format $format does not support passwords"
            return 1
    end
end

function __fish_pack_prepare_secure_extraction --description 'Prepare extraction with security checks'
    set -l archive $argv[1]
    set -l format $argv[2]
    set -l destination $argv[3]
    set -l password $argv[4]
    set -l options $argv[5..-1]
    
    # First, verify archive members for path traversal
    if not __fish_pack_verify_archive_members "$archive" "$format"
        __fish_archive_log error "Archive contains unsafe paths. Extraction aborted for security."
        return 1
    end
    
    # Create secure destination if needed
    if test -n "$destination"
        if not test -d "$destination"
            mkdir -p "$destination" 2>/dev/null; or begin
                __fish_archive_log error "Failed to create destination: $destination"
                return 1
            end
        end
        
        # Ensure destination is writable
        if not test -w "$destination"
            __fish_archive_log error "Destination not writable: $destination"
            return 1
        end
    end
    
    # Build extraction command
    set -l args (__fish_archive_prepare_extraction_args "$format" $options "$archive" "$destination")
    
    # Execute with secure password handling
    __fish_pack_execute_with_password (echo $args[1]) "$format" "$password" "extract" $args[2..-1]
end

function __fish_pack_prepare_secure_compression --description 'Prepare compression with security features'
    set -l output $argv[1]
    set -l format $argv[2]
    set -l password $argv[3]
    set -l inputs $argv[4..-1]
    
    # Validate inputs
    for input in $inputs
        if not test -e "$input"
            __fish_archive_log error "Input not found: $input"
            return 1
        end
    end
    
    # Check output directory is writable
    set -l output_dir (dirname "$output")
    if not test -w "$output_dir"
        __fish_archive_log error "Cannot write to directory: $output_dir"
        return 1
    end
    
    # Build compression command
    set -l args (__fish_archive_prepare_compression_args "$format" 6 4 0 (test -n "$password"; and echo 1; or echo 0) "" "$output" $inputs)
    
    # Execute with secure password handling
    __fish_pack_execute_with_password (echo $args[1]) "$format" "$password" "compress" $args[2..-1]
end

function __fish_pack_secure_extract --description 'Secure extraction wrapper'
    set -l archive $argv[1]
    set -l destination $argv[2]
    set -l password $argv[3]
    set -l format $argv[4]
    set -l threads $argv[5]
    set -l strip $argv[6]
    set -l flat $argv[7]
    set -l preserve_perms $argv[8]
    
    # If password is needed but not provided, prompt for it
    if test -z "$password"; and __fish_archive_is_encrypted "$archive" "$format"
        set password (__fish_pack_read_password "Archive password: ")
    end
    
    # Prepare and execute secure extraction
    __fish_pack_prepare_secure_extraction "$archive" "$format" "$destination" "$password" \
        $threads $strip $flat $preserve_perms
end

function __fish_pack_secure_compress --description 'Secure compression wrapper'
    set -l output $argv[1]
    set -l format $argv[2]
    set -l encrypt $argv[3]
    set -l password $argv[4]
    set -l level $argv[5]
    set -l threads $argv[6]
    set -l inputs $argv[7..-1]
    
    # If encryption requested but no password provided, prompt for it
    if test $encrypt -eq 1; and test -z "$password"
        set password (__fish_pack_read_password "Archive password: ")
        set -l confirm (__fish_pack_read_password "Confirm password: ")
        
        if test "$password" != "$confirm"
            __fish_archive_log error "Passwords do not match"
            return 1
        end
    end
    
    # Prepare and execute secure compression
    __fish_pack_prepare_secure_compression "$output" "$format" "$password" $inputs
end