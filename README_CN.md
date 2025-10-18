# Archivist - Fish Shell 档案管理插件

[![Fish Shell](https://img.shields.io/badge/fish-4.12%2B-blue)](https://fishshell.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

一个为 [fish shell](https://fishshell.com/) 打造的高质量、功能丰富的档案管理插件。提供智能的解压和压缩命令，支持智能格式检测、广泛的格式支持、进度指示器以及全面的选项。

[English](README.md) | 简体中文

## ✨ 特性

- 🎯 **智能格式检测**: 自动检测档案格式并选择最优压缩方式
- 🚀 **高性能**: 支持多线程压缩/解压
- 📦 **广泛的格式支持**: tar, gzip, bzip2, xz, zstd, lz4, lzip, lzo, brotli, zip, 7z, rar, iso, deb, rpm 等25+种格式
- 🎨 **美观的输出**: 彩色信息和进度指示器
- 🔐 **加密支持**: 支持密码保护的档案 (zip, 7z)
- 🧪 **测试与验证**: 内置档案完整性检查
- 🔧 **高度可配置**: 通过环境变量自定义
- 📝 **全面的帮助**: 详细的使用信息和示例
- 🎓 **智能补全**: 上下文感知的 tab 补全

## 📋 系统要求

### 最低要求 (fish 4.12+)
- `fish` >= 4.12
- `file` (MIME 类型检测)
- `tar`, `gzip` (基础功能)

### 推荐安装 (Arch Linux)
```bash
pacman -S file tar gzip bzip2 xz zstd lz4 unzip zip p7zip bsdtar

# 可选：增强功能
pacman -S unrar pv lzip lzop brotli pigz pbzip2
```

## 🚀 安装

### 使用 [Fisher](https://github.com/jorgebucaran/fisher) (推荐)

```fish
fisher install your-username/archivist
```

### 手动安装

```fish
git clone https://github.com/your-username/archivist ~/.config/fish/plugins/archivist
ln -sf ~/.config/fish/plugins/archivist/functions/*.fish ~/.config/fish/functions/
ln -sf ~/.config/fish/plugins/archivist/completions/*.fish ~/.config/fish/completions/
ln -sf ~/.config/fish/plugins/archivist/conf.d/*.fish ~/.config/fish/conf.d/
```

### 验证安装

```fish
archdoctor
```

## 📖 使用方法

### 档案解压 (`archx`)

智能解压各种格式的档案：

```fish
# 基础解压
archx file.tar.gz                    # 解压到 ./file/

# 指定目标目录
archx -d output/ archive.zip         # 解压到 ./output/

# 剥离顶层目录（对嵌套档案很有用）
archx --strip 1 dist.tar.xz          # 移除顶层目录

# 解压加密档案
archx -p secret encrypted.7z         # 提供密码

# 列出内容而不解压
archx --list archive.zip             # 预览内容

# 测试完整性
archx --test backup.tar.gz           # 验证档案有效

# 解压多个档案
archx *.tar.gz                       # 解压所有 .tar.gz 文件

# 使用自定义线程数并行解压
archx -t 8 large-archive.tar.zst    # 使用 8 线程

# 详细输出
archx -v complicated.7z              # 显示详细进度
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
    --flat              不保留目录结构解压
    --dry-run           显示将要执行的操作
    --help              显示帮助
```

### 档案压缩 (`archc`)

创建档案并智能选择格式：

```fish
# 基础压缩
archc backup.tar.zst ./data          # 使用 zstd 快速压缩

# 最大压缩
archc -F tar.xz -L 9 logs.tar.xz /var/log

# 智能格式（自动检测最佳压缩）
archc --smart output.auto ./project

# 创建加密档案
archc -e -p secret secure.zip docs/

# 排除模式
archc -x '*.tmp' -x '*.log' clean.tgz .

# 仅包含特定文件
archc -i '*.txt' -i '*.md' docs.zip .

# 更新已存在的档案
archc -u existing.tar.gz newfile.txt

# 多线程压缩
archc -t 16 -F tar.zst fast.tzst large-dir/

# 压缩前切换目录
archc -C /var/www -F tar.xz web-backup.txz html/

# 固实 7z 档案（更好的压缩）
archc --solid -F 7z backup.7z data/
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
| `zip`         | ZIP（通用兼容）                          | 跨平台共享            |
| `7z`          | 7-Zip（高压缩，加密）                    | 安全备份              |
| `auto`        | 自动选择最佳                             | 智能默认              |

### 环境诊断 (`archdoctor`)

检查系统的档案处理能力：

```fish
# 基础检查
archdoctor

# 详细系统信息
archdoctor -v

# 获取安装建议
archdoctor --fix

# 安静模式（仅错误）
archdoctor -q
```

## ⚙️ 配置

通过设置环境变量配置 Archivist（例如在 `~/.config/fish/config.fish` 中）：

```fish
# 彩色输出：auto（默认）、always、never
set -gx ARCHIVIST_COLOR auto

# 进度指示器：auto（默认）、always、never
set -gx ARCHIVIST_PROGRESS auto

# 默认线程数（默认：CPU 核心数）
set -gx ARCHIVIST_DEFAULT_THREADS 8

# 日志级别：debug、info（默认）、warn、error
set -gx ARCHIVIST_LOG_LEVEL info

# 智能选择的默认格式
set -gx ARCHIVIST_DEFAULT_FORMAT auto
```

## 🎯 智能格式选择

Archivist 可以根据数据自动选择最佳压缩格式：

```fish
archc --smart output.auto ./mydata
```

**选择逻辑:**
- **70%+ 文本文件** → `tar.xz`（文本最大压缩）
- **30-70% 文本文件** → `tar.gz`（均衡，兼容）
- **<30% 文本文件** → `tar.zst`（快速，适合二进制数据）

## 💡 提示与最佳实践

### 性能优化

```fish
# 对大型二进制文件使用 zstd（快速）
archc -F tar.zst -t $(nproc) backup.tzst /large/dataset

# 对文本密集内容使用 xz（最佳压缩）
archc -F tar.xz -t $(nproc) source.txz /code

# 对临时档案使用 lz4（非常快）
archc -F tar.lz4 temp.tlz4 /tmp/data
```

### 压缩级别指南

- **级别 1-3**：快速压缩，较大文件（适合临时档案）
- **级别 4-6**：均衡（推荐用于大多数情况）
- **级别 7-9**：最大压缩，较慢（适合长期存储）

### 安全档案

```fish
# 创建加密 ZIP
archc -e -p "strong-password" secure.zip sensitive/

# 创建加密 7z 固实压缩
archc --solid -e -p "strong-password" -F 7z backup.7z data/
```

## 🔧 故障排除

### 缺少工具

```fish
archdoctor --fix  # 显示安装命令
```

### 解压失败

```fish
# 首先测试完整性
archx --test problematic.tar.gz

# 尝试详细模式
archx -v problematic.tar.gz
```

## 📝 常用示例

### 备份工作流

```fish
# 带日期的每日备份
archc -F tar.zst backup-(date +%Y%m%d).tzst ~/Documents

# 增量备份（更新模式）
archc -u backup.tar.zst ~/Documents

# 排除缓存和临时文件
archc -x '*.cache' -x '*.tmp' -x '.git/*' clean-backup.tgz ~/project
```

### 开发工作流

```fish
# 打包源代码
archc -F tar.xz -x 'node_modules/*' -x '__pycache__/*' release.txz .

# 创建可分发档案
archc --smart -x '*.log' -x '.env' dist.auto ./app
```

## 🤝 贡献

欢迎贡献！请随时提交问题、功能请求或拉取请求。

详见 [CONTRIBUTING.md](CONTRIBUTING.md)

## 📄 许可

MIT License - 详见 LICENSE 文件

## 🙏 致谢

- 灵感来自 `atool`、`dtrx` 等档案管理工具
- 为优秀的 [fish shell](https://fishshell.com/) 社区打造
- 使用现代 fish 4.12+ 特性以获得最佳性能

---

**用 ❤️ 为 fish shell 用户打造**

## 更多文档

- [完整安装指南](INSTALL.md) (English)
- [贡献指南](CONTRIBUTING.md) (English)
- [使用示例](examples/README.md) (English)
- [开发总结](SUMMARY.md) (English)
