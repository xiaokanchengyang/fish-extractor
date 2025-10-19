# Safe command execution for Fish Pack (fish 4.1.2+)
# Replaces eval with safer alternatives

function __fish_pack_safe_exec --description 'Execute command safely without eval'
    # This function executes commands without using eval
    # It properly handles arguments with spaces and special characters
    
    set -l cmd $argv[1]
    set -l args $argv[2..-1]
    
    # Ensure command exists
    if not command -q "$cmd"
        __fish_archive_log error "Command not found: $cmd"
        return 127
    end
    
    # Execute command directly with proper argument handling
    "$cmd" $args
end

function __fish_pack_safe_pipe_exec --description 'Execute command with pipe safely'
    # Execute command that needs piping without eval
    set -l cmd1_parts $argv[1]
    set -l pipe_to $argv[2]
    set -l remaining $argv[3..-1]
    
    # Parse the first command
    set -l cmd1 (string split -- ' ' $cmd1_parts)
    
    # Execute with pipe
    if test -n "$pipe_to"
        $cmd1 | $pipe_to $remaining
    else
        $cmd1
    end
end

function __fish_pack_build_tar_command --description 'Build tar command with compression program'
    set -l operation $argv[1]  # 'compress' or 'extract'
    set -l compression $argv[2]  # 'gzip', 'bzip2', 'xz', 'zstd', etc.
    set -l threads $argv[3]
    set -l archive $argv[4]
    set -l files $argv[5..-1]
    
    set -l tar_args
    
    # Base tar operation
    switch $operation
        case compress
            set -a tar_args -c
        case extract
            set -a tar_args -x
        case list
            set -a tar_args -t
    end
    
    # Add compression based on type
    switch $compression
        case gzip gz
            if __fish_archive_has_command pigz; and test $threads -gt 1
                # Use pigz for parallel compression
                if test "$operation" = "compress"
                    set -a tar_args --use-compress-program="pigz -p $threads"
                else
                    set -a tar_args --use-compress-program="pigz -d -p $threads"
                end
            else
                set -a tar_args -z
            end
            
        case bzip2 bz2
            if __fish_archive_has_command pbzip2; and test $threads -gt 1
                # Use pbzip2 for parallel compression
                if test "$operation" = "compress"
                    set -a tar_args --use-compress-program="pbzip2 -p$threads"
                else
                    set -a tar_args --use-compress-program="pbzip2 -d -p$threads"
                end
            else
                set -a tar_args -j
            end
            
        case xz
            if __fish_archive_has_command pxz; and test $threads -gt 1
                # Use pxz for parallel compression
                set -a tar_args --use-compress-program="pxz -T $threads"
            else
                set -a tar_args -J
            end
            
        case zstd zst
            # zstd supports threading natively
            set -a tar_args --use-compress-program="zstd -T$threads"
            
        case lz4
            set -a tar_args --use-compress-program="lz4"
            
        case lzip lz
            set -a tar_args --use-compress-program="lzip"
            
        case lzop lzo
            set -a tar_args --use-compress-program="lzop"
            
        case brotli br
            set -a tar_args --use-compress-program="brotli"
    end
    
    # Add file argument
    set -a tar_args -f "$archive"
    
    # Add files for compression or directory for extraction
    if test "$operation" = "extract"; and test -n "$files[1]"
        set -a tar_args -C "$files[1]"
    else if test "$operation" = "compress"
        set -a tar_args $files
    end
    
    # Return the complete tar command
    echo tar $tar_args
end

function __fish_pack_exec_with_progress --description 'Execute command with progress bar'
    set -l cmd $argv[1..-2]
    set -l size $argv[-1]
    
    if test $size -gt 10485760  # 10MB
        # Execute command and pipe to progress bar
        $cmd | __fish_archive_show_progress_bar $size
    else
        # Execute directly for small files
        $cmd
    end
end