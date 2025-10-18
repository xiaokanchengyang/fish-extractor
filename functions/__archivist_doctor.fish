# Archive environment diagnostic tool for Archivist (fish 4.12+)
# Checks system capabilities, available tools, and configuration

function __archivist_doctor --description 'Diagnose archive tool environment and capabilities'
    set -l usage "\
archdoctor - Diagnostic tool for Archivist

Usage: archdoctor [OPTIONS]

Options:
  -v, --verbose           Show detailed information
  -q, --quiet             Only show errors
      --fix               Attempt to suggest fixes for issues
      --help              Display this help message

Description:
  Checks for required and optional archive tools, validates configuration,
  and reports on system capabilities for archive operations.
"

    set -l verbose 0
    set -l quiet 0
    set -l fix 0

    argparse 'v/verbose' 'q/quiet' 'fix' 'h/help' -- $argv
    or begin
        echo $usage >&2
        return 2
    end

    set -q _flag_help; and echo $usage; and return 0
    set -q _flag_verbose; and set verbose 1
    set -q _flag_quiet; and set quiet 1
    set -q _flag_fix; and set fix 1

    # Required tools (core functionality)
    set -l required \
        file \
        tar \
        gzip \
        bzip2 \
        xz \
        zstd \
        unzip \
        zip

    # Important tools (extended functionality)
    set -l important \
        7z \
        lz4 \
        bsdtar

    # Optional tools (additional features)
    set -l optional \
        unrar \
        pv \
        lzip \
        lzop \
        brotli \
        pigz \
        pbzip2 \
        pxz

    # Display header
    test $quiet -eq 0; and begin
        __archivist__colorize cyan "\n╔════════════════════════════════════════════════╗\n"
        __archivist__colorize cyan "║        Archivist Environment Doctor            ║\n"
        __archivist__colorize cyan "╚════════════════════════════════════════════════╝\n"
        echo ""
    end

    # Check required tools
    test $quiet -eq 0; and echo "Required Tools (Core Functionality):"
    set -l missing_required
    set -l required_ok 0
    
    for cmd in $required
        if command -q $cmd
            set required_ok (math $required_ok + 1)
            if test $quiet -eq 0
                set -l version (eval $cmd --version 2>/dev/null | head -n1 | string replace -r '.*?([0-9]+\\.[0-9]+[^ ]*).*' '$1')
                if test $verbose -eq 1; and test -n "$version"
                    __archivist__colorize green (printf "  ✓ %-15s %s\n" $cmd $version)
                else
                    __archivist__colorize green (printf "  ✓ %-15s OK\n" $cmd)
                end
            end
        else
            set -a missing_required $cmd
            if test $quiet -eq 0
                __archivist__colorize red (printf "  ✗ %-15s MISSING\n" $cmd)
            end
        end
    end

    # Check important tools
    test $quiet -eq 0; and echo "\nImportant Tools (Extended Functionality):"
    set -l missing_important
    set -l important_ok 0
    
    for cmd in $important
        if command -q $cmd
            set important_ok (math $important_ok + 1)
            if test $quiet -eq 0
                set -l version (eval $cmd --version 2>/dev/null | head -n1 | string replace -r '.*?([0-9]+\\.[0-9]+[^ ]*).*' '$1')
                if test $verbose -eq 1; and test -n "$version"
                    __archivist__colorize green (printf "  ✓ %-15s %s\n" $cmd $version)
                else
                    __archivist__colorize green (printf "  ✓ %-15s OK\n" $cmd)
                end
            end
        else
            set -a missing_important $cmd
            if test $quiet -eq 0
                __archivist__colorize yellow (printf "  ⚠ %-15s missing (recommended)\n" $cmd)
            end
        end
    end

    # Check optional tools
    if test $verbose -eq 1; and test $quiet -eq 0
        echo "\nOptional Tools (Performance & Additional Formats):"
        for cmd in $optional
            if command -q $cmd
                set -l version (eval $cmd --version 2>/dev/null | head -n1 | string replace -r '.*?([0-9]+\\.[0-9]+[^ ]*).*' '$1')
                if test -n "$version"
                    __archivist__colorize cyan (printf "  + %-15s %s\n" $cmd $version)
                else
                    __archivist__colorize cyan (printf "  + %-15s available\n" $cmd)
                end
            else
                printf "  - %-15s not available\n" $cmd
            end
        end
    end

    # Configuration status
    if test $quiet -eq 0
        echo "\nConfiguration:"
        printf "  ARCHIVIST_COLOR                = %s\n" (set -q ARCHIVIST_COLOR; and echo $ARCHIVIST_COLOR; or echo "auto")
        printf "  ARCHIVIST_PROGRESS             = %s\n" (set -q ARCHIVIST_PROGRESS; and echo $ARCHIVIST_PROGRESS; or echo "auto")
        printf "  ARCHIVIST_DEFAULT_THREADS      = %s\n" (set -q ARCHIVIST_DEFAULT_THREADS; and echo $ARCHIVIST_DEFAULT_THREADS; or echo "(auto)")
        printf "  ARCHIVIST_LOG_LEVEL            = %s\n" (set -q ARCHIVIST_LOG_LEVEL; and echo $ARCHIVIST_LOG_LEVEL; or echo "info")
        printf "  ARCHIVIST_DEFAULT_FORMAT       = %s\n" (set -q ARCHIVIST_DEFAULT_FORMAT; and echo $ARCHIVIST_DEFAULT_FORMAT; or echo "auto")
        
        if test $verbose -eq 1
            printf "  ARCHIVIST_SMART_LEVEL          = %s\n" (set -q ARCHIVIST_SMART_LEVEL; and echo $ARCHIVIST_SMART_LEVEL; or echo "2")
            printf "  ARCHIVIST_PARANOID             = %s\n" (set -q ARCHIVIST_PARANOID; and echo $ARCHIVIST_PARANOID; or echo "0")
        end
    end

    # System information
    if test $verbose -eq 1; and test $quiet -eq 0
        echo "\nSystem Information:"
        printf "  OS:               %s\n" (uname -s)
        printf "  Architecture:     %s\n" (uname -m)
        printf "  CPU Cores:        %s\n" (nproc 2>/dev/null; or sysctl -n hw.ncpu 2>/dev/null; or echo "unknown")
        printf "  Fish Version:     %s\n" $FISH_VERSION
        printf "  Shell:            %s\n" $SHELL
    end

    # Format support summary
    if test $verbose -eq 1; and test $quiet -eq 0
        echo "\nSupported Archive Formats:"
        set -l formats
        command -q tar; and set -a formats "tar"
        command -q gzip; and set -a formats "tar.gz/tgz"
        command -q bzip2; and set -a formats "tar.bz2/tbz2"
        command -q xz; and set -a formats "tar.xz/txz"
        command -q zstd; and set -a formats "tar.zst/tzst"
        command -q lz4; and set -a formats "tar.lz4/tlz4"
        command -q lzip; and set -a formats "tar.lz/tlz"
        command -q lzop; and set -a formats "tar.lzo/tzo"
        command -q brotli; and set -a formats "tar.br/tbr"
        command -q zip; and set -a formats "zip"
        command -q 7z; and set -a formats "7z"
        command -q unrar; and set -a formats "rar"
        command -q bsdtar; and set -a formats "iso/deb/rpm/pkg"
        
        for fmt in $formats
            printf "  • %s\n" $fmt
        end
    end

    # Suggestions and fixes
    if test $fix -eq 1; or test (count $missing_required) -gt 0; or test (count $missing_important) -gt 0
        echo ""
        if test (count $missing_required) -gt 0
            __archivist__colorize red "⚠ Missing required tools!\n"
            echo "  Install with:"
            echo "    pacman -S "(string join ' ' $missing_required)
        end
        
        if test (count $missing_important) -gt 0
            echo ""
            __archivist__colorize yellow "💡 Recommended tools to install:\n"
            echo "  For better format support:"
            echo "    pacman -S "(string join ' ' $missing_important)
        end
        
        if test $fix -eq 1
            echo ""
            echo "Performance optimization tips:"
            if not command -q pv
                echo "  • Install 'pv' for progress indicators: pacman -S pv"
            end
            if not command -q pigz
                echo "  • Install 'pigz' for parallel gzip: pacman -S pigz"
            end
            if not command -q pbzip2
                echo "  • Install 'pbzip2' for parallel bzip2: pacman -S pbzip2"
            end
            
            echo ""
            echo "Configuration suggestions:"
            if not set -q ARCHIVIST_DEFAULT_THREADS
                set -l cores (nproc 2>/dev/null; or echo 4)
                echo "  • Set thread count: set -Ux ARCHIVIST_DEFAULT_THREADS $cores"
            end
        end
    end

    # Final status
    if test $quiet -eq 0
        echo ""
        set -l total_required (count $required)
        set -l total_important (count $important)
        
        if test (count $missing_required) -eq 0
            __archivist__colorize green "✓ Core functionality: Ready ($required_ok/$total_required)\n"
        else
            __archivist__colorize red "✗ Core functionality: Incomplete ($required_ok/$total_required)\n"
        end
        
        if test (count $missing_important) -eq 0
            __archivist__colorize green "✓ Extended functionality: Ready ($important_ok/$total_important)\n"
        else
            __archivist__colorize yellow "⚠ Extended functionality: Limited ($important_ok/$total_important)\n"
        end
        
        echo ""
    end

    # Return appropriate exit code
    if test (count $missing_required) -gt 0
        return 1
    else
        return 0
    end
end
