# Archivist (fish plugin)

High-quality extraction and compression commands for fish (Arch Linux friendly), with smart format detection, progress, colors, concurrency, and robust error handling. Requires fish 4.12+.

## Installation

Using Fisher:

```fish
fisher install <your-username>/archivist
```

Requirements (recommended): `file`, `tar`, `gzip`, `xz`, `zstd`, `bzip2`, `lz4`, `unzip`, `7z`, `bsdtar`, optional: `unrar`, `pv`.

## Commands

- `archx`: Extract archives. Supports zip, 7z, rar, tar.gz/xz/zst/bz2/lz4, iso, and more via bsdtar/7z fallback.
- `archc`: Create archives with smart format (`--smart` or `--format auto`).
- `archdoctor`: Check environment and configuration.

## Usage

```fish
archx [OPTIONS] FILE...
  -d, --dest DIR          Destination directory (default derived)
  -f, --force             Overwrite existing files
  -s, --strip NUM         Strip leading path components (tar)
  -p, --password PASS     Password for encrypted archives
  -t, --threads N         Parallelism for batch files
  -q, --quiet             Reduce output verbosity
      --no-progress       Disable progress display
      --list              List contents only
      --dry-run           Show actions without executing
      --help              Show help

archc [OPTIONS] OUTPUT [INPUT ...]
  -F, --format FMT        auto|zip|7z|tar.gz|tar.xz|tar.zst|tar.bz2|tar.lz4|tar
  -L, --level N           Compression level
  -t, --threads N         Threads for compressors
  -e, --encrypt           Enable encryption if supported
  -p, --password PASS     Password for encryption
  -C, --chdir DIR         Change directory before adding inputs
  -i, --include-glob G    Include only paths matching glob (repeatable)
  -x, --exclude-glob G    Exclude paths matching glob (repeatable)
  -q, --quiet             Reduce output verbosity
      --no-progress       Disable progress display
      --smart             Choose best format automatically
      --dry-run           Show actions without executing
      --help              Show help
```

## Configuration

Set environment variables (e.g., in `~/.config/fish/conf.d/archivist.fish`):

- `ARCHIVIST_DEFAULT_THREADS`: default concurrency (e.g., `8`).
- `ARCHIVIST_COLOR`: `auto` (default), `always`, `never`.
- `ARCHIVIST_PROGRESS`: `auto` (default), `always`, `never`.
- `ARCHIVIST_SMART_LEVEL`: heuristic strength (reserved for future use).
- `ARCHIVIST_DEFAULT_FORMAT`: default output format if not `auto`.
- `ARCHIVIST_PARANOID`: if `1`, additional safety checks.
- `ARCHIVIST_LOG_LEVEL`: `debug|info|warn|error` (default `info`).

## Features

- Smart format selection based on file content (`file` MIME): text-heavy -> xz, mixed -> gz, binary-heavy -> zstd.
- Progress display for large archives using `pv` where possible.
- Colorful output with `ARCHIVIST_COLOR` control.
- Concurrency for batch extraction and streaming compression pipelines.
- Robust argument parsing and helpful errors.
- Completions for `archx` and `archc`.
- Doctor command to preflight environment.

## Notes

- RAR extraction prefers `unrar` but falls back to `bsdtar`.
- For encrypted archives, `zip`/`7z` support is available. `tar` encryption is not provided.
- On very large inputs, prefer `tar.zst` with threads for speed, or `tar.xz` for maximum compression of text-heavy data.

## Version

- Requires fish 4.12+.

## License

MIT
