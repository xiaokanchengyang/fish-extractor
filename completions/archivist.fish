# Fish completions for Archivist plugin (fish 4.12+)
# Provides intelligent tab completions for archx, archc, and archdoctor commands

# ============================================================================
# Helper Functions for Dynamic Completions
# ============================================================================

function __archivist_complete_formats --description 'List available archive formats'
    echo -e "auto\tAutomatically detect best format"
    echo -e "tar\tUncompressed tar archive"
    command -q gzip; and echo -e "tar.gz\tGzip compressed tar (balanced)"
    command -q bzip2; and echo -e "tar.bz2\tBzip2 compressed tar (high compression)"
    command -q xz; and echo -e "tar.xz\tXZ compressed tar (maximum compression)"
    command -q zstd; and echo -e "tar.zst\tZstd compressed tar (fast and efficient)"
    command -q lz4; and echo -e "tar.lz4\tLZ4 compressed tar (very fast)"
    command -q lzip; and echo -e "tar.lz\tLzip compressed tar"
    command -q lzop; and echo -e "tar.lzo\tLZO compressed tar"
    command -q brotli; and echo -e "tar.br\tBrotli compressed tar"
    command -q zip; and echo -e "zip\tZIP archive (universal)"
    command -q 7z; and echo -e "7z\t7-Zip archive (high compression)"
    echo -e "tgz\tShort for tar.gz"
    echo -e "tbz2\tShort for tar.bz2"
    echo -e "txz\tShort for tar.xz"
    echo -e "tzst\tShort for tar.zst"
    echo -e "tlz4\tShort for tar.lz4"
end

function __archivist_complete_archive_files --description 'Complete archive file names'
    set -l exts '*.tar' '*.tar.gz' '*.tgz' '*.tar.bz2' '*.tbz2' '*.tar.xz' '*.txz' \
                '*.tar.zst' '*.tzst' '*.tar.lz4' '*.tlz4' '*.tar.lz' '*.tlz' \
                '*.zip' '*.7z' '*.rar' '*.gz' '*.bz2' '*.xz' '*.zst' '*.lz4' \
                '*.iso' '*.deb' '*.rpm'
    
    for ext in $exts
        __fish_complete_suffix $ext
    end
end

function __archivist_complete_directories --description 'Complete directory names only'
    __fish_complete_directories
end

function __archivist_complete_threads --description 'Suggest thread counts'
    set -l cores (nproc 2>/dev/null; or echo 4)
    echo -e "1\tSingle thread"
    echo -e "2\t2 threads"
    echo -e "4\t4 threads"
    if test $cores -ge 6
        echo -e "6\t6 threads"
    end
    if test $cores -ge 8
        echo -e "8\t8 threads"
    end
    if test $cores -ge 12
        echo -e "12\t12 threads"
    end
    if test $cores -ge 16
        echo -e "16\t16 threads"
    end
    echo -e "$cores\tAll available cores"
end

# ============================================================================
# archx - Archive Extraction
# ============================================================================

# Basic options
complete -c archx -s d -l dest -r -F -d 'Destination directory'
complete -c archx -s f -l force -d 'Overwrite existing files'
complete -c archx -l overwrite -d 'Always overwrite (alias for --force)'
complete -c archx -s s -l strip -r -d 'Strip NUM leading path components'
complete -c archx -s p -l password -r -d 'Password for encrypted archives'
complete -c archx -s t -l threads -x -a '(__archivist_complete_threads)' -d 'Number of threads'
complete -c archx -s q -l quiet -d 'Suppress non-error output'
complete -c archx -s v -l verbose -d 'Enable verbose output'
complete -c archx -s k -l keep -d 'Keep archive after extraction'
complete -c archx -l no-progress -d 'Disable progress indicators'
complete -c archx -l list -d 'List archive contents without extracting'
complete -c archx -l test -d 'Test archive integrity'
complete -c archx -l flat -d 'Extract without directory structure'
complete -c archx -l dry-run -d 'Show what would be done'
complete -c archx -s h -l help -d 'Display help message'

# File completions for archives
complete -c archx -xa '(__archivist_complete_archive_files)'

# Compression level suggestions for strip option
complete -c archx -n '__fish_seen_subcommand_from --strip -s' -xa '0 1 2 3'

# ============================================================================
# archc - Archive Compression
# ============================================================================

# Format selection
complete -c archc -s F -l format -x -a '(__archivist_complete_formats)' -d 'Archive format'

# Basic options
complete -c archc -s L -l level -x -a '1 2 3 4 5 6 7 8 9' -d 'Compression level (1=fast, 9=best)'
complete -c archc -s t -l threads -x -a '(__archivist_complete_threads)' -d 'Number of threads'
complete -c archc -s e -l encrypt -d 'Enable encryption (zip/7z)'
complete -c archc -s p -l password -r -d 'Encryption password'
complete -c archc -s C -l chdir -r -F -d 'Change to directory before compressing'
complete -c archc -s i -l include-glob -r -d 'Include pattern (can repeat)'
complete -c archc -s x -l exclude-glob -r -d 'Exclude pattern (can repeat)'
complete -c archc -s u -l update -d 'Update existing archive'
complete -c archc -s a -l append -d 'Append to existing archive'
complete -c archc -s q -l quiet -d 'Suppress non-error output'
complete -c archc -s v -l verbose -d 'Enable verbose output'
complete -c archc -l no-progress -d 'Disable progress indicators'
complete -c archc -l smart -d 'Automatically choose best format'
complete -c archc -l solid -d 'Create solid archive (7z only)'
complete -c archc -l dry-run -d 'Show what would be done'
complete -c archc -s h -l help -d 'Display help message'

# Common glob patterns for include/exclude
complete -c archc -n '__fish_seen_subcommand_from --include-glob -i' -xa '
    "*.txt\tText files"
    "*.log\tLog files"
    "*.md\tMarkdown files"
    "*.jpg\tJPEG images"
    "*.png\tPNG images"
    "*.pdf\tPDF files"
    "*.zip\tZIP archives"
'

complete -c archc -n '__fish_seen_subcommand_from --exclude-glob -x' -xa '
    "*.tmp\tTemporary files"
    "*.log\tLog files"
    "*.cache\tCache files"
    "*~\tBackup files"
    ".git/*\tGit repository"
    "node_modules/*\tNode modules"
    "__pycache__/*\tPython cache"
    "*.pyc\tPython bytecode"
    ".DS_Store\tmacOS metadata"
    "Thumbs.db\tWindows thumbnails"
'

# ============================================================================
# archdoctor - Environment Diagnostics
# ============================================================================

complete -c archdoctor -s v -l verbose -d 'Show detailed information'
complete -c archdoctor -s q -l quiet -d 'Only show errors'
complete -c archdoctor -l fix -d 'Suggest fixes for issues'
complete -c archdoctor -s h -l help -d 'Display help message'

# ============================================================================
# Context-Aware Completions
# ============================================================================

# For archc, suggest common output filenames based on format
complete -c archc -n '__fish_seen_subcommand_from --format -F' -xa '
    backup.tar.zst
    archive.tar.xz
    compressed.zip
    backup.7z
'

# Suggest appropriate compression levels based on format
complete -c archc -n '__fish_contains_opt -s F format; and string match -q "*tar.xz*" (commandline -cp)' -s L -l level -xa '6\tDefault 9\tMaximum'
complete -c archc -n '__fish_contains_opt -s F format; and string match -q "*tar.zst*" (commandline -cp)' -s L -l level -xa '3\tFast 6\tDefault 19\tMaximum'
complete -c archc -n '__fish_contains_opt -s F format; and string match -q "*tar.gz*" (commandline -cp)' -s L -l level -xa '6\tDefault 9\tMaximum'
complete -c archc -n '__fish_contains_opt -s F format; and string match -q "*7z*" (commandline -cp)' -s L -l level -xa '5\tDefault 9\tUltra'

# ============================================================================
# Legacy Command Support (if aliases are used)
# ============================================================================

# If user has archextract/archcompress aliases, provide same completions
complete -c archextract -w archx
complete -c archcompress -w archc
