# Common archive operations for Fish Archive Manager (fish 4.12+)
# Provides shared functions for compression and extraction operations

# Load core utilities
source (dirname (status --current-filename))/../core.fish
# Load format handlers
source (dirname (status --current-filename))/../format_handlers.fish
# Load error handling
source (dirname (status --current-filename))/../error_handling.fish
# Load safe execution helpers
source (dirname (status --current-filename))/safe_exec.fish

# ============================================================================
# Common Archive Operation Functions
# ============================================================================

function execute_archive_command --description 'Execute archive command with common error handling and progress'
    set -l command $argv[1]
    set -l operation $argv[2]  # compress or extract
    set -l target $argv[3]
    set -l format $argv[4]
    set -l verbose $argv[5]
    set -l progress $argv[6]
    set -l threads $argv[7]
    set -l args $argv[8..-1]
    
    # Check if command exists
    if not has_command $command
        handle_command_error $command $operation
    end
    
    # Build command with common options
    set -l full_command $command
    for arg in $args
        set full_command $full_command $arg
    end
    
    # Execute with progress if enabled
    if test $progress -eq 1; and can_show_progress
        set -l size (get_file_size "$target")
        __fish_pack_exec_with_progress $full_command $size
    else
        __fish_pack_safe_exec $full_command
    end
    
    set -l exit_code $status
    
    # Handle command failure
    if test $exit_code -ne 0
        handle_operation_error $operation "$command $args" $exit_code
    end
    
    return $exit_code
end

function prepare_archive_environment --description 'Prepare environment for archive operations'
    set -l operation $argv[1]  # compress or extract
    set -l format $argv[2]
    set -l threads $argv[3]
    set -l verbose $argv[4]
    
    # Validate format
    if not validate_format_for_operation $format $operation
        return 1
    end
    
    # Check required commands
    if not check_format_requirements $format $operation
        return 127
    end
    
    # Resolve thread count
    set -l thread_count (resolve_threads $threads)
    
    return 0
end

function build_common_tar_options --description 'Build common tar options for both compress and extract'
    set -l operation $argv[1]  # compress or extract
    set -l format $argv[2]
    set -l verbose $argv[3]
    set -l threads $argv[4]
    set -l progress $argv[5]
    set -l strip $argv[6]
    set -l chdir $argv[7]
    
    set -l opts
    
    # Base operation
    if test "$operation" = "extract"
        set -a opts -xpf
    else
        set -a opts -cf
    end
    
    # Verbose
    if test $verbose -eq 1
        set -a opts -v
    end
    
    # Strip components (extract only)
    if test "$operation" = "extract"; and test $strip -gt 0
        set -a opts --strip-components=$strip
    end
    
    # Change directory
    if test -n "$chdir"
        set -a opts -C "$chdir"
    end
    
    # Compression option
    set -l comp_opt (get_tar_compression_option $format)
    if test -n "$comp_opt"
        set -a opts $comp_opt
    end
    
    # Threading (for supported formats)
    if supports_threading $format; and test $threads -gt 1
        switch $format
            case tar.xz
                set -a opts --use-compress-program="xz -T$threads"
            case tar.zst
                set -a opts --use-compress-program="zstd -T$threads"
        end
    end
    
    echo $opts
end

function execute_tar_operation --description 'Execute tar operation with common logic'
    set -l operation $argv[1]  # compress or extract
    set -l archive $argv[2]
    set -l format $argv[3]
    set -l files $argv[4..-8]
    set -l verbose $argv[-7]
    set -l threads $argv[-6]
    set -l progress $argv[-5]
    set -l strip $argv[-4]
    set -l chdir $argv[-3]
    set -l dest $argv[-2]
    
    require_commands tar; or return 127
    
    # Build tar options
    set -l tar_opts (build_common_tar_options $operation $format $verbose $threads $progress $strip $chdir)
    
    # Add destination for extract
    if test "$operation" = "extract"
        set -a tar_opts -C "$dest"
    end
    
    # Add archive file
    set -a tar_opts -f "$archive"
    
    # Add files for compress
    if test "$operation" = "compress"
        for file in $files
            set -a tar_opts $file
        end
    end
    
    # Execute with or without progress
    if test $progress -eq 1; and can_show_progress
        set -l size (get_file_size "$archive")
        if test $size -gt 10485760  # 10MB
            show_progress_bar $size < "$archive" | tar $tar_opts -f -
        else
            tar $tar_opts
        end
    else
        tar $tar_opts
    end
end

function execute_zip_operation --description 'Execute zip/unzip operation with common logic'
    set -l operation $argv[1]  # compress or extract
    set -l archive $argv[2]
    set -l files $argv[3..-8]
    set -l level $argv[-7]
    set -l encrypt $argv[-6]
    set -l password $argv[-5]
    set -l verbose $argv[-4]
    set -l update $argv[-3]
    set -l dest $argv[-2]
    
    if test "$operation" = "extract"
        require_commands unzip; or return 127
        set -l zip_opts (build_zip_options $operation $level $encrypt $password $verbose $update)
        set -a zip_opts -d "$dest"
        unzip -o $zip_opts "$archive"
    else
        require_commands zip; or return 127
        set -l zip_opts (build_zip_options $operation $level $encrypt $password $verbose $update)
        if test -n "$dest"
            pushd "$dest" >/dev/null
            zip $zip_opts "$archive" $files
            set -l status_code $status
            popd >/dev/null
            return $status_code
        else
            zip $zip_opts "$archive" $files
        end
    end
end

function execute_7z_operation --description 'Execute 7z operation with common logic'
    set -l operation $argv[1]  # compress or extract
    set -l archive $argv[2]
    set -l files $argv[3..-9]
    set -l level $argv[-8]
    set -l threads $argv[-7]
    set -l encrypt $argv[-6]
    set -l password $argv[-5]
    set -l solid $argv[-4]
    set -l verbose $argv[-3]
    set -l update $argv[-2]
    set -l dest $argv[-1]
    
    require_commands 7z; or return 127
    
    set -l opts (build_7z_options $operation $level $threads $encrypt $password $solid $verbose $update)
    
    if test "$operation" = "extract"
        set -a opts -o"$dest"
    end
    
    if test $verbose -eq 1
        7z $opts "$archive" $files
    else
        7z $opts "$archive" $files >/dev/null
    end
end

function execute_compressed_file_operation --description 'Execute single compressed file operation'
    set -l operation $argv[1]  # compress or extract
    set -l format $argv[2]
    set -l file $argv[3]
    set -l dest $argv[4]
    set -l threads $argv[5]
    
    # Get appropriate command
    if test "$operation" = "extract"
        set -l cmd (get_decompression_command $format)
    else
        set -l cmd (get_compression_command $format 1)
    end
    
    if test "$cmd" = "unknown"
        log error "No command available for $format $operation"
        return 127
    end
    
    require_commands $cmd; or return 127
    
    # Ensure destination directory exists
    if test "$operation" = "extract"
        test -d "$dest"; or mkdir -p "$dest"
        
        # Determine output filename
        set -l basename (basename "$file")
        set -l outfile "$dest/"(string replace -r '\\.[^.]+$' '' -- $basename)
        
        # Execute decompression
        switch $cmd
            case gunzip
                gzip -dc "$file" > "$outfile"
            case bunzip2
                bzip2 -dc "$file" > "$outfile"
            case unxz
                set -l xz_opts -dc
                test $threads -gt 1; and set -a xz_opts -T$threads
                xz $xz_opts "$file" > "$outfile"
            case unzstd
                set -l zstd_opts -dc
                test $threads -gt 1; and set -a zstd_opts -T$threads
                zstd $zstd_opts "$file" > "$outfile"
            case unlz4
                lz4 -dc "$file" > "$outfile"
            case lunzip
                lzip -dc "$file" > "$outfile"
            case brotli
                brotli -dc "$file" > "$outfile"
        end
    else
        # Compression for single files using modern compressors
        switch $cmd
            case gzip
                gzip -c "$file" > "$file.gz"
            case pigz
                set -l pigz_opts -c
                test $threads -gt 1; and set -a pigz_opts -p $threads
                pigz $pigz_opts "$file" > "$file.gz"
            case bzip2
                bzip2 -c "$file" > "$file.bz2"
            case pbzip2
                set -l pbzip2_opts -c
                test $threads -gt 1; and set -a pbzip2_opts -p$threads
                pbzip2 $pbzip2_opts "$file" > "$file.bz2"
            case xz
                set -l xz_opts -c
                test $threads -gt 1; and set -a xz_opts -T$threads
                xz $xz_opts "$file" > "$file.xz"
            case zstd
                set -l zstd_opts -c
                test $threads -gt 1; and set -a zstd_opts -T$threads
                zstd $zstd_opts "$file" > "$file.zst"
            case lz4
                lz4 -c "$file" > "$file.lz4"
            case lzip
                lzip -c "$file" > "$file.lz"
            case lzop
                lzop -c "$file" > "$file.lzo"
            case brotli
                brotli -c "$file" > "$file.br"
            case '*'
                log error "Compression command not supported for format: $format"
                return 1
        end
    end
end

function validate_archive_common --description 'Common archive validation for both operations'
    set -l archive $argv[1]
    set -l operation $argv[2]
    set -l format $argv[3]
    set -l password $argv[4]
    set -l encrypt $argv[5]
    
    # Validate archive file
    if not validate_archive "$archive"
        return 1
    end
    
    # Check encryption requirements
    if test $encrypt -eq 1; and test -z "$password"
        log error "Password required for encrypted archives"
        return 1
    end
    
    # Check format-specific requirements
    switch $format
        case zip 7z
            # These formats support encryption
            return 0
        case '*'
            if test $encrypt -eq 1
                log error "Encryption not supported for format: $format"
                return 1
            end
    end
    
    return 0
end

function show_operation_progress --description 'Show operation progress with common formatting'
    set -l operation $argv[1]  # compress or extract
    set -l target $argv[2]
    set -l format $argv[3]
    set -l size $argv[4]
    set -l verbose $argv[5]
    set -l quiet $argv[6]
    set -l current $argv[7]
    set -l total $argv[8]
    
    if not is_quiet $quiet
        if test $total -gt 1
            log info "[$current/$total] $operation: $target"
        else
            log info "$operation: $target"
        end
        
        if should_show_verbose $verbose $quiet
            log debug "  Format: $format"
            log debug "  Size: "(human_size $size)
        end
    end
end

function show_operation_summary --description 'Show operation summary with common formatting'
    set -l operation $argv[1]  # compress or extract
    set -l success_count $argv[2]
    set -l fail_count $argv[3]
    set -l total $argv[4]
    set -l quiet $argv[5]
    
    if not is_quiet $quiet; and test $total -gt 1
        echo ""
        if test $fail_count -eq 0
            colorize green "✓ All $operation operations completed successfully ($success_count/$total)\n"
        else
            colorize yellow "⚠ $operation summary: $success_count succeeded, $fail_count failed\n"
        end
    end
end