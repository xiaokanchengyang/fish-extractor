# Fish Pack - Project Structure

This document explains the organization and purpose of each directory and file in the Fish Pack project.

## Table of Contents

- [Overview](#overview)
- [Directory Structure](#directory-structure)
- [Core Architecture](#core-architecture)
- [Development Guidelines](#development-guidelines)

## Overview

Fish Pack follows the standard Fish shell plugin structure with strict separation of concerns for maintainability, security, and performance.

```
fish-pack/
├── functions/              # Autoloadable functions (Core Commands)
│   └── common/             # Shared utility functions and security logic
├── completions/            # Tab completion definitions
├── conf.d/                 # Plugin initialization and configuration
├── examples/               # Usage examples
├── tests/                  # Integration and unit tests
├── docs/                   # Detailed documentation
├── README.md               # Main entry point
├── LICENSE                 # MIT license
├── SECURITY.md             # Security policy
└── VERSION                 # Current version number
```

## Directory Structure

### `functions/`

Contains the primary commands exposed to the user. Each file represents an autoloadable function.

| File | Command | Description |
|------|---------|-------------|
| `extract.fish` | `extract` | Intelligent archive extraction engine. |
| `compress.fish` | `compress` | Smart archive compression engine. |
| `archqueue.fish`| `archqueue`| Batch task queue manager (Parallel/Sequential). |
| `check.fish` | `check` | System diagnostic and repair tool (formerly `doctor`). |
| `archive_manager.fish` | (Internal) | Entry point for shared logic (legacy). |

### `functions/common/`

Contains the internal logic, shared utilities, and security primitives. These are sourced by the main commands and are not meant to be called directly by users.

| File | Purpose |
|------|---------|
| `optimized_common.fish` | Core utilities (logging, performance, thread calculation). |
| `security_helpers.fish` | **Security Core**. Implements path traversal checks and secure temp files. |
| `secure_archive_ops.fish`| Secure wrapper for archive operations (password handling). |
| `safe_exec.fish` | Safe command execution wrappers (prevents injection). |
| `format_operations.fish` | Format detection, validation, and command selection logic. |
| `platform_helpers.fish` | Cross-platform compatibility (Linux/macOS/BSD). |

### `conf.d/`

Handles plugin initialization.

- `archive_manager.fish`: Sets up default environment variables (`FISH_ARCHIVE_COLOR`, etc.) and handles backward compatibility aliases.

### `completions/`

Provides rich tab completion for `fish`.

- `archive_manager.fish`: Definitions for `extract`, `compress`, `check`.
- `completions.fish`: Helper functions for completions.

## Core Architecture

### Modular Design

Fish Pack uses a layered architecture:

1.  **Command Layer (`functions/*.fish`)**:
    -   Handles argument parsing (`argparse`).
    -   Validates user input.
    -   Orchestrates the workflow.
    -   Example: `extract` command parses flags, calls `security_helpers` to verify the archive, then calls `secure_archive_ops` to perform the work.

2.  **Logic Layer (`functions/common/*.fish`)**:
    -   Implements the actual business logic.
    -   **Security First**: `security_helpers.fish` enforces strict checks (Fail-Fast on path traversal).
    -   **Performance**: `optimized_common.fish` handles thread calculation and progress bars.

### Security Model

-   **Strict Verification**: Every archive is scanned for unsafe paths (e.g., `../`, absolute paths) *before* any extraction command is executed.
-   **Fail-Fast**: If *any* unsafe path is found, the entire operation is aborted. We do not attempt to "sanitize" paths to avoid ambiguity.
-   **Secure Execution**: All shell commands are constructed as arrays to prevent shell injection attacks.

## Development Guidelines

### Adding a New Feature

1.  **New Command**: Create a new file in `functions/` (e.g., `verify.fish`).
2.  **Shared Logic**: Add helper functions to `functions/common/` with a `__fish_archive_` or `__fish_pack_` prefix to avoid namespace collisions.
3.  **Security**: Always use `__fish_pack_safe_exec` for external commands.

### Testing

-   All changes must pass the test suite.
-   Run tests using: `fish tests/run_all.fish`
-   Tests cover: Core logic, security (path traversal), integration, and the task queue.

---

**For more information:**
- [Usage Guide](USAGE.md)
- [Security Policy](../SECURITY.md)
