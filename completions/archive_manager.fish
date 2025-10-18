# Fish Archive Manager - Completions (fish 4.12+)
# Optimized completions with modern Fish features

# ============================================================================
# Extract Command Completions
# ============================================================================

complete -c extract -n "not __fish_seen_subcommand_from --help" -s h -l help -d "Display help message"
complete -c extract -n "not __fish_seen_subcommand_from --help" -s d -l dest -r -d "Destination directory"
complete -c extract -n "not __fish_seen_subcommand_from --help" -s f -l force -d "Overwrite existing files"
complete -c extract -n "not __fish_seen_subcommand_from --help" -s s -l strip -r -d "Strip leading path components"
complete -c extract -n "not __fish_seen_subcommand_from --help" -s p -l password -r -d "Password for encrypted archives"
complete -c extract -n "not __fish_seen_subcommand_from --help" -s t -l threads -r -d "Number of threads"
complete -c extract -n "not __fish_seen_subcommand_from --help" -s q -l quiet -d "Suppress non-error output"
complete -c extract -n "not __fish_seen_subcommand_from --help" -s v -l verbose -d "Enable verbose output"
complete -c extract -n "not __fish_seen_subcommand_from --help" -s k -l keep -d "Keep archive file after extraction"
complete -c extract -n "not __fish_seen_subcommand_from --help" -l no-progress -d "Disable progress indicators"
complete -c extract -n "not __fish_seen_subcommand_from --help" -l list -d "List archive contents"
complete -c extract -n "not __fish_seen_subcommand_from --help" -l test -d "Test archive integrity"
complete -c extract -n "not __fish_seen_subcommand_from --help" -l verify -d "Verify with checksum"
complete -c extract -n "not __fish_seen_subcommand_from --help" -l overwrite -d "Always overwrite"
complete -c extract -n "not __fish_seen_subcommand_from --help" -l flat -d "Extract without directory structure"
complete -c extract -n "not __fish_seen_subcommand_from --help" -l dry-run -d "Show what would be done"
complete -c extract -n "not __fish_seen_subcommand_from --help" -l backup -d "Create backup before extraction"
complete -c extract -n "not __fish_seen_subcommand_from --help" -l checksum -d "Generate checksum file"
complete -c extract -n "not __fish_seen_subcommand_from --help" -l auto-rename -d "Automatically rename output"
complete -c extract -n "not __fish_seen_subcommand_from --help" -l timestamp -d "Add timestamp to directory name"
complete -c extract -n "not __fish_seen_subcommand_from --help" -l preserve-perms -d "Preserve file permissions"
complete -c extract -n "not __fish_seen_subcommand_from --help" -l no-preserve-perms -d "Don't preserve file permissions"

# Archive file completions
complete -c extract -n "not __fish_seen_subcommand_from --help" -f -a "*.tar.gz *.tgz *.tar.bz2 *.tbz2 *.tbz *.tar.xz *.txz *.tar.zst *.tzst *.tar.lz4 *.tlz4 *.tar.lz *.tlz *.tar.lzo *.tzo *.tar.br *.tbr *.zip *.7z *.rar *.gz *.bz2 *.xz *.zst *.lz4 *.lz *.lzo *.br *.iso *.deb *.rpm"

# ============================================================================
# Compress Command Completions
# ============================================================================

complete -c compress -n "not __fish_seen_subcommand_from --help" -s h -l help -d "Display help message"
complete -c compress -n "not __fish_seen_subcommand_from --help" -s F -l format -r -d "Archive format" -a "tar tar.gz tgz tar.bz2 tbz2 tbz tar.xz txz tar.zst tzst tar.lz4 tlz4 tar.lz tlz tar.lzo tzo tar.br tbr zip 7z auto"
complete -c compress -n "not __fish_seen_subcommand_from --help" -s L -l level -r -d "Compression level (1-9)"
complete -c compress -n "not __fish_seen_subcommand_from --help" -s t -l threads -r -d "Number of threads"
complete -c compress -n "not __fish_seen_subcommand_from --help" -s e -l encrypt -d "Enable encryption"
complete -c compress -n "not __fish_seen_subcommand_from --help" -s p -l password -r -d "Encryption password"
complete -c compress -n "not __fish_seen_subcommand_from --help" -s C -l chdir -r -d "Change directory before adding files"
complete -c compress -n "not __fish_seen_subcommand_from --help" -s i -l include-glob -r -d "Include only matching files"
complete -c compress -n "not __fish_seen_subcommand_from --help" -s x -l exclude-glob -r -d "Exclude matching files"
complete -c compress -n "not __fish_seen_subcommand_from --help" -s u -l update -d "Update existing archive"
complete -c compress -n "not __fish_seen_subcommand_from --help" -s a -l append -d "Append to existing archive"
complete -c compress -n "not __fish_seen_subcommand_from --help" -s q -l quiet -d "Suppress non-error output"
complete -c compress -n "not __fish_seen_subcommand_from --help" -s v -l verbose -d "Enable verbose output"
complete -c compress -n "not __fish_seen_subcommand_from --help" -l no-progress -d "Disable progress indicators"
complete -c compress -n "not __fish_seen_subcommand_from --help" -l smart -d "Automatically choose best format"
complete -c compress -n "not __fish_seen_subcommand_from --help" -l solid -d "Create solid archive (7z only)"
complete -c compress -n "not __fish_seen_subcommand_from --help" -l checksum -d "Generate checksum file"
complete -c compress -n "not __fish_seen_subcommand_from --help" -l split -r -d "Split archive into parts"
complete -c compress -n "not __fish_seen_subcommand_from --help" -l dry-run -d "Show what would be done"
complete -c compress -n "not __fish_seen_subcommand_from --help" -l timestamp -d "Add timestamp to archive name"
complete -c compress -n "not __fish_seen_subcommand_from --help" -l auto-rename -d "Automatically rename if output exists"
complete -c compress -n "not __fish_seen_subcommand_from --help" -l compare -d "Compare compression efficiency"

# Output file completions
complete -c compress -n "not __fish_seen_subcommand_from --help" -f -a "*.tar *.tar.gz *.tgz *.tar.bz2 *.tbz2 *.tbz *.tar.xz *.txz *.tar.zst *.tzst *.tar.lz4 *.tlz4 *.tar.lz *.tlz *.tar.lzo *.tzo *.tar.br *.tbr *.zip *.7z *.auto"

# ============================================================================
# Doctor Command Completions
# ============================================================================

complete -c doctor -n "not __fish_seen_subcommand_from --help" -s h -l help -d "Display help message"
complete -c doctor -n "not __fish_seen_subcommand_from --help" -s v -l verbose -d "Show detailed information"
complete -c doctor -n "not __fish_seen_subcommand_from --help" -s q -l quiet -d "Only show errors"
complete -c doctor -n "not __fish_seen_subcommand_from --help" -l fix -d "Suggest fixes for missing tools"
complete -c doctor -n "not __fish_seen_subcommand_from --help" -l export -d "Export diagnostic report"

# Archqueue completions
complete -c archqueue -n "not __fish_seen_subcommand_from --help" -l parallel -r -d "Run N tasks in parallel"
complete -c archqueue -n "not __fish_seen_subcommand_from --help" -l sequential -d "Run tasks sequentially"
complete -c archqueue -n "not __fish_seen_subcommand_from --help" -l stop-on-error -d "Stop on first failure"
complete -c archqueue -n "__fish_use_subcommand" -a "compress:: extract::" -d "Task kinds"

# ============================================================================
# Backward Compatibility Completions
# ============================================================================

# Extract aliases
complete -c extractor -n "not __fish_seen_subcommand_from --help" -s h -l help -d "Display help message"
complete -c extractor -n "not __fish_seen_subcommand_from --help" -s d -l dest -r -d "Destination directory"
complete -c extractor -n "not __fish_seen_subcommand_from --help" -s f -l force -d "Overwrite existing files"
complete -c extractor -n "not __fish_seen_subcommand_from --help" -s s -l strip -r -d "Strip leading path components"
complete -c extractor -n "not __fish_seen_subcommand_from --help" -s p -l password -r -d "Password for encrypted archives"
complete -c extractor -n "not __fish_seen_subcommand_from --help" -s t -l threads -r -d "Number of threads"
complete -c extractor -n "not __fish_seen_subcommand_from --help" -s q -l quiet -d "Suppress non-error output"
complete -c extractor -n "not __fish_seen_subcommand_from --help" -s v -l verbose -d "Enable verbose output"
complete -c extractor -n "not __fish_seen_subcommand_from --help" -s k -l keep -d "Keep archive file after extraction"
complete -c extractor -n "not __fish_seen_subcommand_from --help" -l no-progress -d "Disable progress indicators"
complete -c extractor -n "not __fish_seen_subcommand_from --help" -l list -d "List archive contents"
complete -c extractor -n "not __fish_seen_subcommand_from --help" -l test -d "Test archive integrity"
complete -c extractor -n "not __fish_seen_subcommand_from --help" -l verify -d "Verify with checksum"
complete -c extractor -n "not __fish_seen_subcommand_from --help" -l overwrite -d "Always overwrite"
complete -c extractor -n "not __fish_seen_subcommand_from --help" -l flat -d "Extract without directory structure"
complete -c extractor -n "not __fish_seen_subcommand_from --help" -l dry-run -d "Show what would be done"
complete -c extractor -n "not __fish_seen_subcommand_from --help" -l backup -d "Create backup before extraction"
complete -c extractor -n "not __fish_seen_subcommand_from --help" -l checksum -d "Generate checksum file"
complete -c extractor -n "not __fish_seen_subcommand_from --help" -l auto-rename -d "Automatically rename output"
complete -c extractor -n "not __fish_seen_subcommand_from --help" -l timestamp -d "Add timestamp to directory name"
complete -c extractor -n "not __fish_seen_subcommand_from --help" -l preserve-perms -d "Preserve file permissions"
complete -c extractor -n "not __fish_seen_subcommand_from --help" -l no-preserve-perms -d "Don't preserve file permissions"

# Compress aliases
complete -c compressor -n "not __fish_seen_subcommand_from --help" -s h -l help -d "Display help message"
complete -c compressor -n "not __fish_seen_subcommand_from --help" -s F -l format -r -d "Archive format" -a "tar tar.gz tgz tar.bz2 tbz2 tbz tar.xz txz tar.zst tzst tar.lz4 tlz4 tar.lz tlz tar.lzo tzo tar.br tbr zip 7z auto"
complete -c compressor -n "not __fish_seen_subcommand_from --help" -s L -l level -r -d "Compression level (1-9)"
complete -c compressor -n "not __fish_seen_subcommand_from --help" -s t -l threads -r -d "Number of threads"
complete -c compressor -n "not __fish_seen_subcommand_from --help" -s e -l encrypt -d "Enable encryption"
complete -c compressor -n "not __fish_seen_subcommand_from --help" -s p -l password -r -d "Encryption password"
complete -c compressor -n "not __fish_seen_subcommand_from --help" -s C -l chdir -r -d "Change directory before adding files"
complete -c compressor -n "not __fish_seen_subcommand_from --help" -s i -l include-glob -r -d "Include only matching files"
complete -c compressor -n "not __fish_seen_subcommand_from --help" -s x -l exclude-glob -r -d "Exclude matching files"
complete -c compressor -n "not __fish_seen_subcommand_from --help" -s u -l update -d "Update existing archive"
complete -c compressor -n "not __fish_seen_subcommand_from --help" -s a -l append -d "Append to existing archive"
complete -c compressor -n "not __fish_seen_subcommand_from --help" -s q -l quiet -d "Suppress non-error output"
complete -c compressor -n "not __fish_seen_subcommand_from --help" -s v -l verbose -d "Enable verbose output"
complete -c compressor -n "not __fish_seen_subcommand_from --help" -l no-progress -d "Disable progress indicators"
complete -c compressor -n "not __fish_seen_subcommand_from --help" -l smart -d "Automatically choose best format"
complete -c compressor -n "not __fish_seen_subcommand_from --help" -l solid -d "Create solid archive (7z only)"
complete -c compressor -n "not __fish_seen_subcommand_from --help" -l checksum -d "Generate checksum file"
complete -c compressor -n "not __fish_seen_subcommand_from --help" -l split -r -d "Split archive into parts"
complete -c compressor -n "not __fish_seen_subcommand_from --help" -l dry-run -d "Show what would be done"
complete -c compressor -n "not __fish_seen_subcommand_from --help" -l timestamp -d "Add timestamp to archive name"
complete -c compressor -n "not __fish_seen_subcommand_from --help" -l auto-rename -d "Automatically rename if output exists"
complete -c compressor -n "not __fish_seen_subcommand_from --help" -l compare -d "Compare compression efficiency"

# ============================================================================
# Dynamic Completions
# ============================================================================

# Thread count completions based on CPU cores
function __fish_archive_complete_threads --description 'Complete thread counts based on CPU cores'
    set -l cores (nproc 2>/dev/null; or sysctl -n hw.ncpu 2>/dev/null; or echo 4)
    for i in (seq 1 $cores)
        echo "$i\t$i threads"
    end
end

# Format completions based on available tools
function __fish_archive_complete_formats --description 'Complete available archive formats'
    echo "tar\tUncompressed tar archive"
    echo "tar.gz\tGzip compressed tar archive"
    echo "tgz\tShort name for tar.gz"
    echo "tar.bz2\tBzip2 compressed tar archive"
    echo "tbz2\tShort name for tar.bz2"
    echo "tar.xz\tXZ compressed tar archive"
    echo "txz\tShort name for tar.xz"
    echo "tar.zst\tZstd compressed tar archive"
    echo "tzst\tShort name for tar.zst"
    echo "tar.lz4\tLZ4 compressed tar archive"
    echo "tlz4\tShort name for tar.lz4"
    echo "zip\tZIP archive"
    echo "7z\t7-Zip archive"
    echo "auto\tAutomatically choose best format"
end

# Archive file completions
function __fish_archive_complete_archive_files --description 'Complete archive file names'
    # Use modern Fish features for file completion
    for file in *.tar.gz *.tgz *.tar.bz2 *.tbz2 *.tbz *.tar.xz *.txz *.tar.zst *.tzst *.tar.lz4 *.tlz4 *.zip *.7z *.rar 2>/dev/null
        echo "$file"
    end
end

# Apply dynamic completions
complete -c compress -n "__fish_seen_subcommand_from -F --format" -a "(__fish_archive_complete_formats)"
complete -c compressor -n "__fish_seen_subcommand_from -F --format" -a "(__fish_archive_complete_formats)"
complete -c extract -n "__fish_seen_subcommand_from -t --threads" -a "(__fish_archive_complete_threads)"
complete -c extractor -n "__fish_seen_subcommand_from -t --threads" -a "(__fish_archive_complete_threads)"
complete -c compress -n "__fish_seen_subcommand_from -t --threads" -a "(__fish_archive_complete_threads)"
complete -c compressor -n "__fish_seen_subcommand_from -t --threads" -a "(__fish_archive_complete_threads)"
complete -c extract -n "__fish_seen_subcommand_from -s --strip" -a "1 2 3 4 5"
complete -c extractor -n "__fish_seen_subcommand_from -s --strip" -a "1 2 3 4 5"
complete -c compress -n "__fish_seen_subcommand_from -L --level" -a "1 2 3 4 5 6 7 8 9"
complete -c compressor -n "__fish_seen_subcommand_from -L --level" -a "1 2 3 4 5 6 7 8 9"
complete -c compress -n "__fish_seen_subcommand_from --split" -a "100M 500M 1G 2G 4G"
complete -c compressor -n "__fish_seen_subcommand_from --split" -a "100M 500M 1G 2G 4G"
