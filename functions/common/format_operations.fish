# Common format operations for Fish Archive Manager (fish 4.12+)
# Provides shared functions for format detection, validation, and command selection

# Load core utilities
source (dirname (status --current-filename))/../core.fish
# Load format handlers
source (dirname (status --current-filename))/../format_handlers.fish
# Load error handling
source (dirname (status --current-filename))/../error_handling.fish

# ============================================================================
# Format Detection and Validation
# ============================================================================

function detect_archive_format --description 'Detect archive format with fallback methods'
    set -l file $argv[1]
    
    # First try extension-based detection
    set -l ext_format (get_format_from_extension $file)
    if test "$ext_format" != "unknown"
        echo $ext_format
        return 0
    end
    
    # Try MIME type detection
    set -l mime (get_mime_type $file)
    if test -n "$mime"
        set -l mime_format (get_format_from_mime $mime)
        if test "$mime_format" != "unknown"
            echo $mime_format
            return 0
        end
    end
    
    # Fallback to unknown
    echo "unknown"
    return 1
end

function validate_format_support --description 'Validate format is supported for operation'
    set -l format $argv[1]
    set -l operation $argv[2]  # compress or extract
    
    if not validate_format_for_operation $format $operation
        report_error $FISH_ARCHIVE_ERROR_INVALID_FORMAT "Format $format not supported for $operation" $FISH_ARCHIVE_ERROR "format:$format" "operation:$operation"
    end
end

function check_format_dependencies --description 'Check if required tools are available for format'
    set -l format $argv[1]
    set -l operation $argv[2]  # compress or extract
    
    if not check_format_requirements $format $operation
        return 127
    end
    
    return 0
end

# ============================================================================
# Smart Format Selection
# ============================================================================

function select_smart_format --description 'Select optimal format based on content analysis'
    set -l inputs $argv
    
    # Analyze content
    set -l analysis (analyze_archive_content $inputs)
    set -l total_files $analysis[1]
    set -l text_files $analysis[2]
    set -l total_size $analysis[3]
    set -l compressible_size $analysis[4]
    
    # Decision logic based on analysis
    if test $total_files -eq 0
        echo tar.zst  # Default
        return
    end
    
    # Calculate text ratio
    set -l text_ratio 0
    if test $total_files -gt 0
        set text_ratio (math -s0 "$text_files * 100 / $total_files")
    end
    
    # Calculate compressible size ratio
    set -l compress_ratio 0
    if test $total_size -gt 0
        set compress_ratio (math -s0 "$compressible_size * 100 / $total_size")
    end
    
    log debug "Content analysis: $total_files files, $text_ratio% text files, $compress_ratio% compressible by size"
    
    # Selection heuristics
    if test $text_ratio -ge 70; or test $compress_ratio -ge 70
        # High text content: use xz for maximum compression
        log info "Detected high text content, choosing tar.xz for maximum compression"
        echo tar.xz
    else if test $text_ratio -ge 30; or test $compress_ratio -ge 40
        # Mixed content: use gzip for compatibility and decent compression
        log info "Detected mixed content, choosing tar.gz for balance"
        echo tar.gz
    else
        # Binary/multimedia heavy: use zstd for speed and good compression
        log info "Detected binary content, choosing tar.zst for speed"
        echo tar.zst
    end
end

function normalize_output_format --description 'Normalize output format and update filename if needed'
    set -l output_path $argv[1]
    set -l format $argv[2]
    set -l smart $argv[3]
    
    set -l normalized_format (normalize_format $format)
    
    # If smart mode or auto format, detect from filename or use smart selection
    if test $smart -eq 1; or test "$normalized_format" = "auto"
        # Detect from output filename if it has an extension
        set -l detected (detect_format "$output_path")
        if test "$detected" != "unknown"
            set normalized_format $detected
            log debug "Detected format from filename: $normalized_format"
        else
            # Use smart selection (this would need input files, so just use default)
            set normalized_format "tar.zst"
            log info "Smart format selected: $normalized_format"
        end
        
        # Update output filename with appropriate extension
        set -l base_name (string replace -r '\.[^.]+$' '' -- (basename $output_path))
        set -l dir_name (dirname $output_path)
        set output_path "$dir_name/$base_name."(string replace tar. '' -- $normalized_format)
    end
    
    echo $normalized_format
    echo $output_path
end

# ============================================================================
# Command Selection and Building
# ============================================================================

function get_optimal_command --description 'Get optimal command for format and operation'
    set -l format $argv[1]
    set -l operation $argv[2]  # compress or extract
    set -l parallel $argv[3]
    
    if test "$operation" = "extract"
        get_decompression_command $format
    else
        get_compression_command $format $parallel
    end
end

function build_format_specific_options --description 'Build format-specific options'
    set -l format $argv[1]
    set -l operation $argv[2]  # compress or extract
    set -l args $argv[3..-1]
    
    if is_tar_format $format
        build_common_tar_options $operation $format $args
    else
        switch $format
            case zip
                build_zip_options $operation $args
            case 7z
                build_7z_options $operation $args
            case '*'
                log error "Unsupported format for option building: $format"
                return 1
        end
    end
end

# ============================================================================
# Format Capability Checks
# ============================================================================

function check_format_capabilities --description 'Check what capabilities a format supports'
    set -l format $argv[1]
    
    set -l capabilities
    
    if supports_encryption $format
        set -a capabilities "encryption"
    end
    
    if supports_threading $format
        set -a capabilities "threading"
    end
    
    if supports_solid $format
        set -a capabilities "solid"
    end
    
    if is_compressed_format $format
        set -a capabilities "compression"
    end
    
    echo $capabilities
end

function validate_format_options --description 'Validate options against format capabilities'
    set -l format $argv[1]
    set -l encrypt $argv[2]
    set -l solid $argv[3]
    set -l threads $argv[4]
    
    # Check encryption support
    if test $encrypt -eq 1; and not supports_encryption $format
        log error "Encryption not supported for format: $format"
        return 1
    end
    
    # Check solid compression support
    if test $solid -eq 1; and not supports_solid $format
        log error "Solid compression not supported for format: $format"
        return 1
    end
    
    # Check threading support
    if test $threads -gt 1; and not supports_threading $format
        log warn "Multi-threading not supported for format: $format, using single thread"
    end
    
    return 0
end

# ============================================================================
# Format-Specific Command Execution
# ============================================================================

function execute_format_command --description 'Execute command for specific format'
    set -l format $argv[1]
    set -l operation $argv[2]  # compress or extract
    set -l args $argv[3..-1]
    
    if is_tar_format $format
        execute_tar_operation $operation $args
    else
        switch $format
            case zip
                execute_zip_operation $operation $args
            case 7z
                execute_7z_operation $operation $args
            case rar
                execute_rar_operation $operation $args
            case gzip gz bzip2 bz2 xz zstd zst lz4 lz lzip lzo brotli br
                execute_compressed_file_operation $operation $args
            case iso deb rpm
                execute_package_operation $operation $args
            case '*'
                log error "Unsupported format: $format"
                return 1
        end
    end
end

function execute_rar_operation --description 'Execute RAR operation with fallback'
    set -l operation $argv[1]  # extract only
    set -l archive $argv[2]
    set -l dest $argv[3]
    set -l password $argv[4]
    set -l verbose $argv[5]
    
    if has_command unrar
        set -l opts x -y -idq
        test -n "$password"; and set -a opts -p"$password"
        unrar $opts "$archive" "$dest/"
    else if has_command bsdtar
        log warn "unrar not found, using bsdtar (may have limitations)"
        bsdtar -xpf "$archive" -C "$dest"
    else
        log error "Neither unrar nor bsdtar available for RAR extraction"
        return 127
    end
end

function execute_package_operation --description 'Execute package file operation'
    set -l operation $argv[1]  # extract only
    set -l archive $argv[2]
    set -l dest $argv[3]
    set -l format $argv[4]
    set -l verbose $argv[5]
    
    if has_command bsdtar
        bsdtar -xpf "$archive" -C "$dest"
    else if has_command 7z
        log warn "bsdtar not found, using 7z for $format extraction"
        7z x -y -o"$dest" "$archive" >/dev/null
    else
        log error "bsdtar or 7z required for $format extraction"
        return 127
    end
end

# ============================================================================
# Format Testing and Verification
# ============================================================================

function test_format_integrity --description 'Test format integrity'
    set -l archive $argv[1]
    set -l format $argv[2]
    
    switch $format
        case tar tar.gz tgz tar.bz2 tbz2 tar.xz txz tar.zst tzst tar.lz4
            require_commands tar; or return 127
            set -l opts -tf
            
            switch $format
                case tar.gz tgz
                    set -a opts -z
                case tar.bz2 tbz2
                    set -a opts -j
                case tar.xz txz
                    set -a opts -J
                case tar.zst tzst
                    set -a opts --zstd
                case tar.lz4 tlz4
                    set -a opts --use-compress-program=lz4
            end
            
            tar $opts "$archive" >/dev/null 2>&1
            
        case zip
            require_commands unzip; or return 127
            unzip -t "$archive" >/dev/null 2>&1
            
        case 7z
            require_commands 7z; or return 127
            7z t "$archive" >/dev/null 2>&1
            
        case rar
            if has_command unrar
                unrar t "$archive" >/dev/null 2>&1
            else
                log warn "Cannot test RAR without unrar"
                return 1
            end
            
        case gzip gz bzip2 bz2 xz zstd zst lz4 lz lzip lzo brotli br
            set -l cmd (get_decompression_command $format)
            if test "$cmd" != "unknown"
                require_commands $cmd; or return 127
                eval $cmd -t "$archive" 2>&1
            else
                return 1
            end
            
        case '*'
            if has_command 7z
                7z t "$archive" >/dev/null 2>&1
            else
                log warn "Cannot test this format"
                return 1
            end
    end
end

function list_format_contents --description 'List contents of format'
    set -l archive $argv[1]
    set -l format $argv[2]
    
    log info "Contents of $archive:"
    echo ""
    
    switch $format
        case tar tar.gz tgz tar.bz2 tbz2 tar.xz txz tar.zst tzst tar.lz4 tar.lz tar.lzo tar.br
            require_commands tar; or return 127
            set -l opts -tf
            
            switch $format
                case tar.gz tgz
                    set -a opts -z
                case tar.bz2 tbz2
                    set -a opts -j
                case tar.xz txz
                    set -a opts -J
                case tar.zst tzst
                    set -a opts --zstd
                case tar.lz4 tlz4
                    set -a opts --use-compress-program=lz4
                case tar.lz tlz
                    set -a opts --lzip
            end
            
            tar $opts "$archive"
            
        case zip
            require_commands unzip; or return 127
            unzip -l "$archive"
            
        case 7z
            require_commands 7z; or return 127
            7z l "$archive"
            
        case rar
            if has_command unrar
                unrar l "$archive"
            else if has_command bsdtar
                bsdtar -tf "$archive"
            else
                return 127
            end
            
        case '*'
            if has_command bsdtar
                bsdtar -tf "$archive"
            else if has_command 7z
                7z l "$archive"
            else
                log error "No tool available for listing"
                return 127
            end
    end
end