# Fish Extractor - Fish Shell 档案管理工具

[![Fish Shell](https://img.shields.io/badge/fish-4.12%2B-blue)](https://fishshell.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-2.0.0-green.svg)](https://github.com/your-username/fish-extractor)

**Fish Extractor** 是为 [fish shell](https://fishshell.com/) 打造的专业级档案管理工具。它提供强大、直观的命令来解压和压缩档案，支持智能格式检测、并行处理以及全面的选项配置。

[English](README.md) | 简体中文

## ✨ 特性

- 🎯 **智能格式检测**: 自动检测档案格式并选择最优压缩方式
- 🚀 **高性能**: 支持多线程压缩/解压和优化算法
- 📦 **广泛的格式支持**: 支持25+种格式，包括 tar、gzip、bzip2、xz、zstd、lz4、zip、7z、rar、iso 等
- 🎨 **美观的输出**: 彩色信息、进度条和详细统计数据
- 🔐 **加密支持**: 支持 zip 和 7z 格式的密码保护
- 🧪 **测试与验证**: 内置完整性检查和校验和验证
- 🔧 **高度可配置**: 通过环境变量自定义
- 📝 **全面的帮助**: 详细的使用信息和示例
- 🎓 **智能补全**: 上下文感知的 tab 自动补全
- 💾 **备份支持**: 解压前自动备份
- ✂️ **档案分割**: 将大型档案分割成可管理的部分
- 📊 **批量处理**: 高效处理多个档案

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
| gz, bz2, xz  | ✓    | -    | ✓    | ✓      | -    |
| zst, lz4     | ✓    | -    | ✓    | ✓      | -    |
| iso          | ✓    | -    | -    | -      | -    |
| deb, rpm     | ✓    | -    | -    | -      | -    |

## 🚀 安装

### 使用 [Fisher](https://github.com/jorgebucaran/fisher) (推荐)

```fish
fisher install your-username/fish-extractor
```

### 手动安装

```fish
git clone https://github.com/your-username/fish-extractor ~/.config/fish/fish-extractor
ln -sf ~/.config/fish/fish-extractor/functions/*.fish ~/.config/fish/functions/
ln -sf ~/.config/fish/fish-extractor/completions/*.fish ~/.config/fish/completions/
ln -sf ~/.config/fish/fish-extractor/conf.d/*.fish ~/.config/fish/conf.d/
```

### 验证安装

```fish
ext-doctor
```

## 📖 使用方法

### 档案解压 (`extractor`)

智能解压各种格式的档案：

```fish
# 基础解压
extractor file.tar.gz                    # 解压到 ./file/

# 指定目标目录
extractor -d output/ archive.zip         # 解压到 ./output/

# 剥离顶层目录（对嵌套档案很有用）
extractor --strip 1 dist.tar.xz          # 移除顶层目录

# 解压加密档案
extractor -p secret encrypted.7z         # 提供密码

# 列出内容而不解压
extractor --list archive.zip             # 预览内容

# 测试完整性
extractor --test backup.tar.gz           # 验证档案有效

# 校验和验证
extractor --verify data.tar.xz           # 检查完整性和校验和

# 解压多个档案
extractor *.tar.gz                       # 解压所有 .tar.gz 文件

# 使用自定义线程数并行解压
extractor -t 16 large-archive.tar.zst    # 使用 16 线程

# 解压前创建备份
extractor --backup --force archive.zip   # 备份现有目录

# 解压并生成校验和
extractor --checksum important.txz       # 生成 sha256 校验和

# 详细输出
extractor -v complicated.7z              # 显示详细进度
```

#### 选项说明

```
-d, --dest DIR          目标目录（默认：从档案名派生）
-f, --force             强制覆盖已存在文件
-s, --strip NUM         剥离 NUM 层目录组件
-p, --password PASS     加密档案的密码
-t, --threads NUM       解压的线程数
-q, --quiet             抑制非错误输出
-v, --verbose           详细输出
-k, --keep              解压后保留档案
    --no-progress       禁用进度指示器
    --list              仅列出内容
    --test              测试档案完整性
    --verify            使用校验和验证
    --flat              不保留目录结构解压
    --backup            解压前创建备份
    --checksum          生成校验和文件
    --dry-run           显示将要执行的操作
    --help              显示帮助
```

### 档案压缩 (`compressor`)

创建档案并智能选择格式：

```fish
# 基础压缩
compressor backup.tar.zst ./data          # 使用 zstd 快速压缩

# 最大压缩
compressor -F tar.xz -L 9 logs.tar.xz /var/log

# 智能格式（自动检测最佳压缩）
compressor --smart output.auto ./project

# 创建加密档案
compressor -e -p secret secure.zip docs/

# 排除模式
compressor -x '*.tmp' -x '*.log' clean.tgz .

# 仅包含特定文件
compressor -i '*.txt' -i '*.md' docs.zip .

# 更新已存在的档案
compressor -u existing.tar.gz newfile.txt

# 多线程压缩
compressor -t 16 -F tar.zst fast.tzst large-dir/

# 压缩前切换目录
compressor -C /var/www -F tar.xz web-backup.txz html/

# 固实 7z 档案（更好的压缩）
compressor --solid -F 7z backup.7z data/

# 创建时生成校验和
compressor --checksum backup.tar.xz data/

# 分割大型档案
compressor --split 100M large.zip huge-files/

# 详细输出和自定义级别
compressor -v -L 7 -F tar.xz archive.txz files/
```

#### 选项说明

```
-F, --format FMT        档案格式（见下方格式）
-L, --level NUM         压缩级别（1-9，取决于格式）
-t, --threads NUM       压缩的线程数
-e, --encrypt           启用加密 (zip/7z)
-p, --password PASS     加密密码
-C, --chdir DIR         添加文件前切换到目录
-i, --include-glob PAT  仅包含匹配的文件（可重复）
-x, --exclude-glob PAT  排除匹配的文件（可重复）
-u, --update            更新已存在的档案
-a, --append            追加到已存在的档案
-q, --quiet             抑制非错误输出
-v, --verbose           详细输出
    --no-progress       禁用进度指示器
    --smart             自动选择最佳格式
    --solid             固实档案 (仅 7z)
    --checksum          生成校验和文件
    --split SIZE        分割成指定大小（如 100M, 1G）
    --dry-run           显示将要执行的操作
    --help              显示帮助
```

#### 支持的格式

| 格式          | 说明                                     | 最适合                |
|---------------|------------------------------------------|-----------------------|
| `tar`         | 未压缩的 tar                             | 预处理                |
| `tar.gz`, `tgz` | Gzip 压缩（均衡）                       | 通用目的              |
| `tar.bz2`, `tbz2` | Bzip2（高压缩，慢）                    | 长期存储              |
| `tar.xz`, `txz` | XZ（文本最佳压缩）                       | 源代码、日志          |
| `tar.zst`, `tzst` | Zstd（快速，好压缩）                   | 大数据集              |
| `tar.lz4`, `tlz4` | LZ4（非常快，低压缩）                  | 临时档案              |
| `tar.lz`, `tlz` | Lzip（高压缩）                           | 科学数据              |
| `tar.lzo`, `tzo` | LZO（快速）                             | 实时压缩              |
| `tar.br`, `tbr` | Brotli（网络优化）                       | Web 资源              |
| `zip`         | ZIP（通用兼容）                          | 跨平台共享            |
| `7z`          | 7-Zip（高压缩，加密）                    | 安全备份              |
| `auto`        | 自动选择最佳                             | 智能默认              |

### 环境诊断 (`ext-doctor`)

检查系统的档案处理能力：

```fish
# 基础检查
ext-doctor

# 详细系统信息
ext-doctor -v

# 获取安装建议
ext-doctor --fix

# 导出诊断报告
ext-doctor --export

# 安静模式（仅错误）
ext-doctor -q
```

## ⚙️ 配置

通过设置环境变量配置 Fish Extractor（例如在 `~/.config/fish/config.fish` 中）：

```fish
# 彩色输出：auto（默认）、always、never
set -Ux FISH_EXTRACTOR_COLOR auto

# 进度指示器：auto（默认）、always、never
set -Ux FISH_EXTRACTOR_PROGRESS auto

# 默认线程数（默认：CPU 核心数）
set -Ux FISH_EXTRACTOR_DEFAULT_THREADS 8

# 日志级别：debug、info（默认）、warn、error
set -Ux FISH_EXTRACTOR_LOG_LEVEL info

# 智能选择的默认格式
set -Ux FISH_EXTRACTOR_DEFAULT_FORMAT auto
```

## 🎯 智能格式选择

Fish Extractor 可以根据数据自动选择最佳压缩格式：

```fish
compressor --smart output.auto ./mydata
```

**选择逻辑:**
- **70%+ 文本文件** → `tar.xz`（文本最大压缩）
- **30-70% 文本文件** → `tar.gz`（均衡，兼容）
- **<30% 文本文件** → `tar.zst`（快速，适合二进制数据）

## 💡 提示与最佳实践

### 性能优化

```fish
# 对大型二进制文件使用 zstd（快速）
compressor -F tar.zst -t $(nproc) backup.tzst /large/dataset

# 对文本密集内容使用 xz（最佳压缩）
compressor -F tar.xz -t $(nproc) source.txz /code

# 对临时档案使用 lz4（非常快）
compressor -F tar.lz4 temp.tlz4 /tmp/data
```

### 压缩级别指南

- **级别 1-3**：快速压缩，较大文件（适合临时档案）
- **级别 4-6**：均衡（推荐用于大多数情况）
- **级别 7-9**：最大压缩，较慢（适合长期存储）

### 安全档案

```fish
# 创建加密 ZIP
compressor -e -p "strong-password" secure.zip sensitive/

# 创建加密 7z 固实压缩
compressor --solid -e -p "strong-password" -F 7z backup.7z data/
```

### 处理大型档案

```fish
# 使用 pv 显示进度
extractor large-archive.tar.zst  # 自动显示进度条

# 使用多线程
extractor -t 16 huge-file.tar.xz

# 解压前测试
extractor --test archive.7z && extractor archive.7z

# 分割大型档案
compressor --split 100M large.zip huge-files/
```

### 备份工作流

```fish
# 带日期的每日备份
compressor -F tar.zst backup-$(date +%Y%m%d).tzst ~/Documents

# 增量备份（更新模式）
compressor -u backup.tar.zst ~/Documents

# 排除缓存和临时文件
compressor -x '*.cache' -x '*.tmp' -x '.git/*' clean-backup.tgz ~/project
```

### 开发工作流

```fish
# 打包源代码
compressor -F tar.xz -x 'node_modules/*' -x '__pycache__/*' release.txz .

# 创建带校验和的可分发档案
compressor --smart --checksum -x '*.log' -x '.env' dist.auto ./app

# 解压并验证
extractor --verify --test release.txz && extractor release.txz
```

## 🔧 故障排除

### 缺少工具

```fish
ext-doctor --fix  # 显示安装命令
```

### 解压失败

```fish
# 首先测试完整性
extractor --test problematic.tar.gz

# 尝试详细模式
extractor -v problematic.tar.gz

# 检查可用格式
ext-doctor -v
```

### 压缩问题

```fish
# 验证输入存在
compressor --dry-run output.tar.zst input/

# 检查格式支持
ext-doctor
```

## 🔄 与其他工具对比

| 功能                | Fish Extractor | `tar` + `*` | `atool` | `dtrx` |
|---------------------|----------------|-------------|---------|--------|
| 智能格式检测         | ✓              | -           | ✓       | ✓      |
| 多线程              | ✓              | 手动        | -       | -      |
| 进度指示器          | ✓              | 手动        | -       | -      |
| 档案测试            | ✓              | 手动        | -       | -      |
| 校验和验证          | ✓              | -           | -       | -      |
| 加密支持            | ✓              | -           | ✓       | -      |
| 批量处理            | ✓              | -           | -       | -      |
| 档案分割            | ✓              | 手动        | -       | -      |
| Fish 补全           | ✓              | 基础        | -       | -      |
| 现代 fish 语法      | ✓              | N/A         | N/A     | N/A    |

## 🤝 贡献

欢迎贡献！请随时提交问题、功能请求或拉取请求。

详见 [CONTRIBUTING.md](CONTRIBUTING.md)

## 📄 许可

MIT License - 详见 LICENSE 文件

## 🙏 致谢

- 灵感来自 `atool`、`dtrx` 等档案管理工具
- 为优秀的 [fish shell](https://fishshell.com/) 社区打造
- 使用现代 fish 4.12+ 特性以获得最佳性能

## 📚 更多文档

- [安装指南](INSTALL.md) (English)
- [贡献指南](CONTRIBUTING.md) (English)
- [使用示例](examples/README.md) (English)
- [开发总结](SUMMARY.md) (English)
- [fish shell 文档](https://fishshell.com/docs/current/)
- [Fisher 插件管理器](https://github.com/jorgebucaran/fisher)

---

**用 ❤️ 为 fish shell 用户打造**

## v2.0.0 新特性

- 🎉 **重命名为 Fish Extractor** - 更清晰、更专注的名称
- 🔧 **新命令**: `extractor`（解压）, `compressor`（压缩）, `ext-doctor`（诊断）
- ✨ **增强功能**:
  - 校验和验证和生成
  - 解压前自动备份
  - 档案分割支持
  - 改进的批量处理
  - 更好的错误处理和诊断
  - 通过并行工具优化性能（pigz, pbzip2）
- 📊 **更好的输出**: 压缩比、文件大小、详细统计
- 🎯 **改进的智能检测**: 更好的内容分析以选择格式
- 📝 **完全重写**: 更清晰的代码、更好的命名规范、全面的注释
