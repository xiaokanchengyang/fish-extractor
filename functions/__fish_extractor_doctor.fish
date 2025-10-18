# Archive environment diagnostic tool for Fish Extractor (fish 4.12+)
# Checks system capabilities, available tools, and configuration

function __fish_extractor_doctor --description 'Diagnose archive tool environment and capabilities'
    set -l usage "\
ext-doctor - Diagnostic tool for Fish Extractor

Usage: ext-doctor [OPTIONS]

Options:
  -v, --verbose           Show detailed information
  -q, --quiet             Only show errors
      --fix               Attempt to suggest fixes for issues
      --export            Export diagnostic report to file
      --help              Display this help message

Description:
  Checks for required and optional archive tools, validates configuration,
  and reports on system capabilities for archive operations.
"

    set -l verbose 0
    set -l quiet 0
    set -l fix 0
    set -l export_report 0

    argparse 'v/verbose' 'q/quiet' 'fix' 'export' 'h/help' -- $argv
    or begin
        echo $usage >&2
        return 2
    end

    set -q _flag_help; and echo $usage; and return 0
    set -q _flag_verbose; and set verbose 1
    set -q _flag_quiet; and set quiet 1
    set -q _flag_fix; and set fix 1
    set -q _flag_export; and set export_report 1

    # Start diagnostic report
    set -l report_lines

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
        pxz \
        split

    # Display header
    test $quiet -eq 0; and begin
        __fish_extractor_colorize cyan "\n╔════════════════════════════════════════════════╗\n"
        __fish_extractor_colorize cyan "║        Fish Extractor Environment Doctor       ║\n"
        __fish_extractor_colorize cyan "╚════════════════════════════════════════════════╝\n"
        echo ""
    end

    set -a report_lines "Fish Extractor Diagnostic Report"
    set -a report_lines "Generated: "(date)
    set -a report_lines ""

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
                    __fish_extractor_colorize green (printf "  ✓ %-15s %s\n" $cmd $version)
                    set -a report_lines "✓ $cmd: $version"
                else
                    __fish_extractor_colorize green (printf "  ✓ %-15s OK\n" $cmd)
                    set -a report_lines "✓ $cmd: OK"
                end
            end
        else
            set -a missing_required $cmd
            if test $quiet -eq 0
                __fish_extractor_colorize red (printf "  ✗ %-15s MISSING\n" $cmd)
            end
            set -a report_lines "✗ $cmd: MISSING"
        end
    end

    set -a report_lines ""

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
                    __fish_extractor_colorize green (printf "  ✓ %-15s %s\n" $cmd $version)
                    set -a report_lines "✓ $cmd: $version"
                else
                    __fish_extractor_colorize green (printf "  ✓ %-15s OK\n" $cmd)
                    set -a report_lines "✓ $cmd: OK"
                end
            end
        else
            set -a missing_important $cmd
            if test $quiet -eq 0
                __fish_extractor_colorize yellow (printf "  ⚠ %-15s missing (recommended)\n" $cmd)
            end
            set -a report_lines "⚠ $cmd: missing (recommended)"
        end
    end

    set -a report_lines ""

    # Check optional tools
    if test $verbose -eq 1; and test $quiet -eq 0
        echo "\nOptional Tools (Performance & Additional Formats):"
        set -l optional_found 0
        for cmd in $optional
            if command -q $cmd
                set optional_found (math $optional_found + 1)
                set -l version (eval $cmd --version 2>/dev/null | head -n1 | string replace -r '.*?([0-9]+\\.[0-9]+[^ ]*).*' '$1')
                if test -n "$version"
                    __fish_extractor_colorize cyan (printf "  + %-15s %s\n" $cmd $version)
                    set -a report_lines "+ $cmd: $version"
                else
                    __fish_extractor_colorize cyan (printf "  + %-15s available\n" $cmd)
                    set -a report_lines "+ $cmd: available"
                end
            else
                printf "  - %-15s not available\n" $cmd
                set -a report_lines "- $cmd: not available"
            end
        end
    end

    set -a report_lines ""

    # Configuration status
    if test $quiet -eq 0
        echo "\nConfiguration:"
        printf "  FISH_EXTRACTOR_COLOR           = %s\n" (set -q FISH_EXTRACTOR_COLOR; and echo $FISH_EXTRACTOR_COLOR; or echo "auto")
        printf "  FISH_EXTRACTOR_PROGRESS        = %s\n" (set -q FISH_EXTRACTOR_PROGRESS; and echo $FISH_EXTRACTOR_PROGRESS; or echo "auto")
        printf "  FISH_EXTRACTOR_DEFAULT_THREADS = %s\n" (set -q FISH_EXTRACTOR_DEFAULT_THREADS; and echo $FISH_EXTRACTOR_DEFAULT_THREADS; or echo "(auto)")
        printf "  FISH_EXTRACTOR_LOG_LEVEL       = %s\n" (set -q FISH_EXTRACTOR_LOG_LEVEL; and echo $FISH_EXTRACTOR_LOG_LEVEL; or echo "info")
        printf "  FISH_EXTRACTOR_DEFAULT_FORMAT  = %s\n" (set -q FISH_EXTRACTOR_DEFAULT_FORMAT; and echo $FISH_EXTRACTOR_DEFAULT_FORMAT; or echo "auto")
    end

    set -a report_lines "Configuration:"
    set -a report_lines "  FISH_EXTRACTOR_COLOR           = "(set -q FISH_EXTRACTOR_COLOR; and echo $FISH_EXTRACTOR_COLOR; or echo "auto")
    set -a report_lines "  FISH_EXTRACTOR_PROGRESS        = "(set -q FISH_EXTRACTOR_PROGRESS; and echo $FISH_EXTRACTOR_PROGRESS; or echo "auto")
    set -a report_lines "  FISH_EXTRACTOR_DEFAULT_THREADS = "(set -q FISH_EXTRACTOR_DEFAULT_THREADS; and echo $FISH_EXTRACTOR_DEFAULT_THREADS; or echo "(auto)")
    set -a report_lines "  FISH_EXTRACTOR_LOG_LEVEL       = "(set -q FISH_EXTRACTOR_LOG_LEVEL; and echo $FISH_EXTRACTOR_LOG_LEVEL; or echo "info")
    set -a report_lines "  FISH_EXTRACTOR_DEFAULT_FORMAT  = "(set -q FISH_EXTRACTOR_DEFAULT_FORMAT; and echo $FISH_EXTRACTOR_DEFAULT_FORMAT; or echo "auto")
    set -a report_lines ""

    # System information
    if test $verbose -eq 1; and test $quiet -eq 0
        echo "\nSystem Information:"
        printf "  OS:               %s\n" (uname -s)
        printf "  Architecture:     %s\n" (uname -m)
        printf "  Kernel:           %s\n" (uname -r)
        set -l cores (nproc 2>/dev/null; or sysctl -n hw.ncpu 2>/dev/null; or echo "unknown")
        printf "  CPU Cores:        %s\n" $cores
        printf "  Fish Version:     %s\n" $FISH_VERSION
        printf "  Shell:            %s\n" $SHELL
        
        set -a report_lines "System Information:"
        set -a report_lines "  OS:               "(uname -s)
        set -a report_lines "  Architecture:     "(uname -m)
        set -a report_lines "  Kernel:           "(uname -r)
        set -a report_lines "  CPU Cores:        $cores"
        set -a report_lines "  Fish Version:     $FISH_VERSION"
        set -a report_lines "  Shell:            $SHELL"
        set -a report_lines ""
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
        
        set -a report_lines "Supported Archive Formats:"
        for fmt in $formats
            printf "  • %s\n" $fmt
            set -a report_lines "  • $fmt"
        end
        set -a report_lines ""
    end

    # Performance assessment
    if test $verbose -eq 1; and test $quiet -eq 0
        echo "\nPerformance Features:"
        set -l perf_features
        
        command -q pigz; and set -a perf_features "✓ Parallel gzip (pigz)"; or set -a perf_features "✗ Parallel gzip (pigz not found)"
        command -q pbzip2; and set -a perf_features "✓ Parallel bzip2 (pbzip2)"; or set -a perf_features "✗ Parallel bzip2 (pbzip2 not found)"
        command -q pv; and set -a perf_features "✓ Progress viewer (pv)"; or set -a perf_features "✗ Progress viewer (pv not found)"
        
        for feat in $perf_features
            echo "  $feat"
            set -a report_lines "  $feat"
        end
        set -a report_lines ""
    end

    # Suggestions and fixes
    if test $fix -eq 1; or test (count $missing_required) -gt 0; or test (count $missing_important) -gt 0
        echo ""
        set -a report_lines "Recommendations:"
        
        if test (count $missing_required) -gt 0
            __fish_extractor_colorize red "⚠ Missing required tools!\n"
            echo "  Install with your package manager:"
            
            # Detect package manager and provide appropriate command
            if command -q pacman
                echo "    pacman -S "(string join ' ' $missing_required)
                set -a report_lines "  pacman -S "(string join ' ' $missing_required)
            else if command -q apt-get
                echo "    apt-get install "(string join ' ' $missing_required)
                set -a report_lines "  apt-get install "(string join ' ' $missing_required)
            else if command -q brew
                echo "    brew install "(string join ' ' $missing_required)
                set -a report_lines "  brew install "(string join ' ' $missing_required)
            else if command -q dnf
                echo "    dnf install "(string join ' ' $missing_required)
                set -a report_lines "  dnf install "(string join ' ' $missing_required)
            else
                echo "    Use your package manager to install: "(string join ' ' $missing_required)
                set -a report_lines "  Use your package manager to install: "(string join ' ' $missing_required)
            end
        end
        
        if test (count $missing_important) -gt 0
            echo ""
            __fish_extractor_colorize yellow "💡 Recommended tools to install:\n"
            echo "  For better format support:"
            
            if command -q pacman
                echo "    pacman -S "(string join ' ' $missing_important)
                set -a report_lines "  pacman -S "(string join ' ' $missing_important)
            else if command -q apt-get
                echo "    apt-get install "(string join ' ' $missing_important)
                set -a report_lines "  apt-get install "(string join ' ' $missing_important)
            else if command -q brew
                echo "    brew install "(string join ' ' $missing_important)
                set -a report_lines "  brew install "(string join ' ' $missing_important)
            else if command -q dnf
                echo "    dnf install "(string join ' ' $missing_important)
                set -a report_lines "  dnf install "(string join ' ' $missing_important)
            else
                echo "    Use your package manager to install: "(string join ' ' $missing_important)
                set -a report_lines "  Use your package manager to install: "(string join ' ' $missing_important)
            end
        end
        
        if test $fix -eq 1
            echo ""
            echo "Performance optimization tips:"
            set -a report_lines ""
            set -a report_lines "Performance optimization tips:"
            
            if not command -q pv
                echo "  • Install 'pv' for progress indicators"
                set -a report_lines "  • Install 'pv' for progress indicators"
            end
            if not command -q pigz
                echo "  • Install 'pigz' for parallel gzip compression"
                set -a report_lines "  • Install 'pigz' for parallel gzip compression"
            end
            if not command -q pbzip2
                echo "  • Install 'pbzip2' for parallel bzip2 compression"
                set -a report_lines "  • Install 'pbzip2' for parallel bzip2 compression"
            end
            
            echo ""
            echo "Configuration suggestions:"
            set -a report_lines ""
            set -a report_lines "Configuration suggestions:"
            
            if not set -q FISH_EXTRACTOR_DEFAULT_THREADS
                set -l cores (nproc 2>/dev/null; or sysctl -n hw.ncpu 2>/dev/null; or echo 4)
                echo "  • Set thread count: set -Ux FISH_EXTRACTOR_DEFAULT_THREADS $cores"
                set -a report_lines "  • Set thread count: set -Ux FISH_EXTRACTOR_DEFAULT_THREADS $cores"
            end
            
            if not set -q FISH_EXTRACTOR_COLOR
                echo "  • Enable colors: set -Ux FISH_EXTRACTOR_COLOR auto"
                set -a report_lines "  • Enable colors: set -Ux FISH_EXTRACTOR_COLOR auto"
            end
        end
        set -a report_lines ""
    end

    # Final status
    if test $quiet -eq 0
        echo ""
        set -l total_required (count $required)
        set -l total_important (count $important)
        
        if test (count $missing_required) -eq 0
            __fish_extractor_colorize green "✓ Core functionality: Ready ($required_ok/$total_required)\n"
            set -a report_lines "✓ Core functionality: Ready ($required_ok/$total_required)"
        else
            __fish_extractor_colorize red "✗ Core functionality: Incomplete ($required_ok/$total_required)\n"
            set -a report_lines "✗ Core functionality: Incomplete ($required_ok/$total_required)"
        end
        
        if test (count $missing_important) -eq 0
            __fish_extractor_colorize green "✓ Extended functionality: Ready ($important_ok/$total_important)\n"
            set -a report_lines "✓ Extended functionality: Ready ($important_ok/$total_important)"
        else
            __fish_extractor_colorize yellow "⚠ Extended functionality: Limited ($important_ok/$total_important)\n"
            set -a report_lines "⚠ Extended functionality: Limited ($important_ok/$total_important)"
        end
        
        echo ""
    end

    # Export report if requested
    if test $export_report -eq 1
        set -l report_file "fish-extractor-diagnostic-"(date +%Y%m%d_%H%M%S)".txt"
        printf "%s\n" $report_lines > $report_file
        __fish_extractor_log info "Diagnostic report exported to: $report_file"
    end

    # Return appropriate exit code
    if test (count $missing_required) -gt 0
        return 1
    else
        return 0
    end
end
