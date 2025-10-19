# Security Policy

## Supported Versions

We currently support the following versions of Fish Pack with security updates:

| Version | Supported          |
| ------- | ------------------ |
| 4.0.x   | :white_check_mark: |
| 3.0.x   | :x:                |
| < 3.0   | :x:                |

## Reporting a Vulnerability

We take security vulnerabilities seriously. If you discover a security vulnerability in Fish Pack, please report it responsibly.

### How to Report

1. **DO NOT** create a public GitHub issue for security vulnerabilities
2. Email security details to: [security@example.com](mailto:security@example.com)
3. Include the following information:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)
   - Your contact information

### What to Expect

- We will acknowledge receipt within 48 hours
- We will provide regular updates on our progress
- We will work with you to understand and resolve the issue
- We will credit you in our security advisories (unless you prefer to remain anonymous)

## Security Features

Fish Pack includes comprehensive security features:

### Input Validation
- All file paths are sanitized to prevent directory traversal attacks
- Filenames are cleaned to remove dangerous characters
- Archive contents are validated before extraction

### Safe Command Execution
- No use of `eval` or dangerous shell constructs
- All external commands are properly escaped
- Command arguments are validated before execution

### Temporary File Security
- **mktemp usage**: All temp files/dirs created with mktemp
- **Restricted permissions**: Files (600), directories (700)
- **Automatic cleanup**: Cleanup on success, error, or interrupt
- **No fallback to predictable names**: Fails safely if mktemp unavailable

### Password Handling
- **Secure input**: Passwords never appear in command lines or process lists
- **Interactive prompts**: Uses `read -s` for silent password input
- **Temporary files**: Password files created with 600 permissions and immediate cleanup
- **No eval usage**: Commands built safely without shell interpretation

### Archive Security
- Path traversal protection in archive extraction
- Validation of archive integrity before extraction
- Safe handling of symbolic links

## Security Best Practices

### For Users

1. **Verify Archives**: Always verify archive integrity before extraction
   ```fish
   extract --test suspicious-archive.tar.gz
   extract --verify trusted-archive.tar.xz
   ```

2. **Use Trusted Sources**: Only extract archives from trusted sources
   ```fish
   # Good: Known source
   extract official-release.tar.gz
   
   # Bad: Unknown source
   extract random-file-from-internet.tar.gz
   ```

3. **Check Permissions**: Be aware of file permissions after extraction
   ```fish
   # Check what was extracted
   extract --list archive.tar.gz
   ```

4. **Use Secure Passwords**: When creating encrypted archives
   ```fish
   # Good: Interactive prompt (not stored in history)
   compress -e secure.zip ./files
   
   # Now safe: Password handled securely internally
   compress -e secure.zip ./files  # Prompts for password
   ```

### For Developers

1. **Input Validation**: Always validate and sanitize user input
2. **Error Handling**: Implement proper error handling without exposing sensitive information
3. **Logging**: Log security-relevant events without exposing sensitive data
4. **Testing**: Include security tests in your test suite

## Known Security Considerations

### Archive Extraction
- **Path Traversal**: Archives may contain paths like `../../../etc/passwd`
  - **Mitigation**: All paths are sanitized and validated before extraction
  - **Detection**: Use `extract --list` to inspect archive contents

### Command Injection
- **Risk**: Malicious filenames could execute commands
  - **Mitigation**: All external commands use proper argument escaping
  - **Prevention**: Filenames are sanitized before use

### Temporary Files
- **Risk**: Temporary files could be read by other users
  - **Mitigation**: Files are created with 600 permissions
  - **Cleanup**: Automatic cleanup on exit or error

### Password Exposure
- **Risk**: Passwords in command line are visible in process lists
  - **Mitigation**: Interactive prompts preferred
  - **Alternative**: Use environment variables for scripts

## Security Updates

Security updates are released as patch versions (e.g., 3.0.1). We recommend:

1. **Stay Updated**: Keep Fish Pack updated to the latest version
2. **Monitor Releases**: Watch for security advisories in release notes
3. **Test Updates**: Test updates in a safe environment before production use

## Security Audit

We regularly audit our code for security issues:

- **Static Analysis**: Automated security scanning
- **Code Review**: Manual security review of changes
- **Dependency Check**: Regular updates of dependencies
- **Penetration Testing**: Periodic security testing

## Contact

For security-related questions or concerns:

- **Security Issues**: [security@example.com](mailto:security@example.com)
- **General Questions**: [GitHub Issues](https://github.com/xiaokanchengyang/fish-pack/issues)
- **Documentation**: [Security Documentation](docs/SECURITY.md)

## Acknowledgments

We thank the security researchers and community members who have helped improve the security of Fish Pack through responsible disclosure.

---

**Last Updated**: October 2025
**Version**: 4.0.0