# Fisher plugin manifest for Fish Archive Manager
# This file is used by Fisher to install the plugin

# Plugin metadata
set -l plugin_name fish-archive
set -l plugin_version 3.0.0
set -l plugin_description "Professional archive management tool for fish shell with smart format detection and comprehensive features"

# Files to install
set -l functions_dir (status dirname)/functions
set -l completions_dir (status dirname)/completions
set -l conf_dir (status dirname)/conf.d

# Export installation paths for Fisher
if test -d $functions_dir
    for file in $functions_dir/*.fish
        echo $file
    end
end

if test -d $completions_dir
    for file in $completions_dir/*.fish
        echo $file
    end
end

if test -d $conf_dir
    for file in $conf_dir/*.fish
        echo $file
    end
end