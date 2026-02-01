# Archive environment diagnostic tool for Fish Archive Manager (fish 4.12+)
# Checks system capabilities, available tools, and configuration

# Load optimized common functions
source (dirname (status --current-filename))/common/optimized_common.fish
# Load secure execution functions
source (dirname (status --current-filename))/common/safe_exec.fish
# Load secure archive operations
source (dirname (status --current-filename))/common/secure_archive_ops.fish
# Load performance utilities
source (dirname (status --current-filename))/common/performance_utils.fish

function check --description 'Diagnose system capabilities and configuration'
    set -l usage "
check - Diagnose system capabilities and configuration

Usage: check [OPTIONS]

Options:
  -v, --verbose           Show detailed system information
  -q, --quiet             Only show errors
      --fix               Suggest fixes for missing tools
      --export            Export diagnostic report to file
      --help              Display this help message

Examples:
  check                   # Basic system check
  check -v                # Detailed diagnostic
  check --fix             # Get installation suggestions
  check --export          # Export report to file
"

    # Parse arguments
    set -l options h/help v/verbose q/quiet
    set -l long_options fix export
    argparse $options $long_options -- $argv

    if test $status -ne 0
        echo $usage
        return 2
    end

    # Handle help
    if set -q _flag_help
        echo $usage
        return 0
    end

    # Set flags
    set -l verbose 0
    set -l quiet 0
    set -l fix 0
    set -l export 0

    if set -q _flag_verbose
        set verbose 1
    end

    if set -q _flag_quiet
        set quiet 1
    end

    if set -q _flag_fix
        set fix 1
    end

    if set -q _flag_export
        set export 1
    end

    # Run diagnostics
    __fish_archive_run_diagnostics $verbose $quiet $fix $export
end

# Alias for backward compatibility
function doctor --description 'Alias for check command'
    check $argv
end
