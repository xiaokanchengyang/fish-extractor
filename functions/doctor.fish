# Archive environment diagnostic tool for Fish Archive Manager (fish 4.12+)
# Checks system capabilities, available tools, and configuration

# Load validation helpers
source (dirname (status --current-filename))/validation.fish
# Load format handlers
source (dirname (status --current-filename))/format_handlers.fish
# Load error handling
source (dirname (status --current-filename))/error_handling.fish

function doctor --description 'Diagnose archive tool environment and capabilities'
    set -l usage "\
doctor - Diagnostic tool for Fish Archive Manager

Usage: doctor [OPTIONS]

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
        colorize cyan "\n╔════════════════════════════════════════════════╗\n"
        colorize cyan "║        Fish Archive Manager Environment Doctor ║\n"
        colorize cyan "╚════════════════════════════════════════════════╝\n"
        echo ""
    end

    set -a report_lines "Fish Archive Manager Diagnostic Report"
    set -a report_lines "Generated: "(date)
    set -a report_lines ""

    # Check required tools
    test $quiet -eq 0; and echo "Required Tools (Core Functionality):"
    set -l missing_required
    set -l required_ok 0
    
    for cmd in $required
        if has_command $cmd
            set required_ok (math $required_ok + 1)
            if should_show_info $quiet
                set -l version (eval $cmd --version 2>/dev/null | head -n1 | string replace -r '.*?([0-9]+\\.[0-9]+[^ ]*).*' '$1')
                if should_show_verbose $verbose $quiet; and test -n "$version"
                    colorize green (printf "  ✓ %-15s %s\n" $cmd $version)
                    set -a report_lines "✓ $cmd: $version"
                else
                    colorize green (printf "  ✓ %-15s OK\n" $cmd)
                    set -a report_lines "✓ $cmd: OK"
                end
            end
        else
            set -a missing_required $cmd
            if should_show_info $quiet
                colorize red (printf "  ✗ %-15s MISSING\n" $cmd)
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
        if has_command $cmd
            set important_ok (math $important_ok + 1)
            if test $quiet -eq 0
                set -l version (eval $cmd --version 2>/dev/null | head -n1 | string replace -r '.*?([0-9]+\\.[0-9]+[^ ]*).*' '$1')
                if test $verbose -eq 1; and test -n "$version"
                    colorize green (printf "  ✓ %-15s %s\n" $cmd $version)
                    set -a report_lines "✓ $cmd: $version"
                else
                    colorize green (printf "  ✓ %-15s OK\n" $cmd)
                    set -a report_lines "✓ $cmd: OK"
                end
            end
        else
            set -a missing_important $cmd
            if test $quiet -eq 0
                colorize yellow (printf "  ⚠ %-15s missing (recommended)\n" $cmd)
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
            if has_command $cmd
                set optional_found (math $optional_found + 1)
                set -l version (eval $cmd --version 2>/dev/null | head -n1 | string replace -r '.*?([0-9]+\\.[0-9]+[^ ]*).*' '$1')
                if test -n "$version"
                    colorize cyan (printf "  + %-15s %s\n" $cmd $version)
                    set -a report_lines "+ $cmd: $version"
                else
                    colorize cyan (printf "  + %-15s available\n" $cmd)
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
        printf "  FISH_ARCHIVE_COLOR           = %s\n" (set -q FISH_ARCHIVE_COLOR; and echo $FISH_ARCHIVE_COLOR; or echo "auto")
        printf "  FISH_ARCHIVE_PROGRESS        = %s\n" (set -q FISH_ARCHIVE_PROGRESS; and echo $FISH_ARCHIVE_PROGRESS; or echo "auto")
        printf "  FISH_ARCHIVE_DEFAULT_THREADS = %s\n" (set -q FISH_ARCHIVE_DEFAULT_THREADS; and echo $FISH_ARCHIVE_DEFAULT_THREADS; or echo "(auto)")
        printf "  FISH_ARCHIVE_LOG_LEVEL       = %s\n" (set -q FISH_ARCHIVE_LOG_LEVEL; and echo $FISH_ARCHIVE_LOG_LEVEL; or echo "info")
        printf "  FISH_ARCHIVE_DEFAULT_FORMAT  = %s\n" (set -q FISH_ARCHIVE_DEFAULT_FORMAT; and echo $FISH_ARCHIVE_DEFAULT_FORMAT; or echo "auto")
    end

    set -a report_lines "Configuration:"
    set -a report_lines "  FISH_ARCHIVE_COLOR           = "(set -q FISH_ARCHIVE_COLOR; and echo $FISH_ARCHIVE_COLOR; or echo "auto")
    set -a report_lines "  FISH_ARCHIVE_PROGRESS        = "(set -q FISH_ARCHIVE_PROGRESS; and echo $FISH_ARCHIVE_PROGRESS; or echo "auto")
    set -a report_lines "  FISH_ARCHIVE_DEFAULT_THREADS = "(set -q FISH_ARCHIVE_DEFAULT_THREADS; and echo $FISH_ARCHIVE_DEFAULT_THREADS; or echo "(auto)")
    set -a report_lines "  FISH_ARCHIVE_LOG_LEVEL       = "(set -q FISH_ARCHIVE_LOG_LEVEL; and echo $FISH_ARCHIVE_LOG_LEVEL; or echo "info")
    set -a report_lines "  FISH_ARCHIVE_DEFAULT_FORMAT  = "(set -q FISH_ARCHIVE_DEFAULT_FORMAT; and echo $FISH_ARCHIVE_DEFAULT_FORMAT; or echo "auto")
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
        has_command tar; and set -a formats "tar"
        has_command gzip; and set -a formats "tar.gz/tgz"
        has_command bzip2; and set -a formats "tar.bz2/tbz2"
        has_command xz; and set -a formats "tar.xz/txz"
        has_command zstd; and set -a formats "tar.zst/tzst"
        has_command lz4; and set -a formats "tar.lz4/tlz4"
        has_command lzip; and set -a formats "tar.lz/tlz"
        has_command lzop; and set -a formats "tar.lzo/tzo"
        has_command brotli; and set -a formats "tar.br/tbr"
        has_command zip; and set -a formats "zip"
        has_command 7z; and set -a formats "7z"
        has_command unrar; and set -a formats "rar"
        has_command bsdtar; and set -a formats "iso/deb/rpm/pkg"
        
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
        
        has_command pigz; and set -a perf_features "✓ Parallel gzip (pigz)"; or set -a perf_features "✗ Parallel gzip (pigz not found)"
        has_command pbzip2; and set -a perf_features "✓ Parallel bzip2 (pbzip2)"; or set -a perf_features "✗ Parallel bzip2 (pbzip2 not found)"
        has_command pv; and set -a perf_features "✓ Progress viewer (pv)"; or set -a perf_features "✗ Progress viewer (pv not found)"
        
        # Check for parallel xz/zstd support
        if has_command pxz
            set -a perf_features "✓ Parallel xz (pxz)"
        else
            set -a perf_features "⚠ Parallel xz (pxz not found, using single-threaded xz)"
        end
        
        # Check zstd threading support
        if has_command zstd
            set -l zstd_version (zstd --version 2>/dev/null | head -n1)
            if string match -q "*threading*" -- $zstd_version; or string match -q "*multi-thread*" -- $zstd_version
                set -a perf_features "✓ Multi-threaded zstd"
            else
                set -a perf_features "⚠ Single-threaded zstd (consider upgrading)"
            end
        end
        
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
            colorize red "⚠ Missing required tools!\n"
            echo "  Install with your package manager:"
            
            # Detect package manager and provide appropriate command
            if has_command pacman
                echo "    pacman -S "(string join ' ' $missing_required)
                set -a report_lines "  pacman -S "(string join ' ' $missing_required)
            else if has_command apt-get
                echo "    apt-get install "(string join ' ' $missing_required)
                set -a report_lines "  apt-get install "(string join ' ' $missing_required)
            else if has_command brew
                echo "    brew install "(string join ' ' $missing_required)
                set -a report_lines "  brew install "(string join ' ' $missing_required)
            else if has_command dnf
                echo "    dnf install "(string join ' ' $missing_required)
                set -a report_lines "  dnf install "(string join ' ' $missing_required)
            else
                echo "    Use your package manager to install: "(string join ' ' $missing_required)
                set -a report_lines "  Use your package manager to install: "(string join ' ' $missing_required)
            end
        end
        
        if test (count $missing_important) -gt 0
            echo ""
            colorize yellow "💡 Recommended tools to install:\n"
            echo "  For better format support:"
            
            if has_command pacman
                echo "    pacman -S "(string join ' ' $missing_important)
                set -a report_lines "  pacman -S "(string join ' ' $missing_important)
            else if has_command apt-get
                echo "    apt-get install "(string join ' ' $missing_important)
                set -a report_lines "  apt-get install "(string join ' ' $missing_important)
            else if has_command brew
                echo "    brew install "(string join ' ' $missing_important)
                set -a report_lines "  brew install "(string join ' ' $missing_important)
            else if has_command dnf
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
            
            if not has_command pv
                echo "  • Install 'pv' for progress indicators"
                set -a report_lines "  • Install 'pv' for progress indicators"
            end
            if not has_command pigz
                echo "  • Install 'pigz' for parallel gzip compression"
                set -a report_lines "  • Install 'pigz' for parallel gzip compression"
            end
            if not has_command pbzip2
                echo "  • Install 'pbzip2' for parallel bzip2 compression"
                set -a report_lines "  • Install 'pbzip2' for parallel bzip2 compression"
            end
            if not has_command pxz
                echo "  • Install 'pxz' for parallel xz compression"
                set -a report_lines "  • Install 'pxz' for parallel xz compression"
            end
            
            # Platform-specific recommendations
            set -l platform (detect_platform)
            switch $platform
                case linux
                    echo "  • Linux: Consider using 'zstd' with threading support"
                    set -a report_lines "  • Linux: Consider using 'zstd' with threading support"
                case macos
                    echo "  • macOS: Use 'brew install zstd' for latest version"
                    set -a report_lines "  • macOS: Use 'brew install zstd' for latest version"
                case windows
                    echo "  • Windows: Consider WSL for better tool support"
                    set -a report_lines "  • Windows: Consider WSL for better tool support"
            end
            
            echo ""
            echo "Configuration suggestions:"
            set -a report_lines ""
            set -a report_lines "Configuration suggestions:"
            
            if not set -q FISH_ARCHIVE_DEFAULT_THREADS
                set -l cores (nproc 2>/dev/null; or sysctl -n hw.ncpu 2>/dev/null; or echo 4)
                echo "  • Set thread count: set -Ux FISH_ARCHIVE_DEFAULT_THREADS $cores"
                set -a report_lines "  • Set thread count: set -Ux FISH_ARCHIVE_DEFAULT_THREADS $cores"
            end
            
            if not set -q FISH_ARCHIVE_COLOR
                echo "  • Enable colors: set -Ux FISH_ARCHIVE_COLOR auto"
                set -a report_lines "  • Enable colors: set -Ux FISH_ARCHIVE_COLOR auto"
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
            colorize green "✓ Core functionality: Ready ($required_ok/$total_required)\n"
            set -a report_lines "✓ Core functionality: Ready ($required_ok/$total_required)"
        else
            colorize red "✗ Core functionality: Incomplete ($required_ok/$total_required)\n"
            set -a report_lines "✗ Core functionality: Incomplete ($required_ok/$total_required)"
        end
        
        if test (count $missing_important) -eq 0
            colorize green "✓ Extended functionality: Ready ($important_ok/$total_important)\n"
            set -a report_lines "✓ Extended functionality: Ready ($important_ok/$total_important)"
        else
            colorize yellow "⚠ Extended functionality: Limited ($important_ok/$total_important)\n"
            set -a report_lines "⚠ Extended functionality: Limited ($important_ok/$total_important)"
        end
        
        echo ""
    end

    # Export report if requested
    if test $export_report -eq 1
        set -l report_file "fish-archive-diagnostic-"(date +%Y%m%d_%H%M%S)".txt"
        printf "%s\n" $report_lines > $report_file
        log info "Diagnostic report exported to: $report_file"
    end

    # Return appropriate exit code
    if test (count $missing_required) -gt 0
        return 1
    else
        return 0
    end
end