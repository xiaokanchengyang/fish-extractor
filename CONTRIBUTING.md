# Contributing to Archivist

Thank you for your interest in contributing to Archivist! This document provides guidelines and instructions for contributing.

## 🤝 How to Contribute

### Reporting Bugs

Before submitting a bug report:
1. Check existing issues to avoid duplicates
2. Run `archdoctor -v` to gather system information
3. Try to reproduce the issue with minimal input

When reporting:
- Include your fish version (`fish --version`)
- Include output of `archdoctor -v`
- Provide the exact command that failed
- Include any error messages
- Describe expected vs actual behavior

### Suggesting Features

We welcome feature suggestions! Please:
- Check if the feature already exists or is planned
- Explain the use case clearly
- Provide examples of how it would work
- Consider implementation complexity

### Pull Requests

1. **Fork and Clone**
   ```fish
   git clone https://github.com/your-username/archivist.git
   cd archivist
   ```

2. **Create a Branch**
   ```fish
   git checkout -b feature/your-feature-name
   ```

3. **Make Changes**
   - Follow the code style guidelines below
   - Test your changes thoroughly
   - Update documentation if needed

4. **Test Your Changes**
   ```fish
   # Install locally for testing
   fisher install .
   
   # Run diagnostics
   archdoctor -v
   
   # Test extraction
   archx --test test-file.tar.gz
   
   # Test compression
   archc --dry-run test.tar.zst test-dir/
   ```

5. **Commit Your Changes**
   ```fish
   git add .
   git commit -m "feat: add new feature description"
   ```

6. **Push and Create PR**
   ```fish
   git push origin feature/your-feature-name
   ```

## 📝 Code Style Guidelines

### Fish Shell Best Practices

1. **Use Modern fish Syntax (4.12+)**
   ```fish
   # Good
   set -l items (string split , -- $input)
   
   # Avoid (old style)
   set -l items (echo $input | tr ',' '\n')
   ```

2. **Function Documentation**
   ```fish
   function __archivist__helper --description 'Brief description of what it does'
       # Function implementation
   end
   ```

3. **Error Handling**
   ```fish
   # Always check command results
   __archivist__require_cmds tar; or return 127
   
   # Validate inputs
   if not test -e "$file"
       __archivist__log error "File not found: $file"
       return 1
   end
   ```

4. **Variable Naming**
   - Use descriptive names: `archive_path` not `ap`
   - Use snake_case: `thread_count` not `threadCount`
   - Local variables: `set -l variable_name`
   - Global variables: `set -g variable_name`
   - Exported variables: `set -gx VARIABLE_NAME`

5. **Comments**
   - Use English for all comments
   - Document complex logic
   - Add section headers for readability
   - Keep comments concise but clear

### Code Organization

1. **File Structure**
   ```
   functions/
     __archivist_common.fish      # Shared utilities
     __archivist_extract.fish     # Extraction logic
     __archivist_compress.fish    # Compression logic
     __archivist_doctor.fish      # Diagnostics
   completions/
     archivist.fish               # Tab completions
   conf.d/
     archivist.fish               # Initialization
   ```

2. **Function Prefixes**
   - Public commands: `archx`, `archc`, `archdoctor`
   - Internal helpers: `__archivist__function_name`
   - Format handlers: `__archivist__create_FORMAT`, `__archivist__extract_FORMAT`

3. **Section Organization**
   ```fish
   # ============================================================================
   # Section Name
   # ============================================================================
   
   function __archivist__something
       # Implementation
   end
   ```

### Testing

Before submitting:

1. **Test All Commands**
   ```fish
   # Extraction
   archx --help
   archx --list test.tar.gz
   archx --test test.tar.gz
   archx test.tar.gz
   
   # Compression
   archc --help
   archc --dry-run test.tar.zst testdir/
   archc test.tar.zst testdir/
   
   # Doctor
   archdoctor
   archdoctor -v
   archdoctor --fix
   ```

2. **Test Edge Cases**
   - Non-existent files
   - Permission issues
   - Invalid formats
   - Empty archives
   - Special characters in filenames

3. **Test Different Formats**
   - Test at least: tar.gz, tar.xz, tar.zst, zip, 7z
   - Test with and without optional tools

### Documentation

Update documentation when:
- Adding new features
- Changing command options
- Modifying behavior
- Adding new formats

Required documentation updates:
- README.md: User-facing changes
- CHANGELOG.md: All changes
- Function `--description`: Updated descriptions
- Help text: Updated usage strings

## 🔍 Code Review Process

Pull requests will be reviewed for:

1. **Functionality**
   - Does it work as intended?
   - Are edge cases handled?
   - Is error handling adequate?

2. **Code Quality**
   - Follows style guidelines
   - No unnecessary complexity
   - Appropriate use of fish features
   - Proper error handling

3. **Performance**
   - No unnecessary command spawning
   - Efficient algorithms
   - Appropriate use of parallelism

4. **Compatibility**
   - Works with fish 4.12+
   - Handles missing optional dependencies
   - Cross-platform considerations

5. **Documentation**
   - Clear comments
   - Updated help text
   - README changes if needed

## 🎯 Development Tips

### Debugging

```fish
# Enable debug logging
set -gx ARCHIVIST_LOG_LEVEL debug

# Verbose output
archx -v file.tar.gz
archc -v output.tar.zst input/

# Dry run mode
archx --dry-run file.tar.gz
archc --dry-run output.tar.zst input/
```

### Local Testing

```fish
# Install from local directory
fisher install .

# Reload functions after changes
source ~/.config/fish/conf.d/archivist.fish

# Uninstall
fisher remove archivist
```

### Performance Profiling

```fish
# Time operations
time archx large-file.tar.gz
time archc output.tar.zst large-dir/

# Check thread usage
archc -t 1 vs -t (nproc) output.tar.zst input/
```

## 🚀 Release Process

For maintainers:

1. Update version in relevant files
2. Update CHANGELOG.md
3. Tag release: `git tag -a v1.0.0 -m "Release 1.0.0"`
4. Push tag: `git push origin v1.0.0`
5. Create GitHub release with notes

## 📞 Getting Help

- Open an issue for bugs or questions
- Check existing documentation
- Review closed issues for similar problems

## 📄 License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to Archivist! 🎉
