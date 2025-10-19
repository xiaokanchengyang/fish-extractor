# Security Policy

## Supported Versions

We currently support the following versions of Fish Archive Manager with security updates:

| Version | Supported          |
| ------- | ------------------ |
| 3.0.x   | :white_check_mark: |
| 2.x.x   | :x:                |
| 1.x.x   | :x:                |

## Reporting a Vulnerability

We take security vulnerabilities seriously. If you discover a security vulnerability in Fish Archive Manager, please report it responsibly.

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

Fish Archive Manager includes several security features:

### Input Validation
- All file paths are sanitized to prevent directory traversal attacks
- Filenames are cleaned to remove dangerous characters
- Archive contents are validated before extraction

### Safe Command Execution
- No use of `eval` or dangerous shell constructs
- All external commands are properly escaped
- Command arguments are validated before execution

### Temporary File Security
- Temporary files are created with secure permissions (600)
- Temporary files are automatically cleaned up
- Random filenames prevent predictable paths

### Password Handling
- Passwords are not logged or stored in command history
- Interactive password prompts when possible
- Environment variable support for scripts

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
   
   # Avoid: Password in command line
   compress -e -p "password123" secure.zip ./files
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

1. **Stay Updated**: Keep Fish Archive Manager updated to the latest version
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
- **General Questions**: [GitHub Issues](https://github.com/xiaokanchengyang/fish-extractor/issues)
- **Documentation**: [Security Documentation](docs/SECURITY.md)

## Acknowledgments

We thank the security researchers and community members who have helped improve the security of Fish Archive Manager through responsible disclosure.

---

**Last Updated**: December 2024
**Version**: 3.0.0