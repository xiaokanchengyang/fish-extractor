# Fisher plugin manifest for Archivist
# This file is used by Fisher to install the plugin

# Plugin metadata
set -l plugin_name archivist
set -l plugin_version 1.0.0
set -l plugin_description "High-quality archive management for fish shell"

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
