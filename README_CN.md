# Fish Extractor (鱼壳解压器) - Fish Shell 档案管理工具

[![Fish Shell](https://img.shields.io/badge/fish-4.12%2B-blue)](https://fishshell.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-2.0.0-green.svg)](https://github.com/xiaokanchengyang/fish-extractor)

**Fish Extractor** 是为 [fish shell](https://fishshell.com/) 打造的专业级档案管理工具。它提供强大、直观的命令来解压和压缩档案，支持智能格式检测、并行处理以及全面的选项配置。

[English](README.md) | 简体中文

## ✨ 特性

- 🎯 **智能压缩策略**: 根据文件大小、类型、CPU 核心数自动选择最优算法（小/中用 `zstd`，大文件用 `pigz/gzip`，文本密集用 `xz`）
- 🚀 **高性能**: 支持多线程压缩/解压和优化算法
- 📦 **广泛的格式支持**: 支持 `.xz`、`.lz4`、`.zst` 等现代格式，tar/zip/7z/rar 等
- 🧰 **跨平台一致性**: 自动检测可用工具，提供 macOS/Linux/Windows (MSYS2) 安装建议
- 🎨 **用户体验**: 实时进度/速度/剩余时间，完成后显示压缩率与估算 CPU 利用率
- 🧵 **批量任务队列**: `archqueue` 支持一次提交多个任务，顺序或并行执行
- 🔐 **加密支持**: 支持 zip 和 7z 格式的密码保护
- 🧪 **测试与验证**: 内置完整性检查和校验和验证
- 🔧 **高度可配置**: 通过环境变量自定义
- 📝 **全面的帮助**: 详细的使用信息和示例

## 📋 系统要求

### 最低要求 (fish 4.12+)
- `fish` >= 4.12
- `file` (MIME 类型检测)
- `tar`, `gzip` (基础功能)

### 推荐安装
```bash
# Arch Linux / Manjaro
pacman -S file tar gzip bzip2 xz zstd lz4 unzip zip p7zip bsdtar

# Ubuntu / Debian
apt-get install file tar gzip bzip2 xz-utils zstd liblz4-tool unzip zip p7zip-full libarchive-tools

# macOS (Homebrew)
brew install gnu-tar gzip bzip2 xz zstd lz4 p7zip libarchive

# Windows (MSYS2)
pacman -S file tar gzip bzip2 xz zstd lz4 unzip zip p7zip libarchive

# 可选：增强性能
pacman -S unrar pv lzip lzop brotli pigz pbzip2  # Arch
apt-get install unrar pv lzip lzop brotli pigz pbzip2  # Debian/Ubuntu
brew install unrar pv lzip lzop brotli pigz pbzip2  # macOS
```

### 功能矩阵

| 格式         | 解压 | 压缩 | 测试 | 多线程 | 加密 |
|--------------|------|------|------|--------|------|
| tar          | ✓    | ✓    | ✓    | -      | -    |
| tar.gz/tgz   | ✓    | ✓    | ✓    | pigz   | -    |
| tar.bz2/tbz2 | ✓    | ✓    | ✓    | pbzip2 | -    |
| tar.xz/txz   | ✓    | ✓    | ✓    | ✓      | -    |
| tar.zst/tzst | ✓    | ✓    | ✓    | ✓      | -    |
| tar.lz4/tlz4 | ✓    | ✓    | ✓    | ✓      | -    |
| tar.lz/tlz   | ✓    | ✓    | ✓    | -      | -    |
| tar.lzo/tzo  | ✓    | ✓    | -    | -      | -    |
| tar.br/tbr   | ✓    | ✓    | -    | -      | -    |
| zip          | ✓    | ✓    | ✓    | -      | ✓    |
| 7z           | ✓    | ✓    | ✓    | ✓      | ✓    |
| rar          | ✓    | -    | ✓    | -      | ✓    |
| gz, bz2, xz  | ✓    | ✓    | ✓    | ✓      | -    |
| zst, lz4     | ✓    | ✓    | ✓    | ✓      | -    |
| iso          | ✓    | -    | -    | -      | -    |
| deb, rpm     | ✓    | -    | -    | -      | -    |

## 🚀 安装

### 使用 [Fisher](https://github.com/jorgebucaran/fisher) (推荐)

```fish
fisher install xiaokanchengyang/fish-extractor
```

### 手动安装

```fish
git clone https://github.com/xiaokanchengyang/fish-extractor ~/.config/fish/fish-extractor
ln -sf ~/.config/fish/fish-extractor/functions/*.fish ~/.config/fish/functions/
ln -sf ~/.config/fish/fish-extractor/completions/*.fish ~/.config/fish/completions/
ln -sf ~/.config/fish/fish-extractor/conf.d/*.fish ~/.config/fish/conf.d/
```

### 验证安装

```fish
doctor
```

## 📖 使用方法

### 档案解压 (`extract`)

智能解压各种格式的档案：

```fish
extract file.tar.gz                    # 解压到 ./file/
extract -d output/ archive.zip         # 指定目标目录
extract --strip 1 dist.tar.xz          # 剥离顶层目录
extract -p secret encrypted.7z         # 解压加密档案
extract --list archive.zip             # 列出内容
extract --test backup.tar.gz           # 测试完整性
extract --verify data.tar.xz           # 校验和验证
extract *.tar.gz                       # 解压多个档案
extract -t 16 large-archive.tar.zst    # 多线程
extract --backup --force archive.zip   # 备份+覆盖
extract --checksum important.txz       # 生成校验和
extract -v complicated.7z              # 详细输出
```

### 档案压缩 (`compress`)

创建档案并智能选择格式：

```fish
compress backup.tar.zst ./data          # zstd 快速压缩
compress -F tar.xz -L 9 logs.tar.xz /var/log   # 最大压缩
compress --smart output.auto ./project  # 智能格式
compress -e -p secret secure.zip docs/  # 加密 ZIP
compress -x '*.tmp' -x '*.log' clean.tgz .   # 排除
compress -i '*.txt' -i '*.md' docs.zip .     # 仅包含
compress -u existing.tar.gz newfile.txt      # 更新
compress -t 16 -F tar.zst fast.tzst large-dir/ # 多线程
compress -C /var/www -F tar.xz web-backup.txz html/ # 切目录
compress --solid -F 7z backup.7z data/         # 固实 7z
compress --checksum backup.tar.xz data/        # 校验和
compress --split 100M large.zip huge-files/    # 分割
compress -v -L 7 -F tar.xz archive.txz files/  # 详细
```

### 批量任务队列 (`archqueue`)

一次性提交多个压缩/解压任务，后台顺序或并行执行：

```fish
archqueue --sequential 'compress::out.tzst::src/' 'extract::dist.zip::./out'
archqueue --parallel 3 'compress::a.tzst::a/' 'compress::b.tzst::b/' 'extract::x.zip::xdir'
```

## ⚙️ 配置

见 `docs/USAGE.md`。

## 🆕 本次更新

- 智能压缩策略：未指定格式时，小/中用 `zstd`，大文件优先 `pigz/gzip`，文本密集用 `xz`
- 新增现代格式原生支持：`.xz`、`.lz4`、`.zst` 单文件压缩/解压
- 进度与统计：显示 ETA/速度/平均速率，完成后展示压缩率与估算 CPU 利用率
- 批量任务队列：`archqueue` 支持并行/顺序与失败即停
- 跨平台一致性：文档提供 macOS/Linux/Windows (MSYS2) 安装建议
- 更多 fish 4.12 语法与体验优化

## 🤝 贡献

欢迎贡献！请随时提交问题、功能请求或拉取请求。

详见 [CONTRIBUTING.md](docs/CONTRIBUTING.md)

## 📄 许可

MIT License - 详见 LICENSE 文件
