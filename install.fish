#!/usr/bin/env fish
# Fish Pack Installation Script
# This script installs the Fish Pack archive manager

# Enable strict error handling
function on_error --on-event fish_error
    echo "Error occurred during installation" >&2
    exit 1
end

set -l script_dir (dirname (status --current-filename))
set -l plugin_name "fish-pack"
set -l version "4.0.0"

function show_help
    echo "Fish Archive Manager Installation Script"
    echo "========================================"
    echo ""
    echo "Usage: fish install.fish [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --help, -h          Show this help message"
    echo "  --version, -v       Show version information"
    echo "  --force, -f         Force installation even if plugin exists"
    echo "  --uninstall, -u     Uninstall the plugin"
    echo "  --test, -t          Run tests after installation"
    echo "  --check, -c         Run system check after installation"
    echo ""
    echo "Examples:"
    echo "  fish install.fish                    # Install the plugin"
    echo "  fish install.fish --force            # Force reinstall"
    echo "  fish install.fish --uninstall        # Uninstall the plugin"
    echo "  fish install.fish --test --check     # Install and run diagnostics"
end

function show_version
    echo "Fish Pack v$version"
    echo "Professional archive management tool for fish shell with enhanced security"
end

function check_fish_version
    set -l fish_version (fish --version | string replace -r '.*?([0-9]+\.[0-9]+).*' '$1')
    set -l required_version "4.1"
    
    # Use sort -V to compare versions reliably
    if test "$fish_version" = "$required_version"
        echo "✓ Fish version $fish_version is compatible"
        return 0
    end
    
    set -l sorted_versions (printf "%s\n%s" "$fish_version" "$required_version" | sort -V)
    if test "$sorted_versions[1]" = "$required_version"
        echo "✓ Fish version $fish_version is compatible"
        return 0
    else
        echo "✗ Fish version $fish_version is too old. Required: $required_version+"
        return 1
    end
end

function check_dependencies
    echo "Checking dependencies..."
    
    set -l required file tar gzip
    set -l missing
    
    for cmd in $required
        if not command -q $cmd
            set -a missing $cmd
        end
    end
    
    if test (count $missing) -gt 0
        echo "✗ Missing required dependencies: "(string join ', ' $missing)
        echo "  Please install them using your package manager:"
        echo "  - Arch Linux: pacman -S file tar gzip"
        echo "  - Ubuntu/Debian: apt-get install file tar gzip"
        echo "  - macOS: brew install gnu-tar gzip"
        return 1
    else
        echo "✓ All required dependencies are available"
        return 0
    end
end

function install_plugin
    set -l force $argv[1]
    
    echo "Installing Fish Pack v$version..."
    
    # Target directories
    set -l func_dir "$HOME/.config/fish/functions"
    set -l comp_dir "$HOME/.config/fish/completions"
    set -l conf_dir "$HOME/.config/fish/conf.d"
    
    # Check if already installed
    if test -d "$func_dir" -a -f "$func_dir/extract.fish"
        if test "$force" != "1"
            echo "⚠ Plugin already installed. Use --force to reinstall."
            return 1
        else
            echo "⚠ Plugin already installed. Forcing reinstall..."
        end
    end
    
    # Create directories with error checking
    mkdir -p "$func_dir" "$comp_dir" "$conf_dir" 2>/dev/null; or begin
        echo "✗ Failed to create config directories"
        return 1
    end
    
    # Install functions (root level)
    echo "Installing functions..."
    for file in $script_dir/functions/*.fish
        set -l basename (basename $file)
        cp "$file" "$func_dir/$basename" 2>/dev/null; or begin
            echo "  ✗ Failed to install $basename"
            return 1
        end
        echo "  ✓ Installed $basename"
    end
    
    # Install common module (recursive)
    if test -d "$script_dir/functions/common"
        echo "Installing common modules..."
        mkdir -p "$func_dir/common"
        cp -r "$script_dir/functions/common/"* "$func_dir/common/" 2>/dev/null; or begin
            echo "  ✗ Failed to install common modules"
            return 1
        end
        echo "  ✓ Installed common/ modules"
    end
    
    # Install completions
    echo "Installing completions..."
    for file in $script_dir/completions/*.fish
        set -l basename (basename $file)
        cp "$file" "$comp_dir/$basename" 2>/dev/null; or begin
            echo "  ✗ Failed to install $basename"
            return 1
        end
        echo "  ✓ Installed $basename"
    end
    
    # Install configuration
    echo "Installing configuration..."
    for file in $script_dir/conf.d/*.fish
        set -l basename (basename $file)
        cp "$file" "$conf_dir/$basename" 2>/dev/null; or begin
            echo "  ✗ Failed to install $basename"
            return 1
        end
        echo "  ✓ Installed $basename"
    end
    
    echo "✓ Installation completed successfully!"
    return 0
end

function uninstall_plugin
    echo "Uninstalling Fish Pack..."
    
    set -l func_dir "$HOME/.config/fish/functions"
    
    # Remove specific functions
    set -l funcs extract.fish compress.fish check.fish pack.fish unpack.fish
    for f in $funcs
        if test -f "$func_dir/$f"
            rm "$func_dir/$f"
            echo "  ✓ Removed $f"
        end
    end
    
    # Remove common directory if it looks like ours (contains optimized_common.fish)
    if test -f "$func_dir/common/optimized_common.fish"
        rm -rf "$func_dir/common"
        echo "  ✓ Removed common/ modules"
    end
    
    # Remove completions
    for file in $HOME/.config/fish/completions/archive_manager.fish $HOME/.config/fish/completions/fish_extractor.fish
        if test -f "$file"
            rm "$file"
            echo "  ✓ Removed "(basename $file)
        end
    end
    
    # Remove configuration
    for file in $HOME/.config/fish/conf.d/archive_manager.fish $HOME/.config/fish/conf.d/fish_extractor.fish
        if test -f "$file"
            rm "$file"
            echo "  ✓ Removed "(basename $file)
        end
    end
    
    echo "✓ Uninstallation completed successfully!"
    return 0
end

function run_tests
    echo "Running tests..."
    
    if test -f "$script_dir/tests/run_all.fish"
        fish "$script_dir/tests/run_all.fish"
        set -l result $status
        
        if test $result -eq 0
            echo "✓ All tests passed!"
        else
            echo "✗ Some tests failed!"
        end
        
        return $result
    else
        echo "⚠ Test suite not found, skipping tests"
        return 0
    end
end

function run_check
    echo "Running system check..."
    
    # Use the installed function if available, else local
    if functions -q check
        check
        return $status
    else if test -f "$script_dir/functions/check.fish"
        fish -c "source $script_dir/functions/common/optimized_common.fish; source $script_dir/functions/check.fish; check"
        return $status
    else
        echo "⚠ Check command not available"
        return 1
    end
end

function main
    set -l force 0
    set -l uninstall 0
    set -l run_tests_flag 0
    set -l run_check_flag 0
    
    # Parse arguments
    for arg in $argv
        switch $arg
            case --help -h
                show_help
                return 0
            case --version -v
                show_version
                return 0
            case --force -f
                set force 1
            case --uninstall -u
                set uninstall 1
            case --test -t
                set run_tests_flag 1
            case --check -c --doctor -d
                set run_check_flag 1
            case '*'
                echo "Unknown option: $arg"
                echo "Use --help for usage information"
                return 1
        end
    end
    
    # Show version
    show_version
    echo ""
    
    # Check Fish version
    if not check_fish_version
        return 1
    end
    
    # Check dependencies
    if not check_dependencies
        return 1
    end
    
    echo ""
    
    # Handle uninstall
    if test $uninstall -eq 1
        uninstall_plugin
        return $status
    end
    
    # Install plugin
    if not install_plugin $force
        return $status
    end
    
    echo ""
    
    # Run tests if requested
    if test $run_tests_flag -eq 1
        run_tests
        echo ""
    end
    
    # Run check if requested
    if test $run_check_flag -eq 1
        run_check
        echo ""
    end
    
    # Final message
    echo "🎉 Fish Pack v$version installed successfully!"
    echo ""
    echo "Available commands:"
    echo "  extract    - Extract archives intelligently with security checks"
    echo "  compress   - Create archives with smart format selection"
    echo "  check      - Check system capabilities and configuration"
    echo "  pack       - Alternative name for compress"
    echo "  unpack     - Alternative name for extract"
    echo ""
    echo "Run 'extract --help' or 'compress --help' for more information."
end

# Run main function
main $argv
