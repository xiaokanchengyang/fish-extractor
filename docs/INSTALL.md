# Installation Guide

This guide covers different methods to install Fish Archive Manager.

## Prerequisites

### Required
- **fish shell** version 4.12 or later
  ```bash
  fish --version
  # Should show: fish, version 4.12 or higher
  ```

## Platform-Specific Installation

### Linux (Ubuntu/Debian)
```bash
# Required tools
sudo apt-get update
sudo apt-get install -y file tar gzip bzip2 xz-utils zstd lz4 lzip lzop brotli zip unzip p7zip-full p7zip-rar unrar-free pigz pbzip2 pxz pv bsdtar

# Install fish (if not already installed)
sudo apt-get install -y fish
```

### Linux (Arch Linux)
```bash
# Required tools
sudo pacman -S file tar gzip bzip2 xz zstd lz4 lzip lzop brotli zip unzip p7zip lz4 bsdtar pv pigz pbzip2 pxz

# Install fish (if not already installed)
sudo pacman -S fish
```

### Linux (Fedora/RHEL)
```bash
# Required tools
sudo dnf install -y file tar gzip bzip2 xz zstd lz4 lzip lzop brotli zip unzip p7zip lz4 bsdtar pv pigz pbzip2 pxz

# Install fish (if not already installed)
sudo dnf install -y fish
```

### macOS
```bash
# Install Homebrew (if not already installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Required tools
brew install file gnu-tar gzip bzip2 xz zstd lz4 lzip lzop brotli zip unzip p7zip unrar pigz pbzip2 pv libarchive

# Install fish (if not already installed)
brew install fish
```

### Windows

#### Option A: WSL (Recommended)
```bash
# Install WSL2
wsl --install

# In WSL, install tools
sudo apt-get update
sudo apt-get install -y file tar gzip bzip2 xz-utils zstd lz4 lzip lzop brotli zip unzip p7zip-full p7zip-rar unrar-free pigz pbzip2 pxz pv bsdtar fish

# Install Fish Archive Manager in WSL
fisher install xiaokanchengyang/fish-extractor
```

#### Option B: Native Windows
```powershell
# Install Chocolatey (if not already installed)
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install required tools
choco install -y 7zip
choco install -y gnuwin32-tar
choco install -y gnuwin32-gzip
choco install -y gnuwin32-bzip2
choco install -y gnuwin32-xz
choco install -y gnuwin32-zstd
choco install -y gnuwin32-lz4
choco install -y gnuwin32-lzip
choco install -y gnuwin32-lzop
choco install -y gnuwin32-brotli
choco install -y gnuwin32-zip
choco install -y gnuwin32-unzip
choco install -y gnuwin32-unrar
choco install -y gnuwin32-pv

# Install fish
choco install -y fish
```

#### Option C: MSYS2
```bash
# Install MSYS2 from https://www.msys2.org/
# Then in MSYS2 terminal:
pacman -S file tar gzip bzip2 xz zstd lz4 lzip lzop brotli zip unzip p7zip lz4 bsdtar pv pigz pbzip2 pxz fish
```

## Installation Methods

### Method 1: Fisher (Recommended)

[Fisher](https://github.com/jorgebucaran/fisher) is the most convenient way to install fish plugins.

1. **Install Fisher** (if not already installed):
   ```fish
   curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher
   ```

2. **Install Archivist**:
   ```fish
   fisher install xiaokanchengyang/fish-extractor
   ```

3. **Verify Installation**:
   ```fish
   archdoctor
   ```

4. **Update** (when new version available):
   ```fish
   fisher update xiaokanchengyang/fish-extractor
   ```

5. **Uninstall**:
   ```fish
   fisher remove xiaokanchengyang/fish-extractor
   ```

### Method 2: Manual Installation

1. **Clone the repository**:
   ```fish
   git clone https://github.com/xiaokanchengyang/fish-extractor.git ~/.config/fish/plugins/archivist
   ```

2. **Create symbolic links**:
   ```fish
   # Link functions
   ln -sf ~/.config/fish/plugins/archivist/functions/*.fish ~/.config/fish/functions/
   
   # Link completions
   ln -sf ~/.config/fish/plugins/archivist/completions/*.fish ~/.config/fish/completions/
   
   # Link initialization
   ln -sf ~/.config/fish/plugins/archivist/conf.d/*.fish ~/.config/fish/conf.d/
   ```

3. **Reload fish configuration**:
   ```fish
   source ~/.config/fish/config.fish
   ```

4. **Verify Installation**:
   ```fish
   archdoctor
   ```

5. **Update**:
   ```fish
   cd ~/.config/fish/plugins/archivist
   git pull
   ```

6. **Uninstall**:
   ```fish
   rm ~/.config/fish/functions/__archivist*.fish
   rm ~/.config/fish/functions/archx.fish
   rm ~/.config/fish/functions/archc.fish
   rm ~/.config/fish/functions/archdoctor.fish
   rm ~/.config/fish/completions/archivist.fish
   rm ~/.config/fish/conf.d/archivist.fish
   rm -rf ~/.config/fish/plugins/archivist
   ```

### Method 3: Direct Copy

For simple installations without git:

1. **Download the latest release** from GitHub

2. **Extract and copy files**:
   ```fish
   # Extract archive
   archx archivist-1.0.0.tar.gz  # or: tar xf archivist-1.0.0.tar.gz
   
   # Copy files
   cp -r archivist-1.0.0/functions/* ~/.config/fish/functions/
   cp -r archivist-1.0.0/completions/* ~/.config/fish/completions/
   cp -r archivist-1.0.0/conf.d/* ~/.config/fish/conf.d/
   ```

3. **Reload fish**:
   ```fish
   exec fish
   ```

## Post-Installation

### 1. Verify Installation

Run the diagnostic tool:
```fish
archdoctor -v
```

This will:
- Check for required and optional tools
- Display your configuration
- Show supported formats
- Provide installation suggestions

### 2. Test Basic Functionality

```fish
# Test extraction help
archx --help

# Test compression help
archc --help

# Create a test archive
echo "test" > test.txt
archc test.tar.gz test.txt

# Extract it
archx --list test.tar.gz
archx --test test.tar.gz
archx test.tar.gz

# Clean up
rm -rf test.txt test/ test.tar.gz
```

### 3. Configure (Optional)

Create `~/.config/fish/conf.d/archivist_user.fish`:

```fish
# Your custom configuration
set -gx ARCHIVIST_DEFAULT_THREADS 8
set -gx ARCHIVIST_COLOR always
set -gx ARCHIVIST_LOG_LEVEL info
```

See `examples/config.fish` for more configuration options.

### 4. Add Custom Aliases (Optional)

In your `~/.config/fish/config.fish`:

```fish
# Short aliases
alias x='archx'
alias c='archc'

# Common operations
alias extract='archx'
alias compress='archc'
```

## Troubleshooting

### Fish Version Too Old

```fish
# Check version
fish --version

# Upgrade fish (Arch Linux)
sudo pacman -Syu fish
```

### Commands Not Found After Installation

```fish
# Reload fish configuration
source ~/.config/fish/config.fish

# Or restart fish
exec fish

# Check if files exist
ls ~/.config/fish/functions/__archivist*.fish
ls ~/.config/fish/completions/archivist.fish
ls ~/.config/fish/conf.d/archivist.fish
```

### Missing Required Tools

```fish
# Check what's missing
archdoctor

# Install missing tools (Arch Linux)
archdoctor --fix  # Shows installation commands
```

### Permission Issues

```fish
# Ensure config directory exists and is writable
mkdir -p ~/.config/fish/{functions,completions,conf.d}
chmod -R u+w ~/.config/fish
```

### Completions Not Working

```fish
# Reload completions
fish_update_completions

# Check if completion file exists
test -f ~/.config/fish/completions/archivist.fish
and echo "Completion file exists"
or echo "Completion file missing"
```

## Verifying Installation

After installation, all three commands should work:

```fish
# Check if commands exist
type archx
type archc  
type archdoctor

# Run diagnostics
archdoctor -v

# Test extraction
archx --help

# Test compression
archc --help
```

Expected output for `type archx`:
```
archx is a function with definition
# Defined in /home/user/.config/fish/functions/__archivist_extract.fish
...
```

## Updating

### With Fisher
```fish
fisher update xiaokanchengyang/fish-extractor
```

### Manual Installation
```fish
cd ~/.config/fish/plugins/archivist
git pull
source ~/.config/fish/config.fish
```

## Uninstalling

### With Fisher
```fish
fisher remove xiaokanchengyang/fish-extractor
```

### Manual Installation
```fish
rm ~/.config/fish/functions/__archivist*.fish
rm ~/.config/fish/completions/archivist.fish  
rm ~/.config/fish/conf.d/archivist.fish
rm -rf ~/.config/fish/plugins/archivist
```

## Getting Help

- **Documentation**: See [README.md](README.md)
- **Examples**: See [examples/](examples/)
- **Issues**: Report bugs on GitHub
- **Command help**: Run `archx --help` or `archc --help`

## Next Steps

1. Read the [README.md](README.md) for detailed usage
2. Check [examples/](examples/) for common use cases
3. Run `archdoctor -v` to see your system capabilities
4. Try creating your first archive: `archc test.tar.zst ./testdir`

---

**Note**: This plugin requires fish 4.12+. Earlier versions are not supported.
