# Format handling functions for Fish Archive Manager (fish 4.12+)
# Provides unified format detection, validation, and command selection

# Load error handling
source (dirname (status --current-filename))/error_handling.fish

# ============================================================================
# Format Definitions and Mappings
# ============================================================================

function get_format_aliases --description 'Get format aliases mapping'
    echo "tgz:tar.gz"
    echo "tbz:tar.bz2"
    echo "tbz2:tar.bz2"
    echo "txz:tar.xz"
    echo "tzst:tar.zst"
    echo "tlz4:tar.lz4"
    echo "tlz:tar.lz"
    echo "tzo:tar.lzo"
    echo "tbr:tar.br"
    echo "7zip:7z"
end

function normalize_format --description 'Normalize format aliases to standard names'
    set -l format $argv[1]
    
    # Check aliases
    for alias_pair in (get_format_aliases)
        set -l parts (string split : -- $alias_pair)
        if test "$format" = "$parts[1]"
            echo $parts[2]
            return
        end
    end
    
    echo $format
end

# ============================================================================
# Format Categories and Capabilities
# ============================================================================

function is_tar_format --description 'Check if format is a tar variant'
    set -l format $argv[1]
    string match -q "tar*" -- $format
end

function is_compressed_format --description 'Check if format uses compression'
    set -l format $argv[1]
    string match -q "tar.*" -- $format; or string match -q "zip" -- $format; or string match -q "7z" -- $format
end

function supports_encryption --description 'Check if format supports encryption'
    set -l format $argv[1]
    string match -q "zip" -- $format; or string match -q "7z" -- $format
end

function supports_threading --description 'Check if format supports multi-threading'
    set -l format $argv[1]
    string match -q "tar.xz" -- $format; or string match -q "tar.zst" -- $format; or string match -q "7z" -- $format
end

function supports_solid --description 'Check if format supports solid compression'
    set -l format $argv[1]
    string match -q "7z" -- $format
end

# ============================================================================
# Command Selection
# ============================================================================

function get_compression_command --description 'Get compression command for format'
    set -l format $argv[1]
    set -l parallel $argv[2]
    
    switch $format
        case gzip tar.gz
            if test $parallel -eq 1; and has_command pigz
                echo "pigz"
            else
                echo "gzip"
            end
        case bzip2 tar.bz2
            if test $parallel -eq 1; and has_command pbzip2
                echo "pbzip2"
            else
                echo "bzip2"
            end
        case xz tar.xz
            echo "xz"
        case zstd tar.zst
            echo "zstd"
        case lz4 tar.lz4
            echo "lz4"
        case lzip tar.lz
            echo "lzip"
        case lzop tar.lzo
            echo "lzop"
        case brotli tar.br
            echo "brotli"
        case zip
            echo "zip"
        case 7z
            echo "7z"
        case '*'
            echo "unknown"
    end
end

function get_decompression_command --description 'Get decompression command for format'
    set -l format $argv[1]
    
    switch $format
        case gzip tar.gz
            echo "gunzip"
        case bzip2 tar.bz2
            echo "bunzip2"
        case xz tar.xz
            echo "unxz"
        case zstd tar.zst
            echo "unzstd"
        case lz4 tar.lz4
            echo "unlz4"
        case lzip tar.lz
            echo "lunzip"
        case lzop tar.lzo
            echo "lzop"
        case brotli tar.br
            echo "brotli"
        case zip
            echo "unzip"
        case 7z
            echo "7z"
        case rar
            if has_command unrar
                echo "unrar"
            else if has_command bsdtar
                echo "bsdtar"
            else
                echo "unknown"
            end
        case '*'
            echo "unknown"
    end
end

# ============================================================================
# Format-Specific Options
# ============================================================================

function get_tar_compression_option --description 'Get tar compression option for format'
    set -l format $argv[1]
    
    switch $format
        case tar.gz tgz
            echo "-z"
        case tar.bz2 tbz2
            echo "-j"
        case tar.xz txz
            echo "-J"
        case tar.zst tzst
            echo "--zstd"
        case tar.lz4 tlz4
            echo "--use-compress-program=lz4"
        case tar.lz tlz
            echo "--lzip"
        case tar.lzo tzo
            echo "--lzop"
        case tar.br tbr
            echo "--use-compress-program=brotli"
        case '*'
            echo ""
    end
end

function get_compression_level_range --description 'Get compression level range for format'
    set -l format $argv[1]
    
    switch $format
        case gzip tar.gz
            echo "1:9"
        case bzip2 tar.bz2
            echo "1:9"
        case xz tar.xz
            echo "0:9"
        case zstd tar.zst
            echo "1:19"
        case lz4 tar.lz4
            echo "1:12"
        case lzip tar.lz
            echo "1:9"
        case lzop tar.lzo
            echo "1:9"
        case brotli tar.br
            echo "1:11"
        case zip
            echo "0:9"
        case 7z
            echo "0:9"
        case '*'
            echo "1:9"
    end
end

# ============================================================================
# Format Validation
# ============================================================================

function validate_format_for_operation --description 'Validate format for specific operation'
    set -l format $argv[1]
    set -l operation $argv[2]  # extract or compress
    
    # Check if format is supported
    set -l supported_formats tar tar.gz tar.bz2 tar.xz tar.zst tar.lz4 tar.lz tar.lzo tar.br zip 7z rar gzip bzip2 xz zstd lz4 lzip lzop brotli iso deb rpm
    
    if not contains $format $supported_formats
        log error "Unsupported format: $format"
        return 1
    end
    
    # Check operation-specific requirements
    switch $operation
        case extract
            # All supported formats can be extracted
            return 0
        case compress
            # Some formats are read-only
            if string match -q "rar" -- $format; or string match -q "iso" -- $format; or string match -q "deb" -- $format; or string match -q "rpm" -- $format
                log error "Format $format is read-only (extraction only)"
                return 1
            end
            return 0
        case '*'
            log error "Unknown operation: $operation"
            return 1
    end
end

function check_format_requirements --description 'Check if required tools are available for format'
    set -l format $argv[1]
    set -l operation $argv[2]
    
    # Get required command
    if test "$operation" = "extract"
        set -l cmd (get_decompression_command $format)
    else
        set -l cmd (get_compression_command $format)
    end
    
    if test "$cmd" = "unknown"
        log error "No command available for $format $operation"
        return 127
    end
    
    # Check if command is available
    if not has_command $cmd
        log error "Required command not found: $cmd"
        return 127
    end
    
    return 0
end

# ============================================================================
# Format Detection Helpers
# ============================================================================

function get_format_from_extension --description 'Get format from file extension'
    set -l filename $argv[1]
    set -l ext (get_extension $filename)
    
    switch $ext
        case 'tar.gz' tgz
            echo tar.gz
        case 'tar.bz2' tbz2 tbz
            echo tar.bz2
        case 'tar.xz' txz
            echo tar.xz
        case 'tar.zst' tzst
            echo tar.zst
        case 'tar.lz4' tlz4
            echo tar.lz4
        case 'tar.lz' tlz
            echo tar.lz
        case 'tar.lzo' tzo
            echo tar.lzo
        case 'tar.br' tbr
            echo tar.br
        case tar
            echo tar
        case zip
            echo zip
        case '7z' '7zip'
            echo 7z
        case rar
            echo rar
        case gz gzip
            echo gzip
        case bz2 bzip2
            echo bzip2
        case xz
            echo xz
        case zst zstd
            echo zstd
        case lz4
            echo lz4
        case lz lzip
            echo lzip
        case lzo
            echo lzo
        case br
            echo brotli
        case iso
            echo iso
        case deb
            echo deb
        case rpm
            echo rpm
        case dmg
            echo dmg
        case pkg
            echo pkg
        case apk
            echo apk
        case cab
            echo cab
        case '*'
            echo unknown
    end
end

function get_format_from_mime --description 'Get format from MIME type'
    set -l mime $argv[1]
    
    switch $mime
        case 'application/x-tar'
            echo tar
        case 'application/gzip' 'application/x-gzip'
            echo gzip
        case 'application/x-bzip2'
            echo bzip2
        case 'application/x-xz'
            echo xz
        case 'application/zstd'
            echo zstd
        case 'application/x-lz4'
            echo lz4
        case 'application/zip'
            echo zip
        case 'application/x-7z-compressed'
            echo 7z
        case 'application/x-rar' 'application/vnd.rar'
            echo rar
        case 'application/x-iso9660-image'
            echo iso
        case '*'
            echo unknown
    end
end

# ============================================================================
# Format-Specific Command Building
# ============================================================================

function build_tar_options --description 'Build tar options for format'
    set -l format $argv[1]
    set -l operation $argv[2]  # extract or compress
    set -l verbose $argv[3]
    set -l strip $argv[4]
    set -l threads $argv[5]
    set -l progress $argv[6]
    
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

function build_zip_options --description 'Build zip options'
    set -l operation $argv[1]  # extract or compress
    set -l level $argv[2]
    set -l encrypt $argv[3]
    set -l password $argv[4]
    set -l verbose $argv[5]
    set -l update $argv[6]
    
    set -l opts
    
    # Operation mode
    if test "$operation" = "extract"
        set -a opts -d
    else
        if test $update -eq 1
            set -a opts -u
        else
            set -a opts -r
        end
    end
    
    # Compression level
    if test "$operation" = "compress"
        set -a opts -$level
    end
    
    # Encryption
    if test $encrypt -eq 1
        set -a opts -e
        if test -n "$password"
            set -a opts -P "$password"
        end
    end
    
    # Verbosity
    if test $verbose -eq 0
        set -a opts -q
    end
    
    echo $opts
end

function build_7z_options --description 'Build 7z options'
    set -l operation $argv[1]  # extract or compress
    set -l level $argv[2]
    set -l threads $argv[3]
    set -l encrypt $argv[4]
    set -l password $argv[5]
    set -l solid $argv[6]
    set -l verbose $argv[7]
    set -l update $argv[8]
    
    set -l opts
    
    # Operation mode
    if test "$operation" = "extract"
        set opts x
    else
        if test $update -eq 1
            set opts u
        else
            set opts a
        end
    end
    
    # Common options
    set -a opts -y  # Yes to all
    set -a opts -mx=$level  # Compression level
    
    # Threading
    if test $threads -gt 1
        set -a opts -mmt=$threads
    end
    
    # Solid compression
    if test $solid -eq 1
        set -a opts -ms=on
    end
    
    # Encryption
    if test $encrypt -eq 1
        set -a opts -mhe=on  # Encrypt headers
        if test -n "$password"
            set -a opts -p"$password"
        end
    end
    
    echo $opts
end