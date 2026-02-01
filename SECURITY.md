# Security Policy for Fish Pack

## Core Philosophy

Fish Pack (fish-pack) prioritizes **Fail-Fast Security** and **Strict Verification**. Our goal is to prevent common archive-based vulnerabilities like "ZipSlip" (Path Traversal) and ensure safe handling of sensitive data (passwords).

## Path Traversal Protection

By default, `extract` operates in **Strict Mode**.

1.  **Detection**: Before extraction, every member path in the archive is scanned.
2.  **Rules**:
    *   **Absolute Paths**: Paths starting with `/` are rejected.
    *   **Traversal**: Paths containing parent directory references (`..`) as path segments (e.g., `../`, `a/../b`) are rejected.
3.  **Action**: If **any** unsafe path is detected, the operation **aborts immediately** (skips the archive) and logs an error. We do not attempt to "sanitize" or rewrite paths silently, as this can lead to unexpected behavior or incomplete protection.

## Temporary Files & Directories

*   **Permissions**: All temporary directories and files are created with strict permissions (`0700` for directories, `0600` for files).
*   **Cleanup**: We ensure temporary artifacts are cleaned up using rigorous logic, even on failure.

## Password Handling

*   **No Leaks**: Passwords are read securely using `read -s` (silent mode).
*   **Process Safety**: Where possible, we avoid passing passwords directly on the command line if the tool supports secure alternatives (like reading from stdin).
*   **Fail-Fast**: If encryption is detected but no password is provided (and the tool requires one), or if password confirmation fails, the operation aborts.

## Reporting Vulnerabilities

If you discover a security vulnerability in Fish Pack, please open an issue on our repository. We treat security issues with high priority.
