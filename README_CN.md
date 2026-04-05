# Fish Pack - Fish Shell 档案管理工具

[![Fish Shell](https://img.shields.io/badge/fish-4.1.2%2B-blue)](https://fishshell.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-4.0.0-green.svg)](https://github.com/xiaokanchengyang/fish-pack)

**Fish Pack** 是为 [fish shell](https://fishshell.com/) 打造的安全、专业级档案管理工具。它提供强大、直观的命令来打包和解包档案，支持智能格式检测、并行处理、增强的安全功能以及全面的选项配置。

[English](README.md) | 简体中文

## 🚀 安装

### 使用 [Fisher](https://github.com/jorgebucaran/fisher) (推荐)

```fish
fisher install xiaokanchengyang/fish-pack
```

> **改名说明**: 项目原本名为 `fish-extractor`，现已更名为 `fish-pack`。请确保您使用更新后的安装命令。

### 📋 系统要求

#### 最低要求 (fish 4.1.2+)
- `fish` >= 4.1.2
- `file` (MIME 类型检测)
- `tar`, `gzip` (基础功能)

#### 推荐安装
为了获得最佳性能和广泛的格式支持，建议安装以下软件包：
```bash
# Arch Linux / Manjaro
pacman -S file tar gzip bzip2 xz zstd lz4 unzip zip p7zip bsdtar unrar pv pigz pbzip2

# Ubuntu / Debian
apt-get install file tar gzip bzip2 xz-utils zstd liblz4-tool unzip zip p7zip-full libarchive-tools unrar pv pigz pbzip2

# macOS (Homebrew)
brew install gnu-tar gzip bzip2 xz zstd lz4 p7zip libarchive unrar pv pigz pbzip2

# Windows (MSYS2)
pacman -S file tar gzip bzip2 xz zstd lz4 unzip zip p7zip libarchive
```

## ✨ 特性

- 🛡️ **安全第一** - 严格防范目录遍历（ZipSlip）攻击和安全处理密码。
- 🎯 **智能压缩策略**: 根据文件大小、类型、CPU 核心数自动选择最优算法（小/中用 `zstd`，大文件用 `pigz/gzip`，文本密集用 `xz`）
- 🚀 **高性能**: 支持多线程压缩/解压和优化算法
- 📦 **广泛的格式支持**: 支持 `.xz`、`.lz4`、`.zst` 等现代格式，tar/zip/7z/rar 等
- 🧰 **跨平台一致性**: 自动检测可用工具，提供 macOS/Linux/Windows (MSYS2) 安装建议
- 🧵 **批量任务队列**: `archqueue` 支持一次提交多个任务，顺序或并行执行

## 📖 使用指南

Fish Pack 提供四个主要命令：`extract`、`compress`、`archqueue` 和 `check`。

### 1. 档案解压 (`extract`)

智能解压各种格式的档案：

```fish
extract file.tar.gz                    # 解压到 ./file/
extract -d output/ archive.zip         # 指定目标目录
extract --strip 1 dist.tar.xz          # 剥离顶层目录
extract -p secret encrypted.7z         # 解压加密档案
extract --list archive.zip             # 列出内容
```

### 2. 档案压缩 (`compress`)

创建档案并智能选择格式：

```fish
compress --smart output.auto ./project  # 根据内容智能选择最优格式
compress backup.tar.zst ./data          # 根据后缀检测格式（快速 zstd 压缩）
compress -F tar.xz -L 9 logs.tar.xz /var/log   # 最大压缩
compress -e -p secret secure.zip docs/  # 加密 ZIP
compress -i '*.txt' -x '*.tmp' docs.zip . # 包含和排除文件
```

### 3. 批量任务队列 (`archqueue`)

一次性提交多个压缩/解压任务，后台顺序或并行执行：

```fish
# 顺序执行（默认）
archqueue \
  'compress::backup.tzst::src/ docs/' \
  'extract::release.zip::dist'

# 并行执行，最多 3 个并发任务
archqueue --parallel 3 \
  'compress::a.tzst::a/' \
  'compress::b.tzst::b/' \
  'extract::x.zip::xdir'
```

### 4. 系统检查 (`check`)

诊断系统的档案处理能力并提供修复建议：

```fish
check        # 基本系统检查
check -v     # 详细诊断
check --fix  # 获取安装建议
```

## ⚙️ 配置

可以在您的 `~/.config/fish/config.fish` 中进行配置：

```fish
# 颜色输出: auto (默认), always, never
set -Ux FISH_PACK_COLOR auto

# 进度条: auto (默认), always, never
set -Ux FISH_PACK_PROGRESS auto

# 默认线程数 (默认: CPU 核心数)
set -Ux FISH_PACK_DEFAULT_THREADS 8

# 日志级别: debug, info (默认), warn, error
set -Ux FISH_PACK_LOG_LEVEL info
```

## 🤝 贡献

欢迎贡献！请随时提交问题、功能请求或拉取请求。

## 📄 许可

MIT License - 详见 LICENSE 文件
