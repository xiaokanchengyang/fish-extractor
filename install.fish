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
    echo "  --doctor, -d        Run doctor after installation"
    echo ""
    echo "Examples:"
    echo "  fish install.fish                    # Install the plugin"
    echo "  fish install.fish --force            # Force reinstall"
    echo "  fish install.fish --uninstall        # Uninstall the plugin"
    echo "  fish install.fish --test --doctor    # Install and run tests"
end

function show_version
    echo "Fish Pack v$version"
    echo "Professional archive management tool for fish shell with enhanced security"
end

function check_fish_version
    set -l fish_version (fish --version | string replace -r '.*?([0-9]+\.[0-9]+).*' '$1')
    set -l required_version "4.1"
    
    if test (math "$fish_version >= $required_version") -eq 1
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
    
    # Check if already installed
    if test -d "$HOME/.config/fish/functions" -a -f "$HOME/.config/fish/functions/extract.fish"
        if test "$force" != "1"
            echo "⚠ Plugin already installed. Use --force to reinstall."
            return 1
        else
            echo "⚠ Plugin already installed. Forcing reinstall..."
        end
    end
    
    # Create directories with error checking
    mkdir -p "$HOME/.config/fish/functions" 2>/dev/null; or begin
        echo "✗ Failed to create functions directory"
        return 1
    end
    mkdir -p "$HOME/.config/fish/completions" 2>/dev/null; or begin
        echo "✗ Failed to create completions directory"
        return 1
    end
    mkdir -p "$HOME/.config/fish/conf.d" 2>/dev/null; or begin
        echo "✗ Failed to create conf.d directory"
        return 1
    end
    
    # Install functions
    echo "Installing functions..."
    for file in $script_dir/functions/*.fish
        set -l basename (basename $file)
        cp "$file" "$HOME/.config/fish/functions/$basename" 2>/dev/null; or begin
            echo "  ✗ Failed to install $basename"
            return 1
        end
        echo "  ✓ Installed $basename"
    end
    
    # Install completions
    echo "Installing completions..."
    for file in $script_dir/completions/*.fish
        set -l basename (basename $file)
        cp "$file" "$HOME/.config/fish/completions/$basename" 2>/dev/null; or begin
            echo "  ✗ Failed to install $basename"
            return 1
        end
        echo "  ✓ Installed $basename"
    end
    
    # Install configuration
    echo "Installing configuration..."
    for file in $script_dir/conf.d/*.fish
        set -l basename (basename $file)
        cp "$file" "$HOME/.config/fish/conf.d/$basename" 2>/dev/null; or begin
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
    
    # Remove functions
    for file in $HOME/.config/fish/functions/{core,extract,compress,doctor}.fish
        if test -f "$file"
            rm "$file"
            echo "  ✓ Removed "(basename $file)
        end
    end
    
    # Remove completions
    for file in $HOME/.config/fish/completions/*.fish
        if test -f "$file"
            rm "$file"
            echo "  ✓ Removed "(basename $file)
        end
    end
    
    # Remove configuration
    for file in $HOME/.config/fish/conf.d/*.fish
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

function run_doctor
    echo "Running doctor..."
    
    if command -q doctor
        doctor
        set -l result $status
        
        if test $result -eq 0
            echo "✓ Doctor check passed!"
        else
            echo "⚠ Doctor found some issues"
        end
        
        return $result
    else
        echo "⚠ Doctor command not available, skipping check"
        return 0
    end
end

function main
    set -l force 0
    set -l uninstall 0
    set -l run_tests_flag 0
    set -l run_doctor_flag 0
    
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
            case --doctor -d
                set run_doctor_flag 1
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
    
    # Run doctor if requested
    if test $run_doctor_flag -eq 1
        run_doctor
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
    echo "Run 'extract --help', 'compress --help', or 'check --help' for more information."
    echo "Run 'check' to verify your system's archive handling capabilities."
end

# Run main function
main $argv