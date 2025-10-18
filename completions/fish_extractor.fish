# Fish completions for Fish Extractor plugin (fish 4.12+)
# Provides intelligent tab completions for extractor, compressor, and ext-doctor commands

# ============================================================================
# Helper Functions for Dynamic Completions
# ============================================================================

function __fish_extractor_complete_formats --description 'List available archive formats'
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

function __fish_extractor_complete_archive_files --description 'Complete archive file names'
    set -l exts '*.tar' '*.tar.gz' '*.tgz' '*.tar.bz2' '*.tbz2' '*.tar.xz' '*.txz' \
                '*.tar.zst' '*.tzst' '*.tar.lz4' '*.tlz4' '*.tar.lz' '*.tlz' \
                '*.zip' '*.7z' '*.rar' '*.gz' '*.bz2' '*.xz' '*.zst' '*.lz4' \
                '*.iso' '*.deb' '*.rpm'
    
    for ext in $exts
        __fish_complete_suffix $ext
    end
end

function __fish_extractor_complete_directories --description 'Complete directory names only'
    __fish_complete_directories
end

function __fish_extractor_complete_threads --description 'Suggest thread counts'
    set -l cores (nproc 2>/dev/null; or sysctl -n hw.ncpu 2>/dev/null; or echo 4)
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
# extract / extractor - Archive Extraction
# ============================================================================

# Basic options for extract command
complete -c extract -s d -l dest -r -F -d 'Destination directory'
complete -c extract -s f -l force -d 'Overwrite existing files'
complete -c extract -l overwrite -d 'Always overwrite (alias for --force)'
complete -c extract -s s -l strip -r -d 'Strip NUM leading path components'
complete -c extract -s p -l password -r -d 'Password for encrypted archives'
complete -c extract -s t -l threads -x -a '(__fish_extractor_complete_threads)' -d 'Number of threads'
complete -c extract -s q -l quiet -d 'Suppress non-error output'
complete -c extract -s v -l verbose -d 'Enable verbose output'
complete -c extract -s k -l keep -d 'Keep archive after extraction'
complete -c extract -l no-progress -d 'Disable progress indicators'
complete -c extract -l list -d 'List archive contents without extracting'
complete -c extract -l test -d 'Test archive integrity'
complete -c extract -l verify -d 'Verify archive with checksum'
complete -c extract -l flat -d 'Extract without directory structure'
complete -c extract -l dry-run -d 'Show what would be done'
complete -c extract -l backup -d 'Create backup before extraction'
complete -c extract -l checksum -d 'Generate checksum after extraction'
complete -c extract -s h -l help -d 'Display help message'

# File completions for archives (extract command)
complete -c extract -xa '(__fish_extractor_complete_archive_files)'

# Compression level suggestions for strip option (extract command)
complete -c extract -n '__fish_seen_subcommand_from --strip -s' -xa '0 1 2 3'

# Basic options for extractor command (alias)
complete -c extractor -s d -l dest -r -F -d 'Destination directory'
complete -c extractor -s f -l force -d 'Overwrite existing files'
complete -c extractor -l overwrite -d 'Always overwrite (alias for --force)'
complete -c extractor -s s -l strip -r -d 'Strip NUM leading path components'
complete -c extractor -s p -l password -r -d 'Password for encrypted archives'
complete -c extractor -s t -l threads -x -a '(__fish_extractor_complete_threads)' -d 'Number of threads'
complete -c extractor -s q -l quiet -d 'Suppress non-error output'
complete -c extractor -s v -l verbose -d 'Enable verbose output'
complete -c extractor -s k -l keep -d 'Keep archive after extraction'
complete -c extractor -l no-progress -d 'Disable progress indicators'
complete -c extractor -l list -d 'List archive contents without extracting'
complete -c extractor -l test -d 'Test archive integrity'
complete -c extractor -l verify -d 'Verify archive with checksum'
complete -c extractor -l flat -d 'Extract without directory structure'
complete -c extractor -l dry-run -d 'Show what would be done'
complete -c extractor -l backup -d 'Create backup before extraction'
complete -c extractor -l checksum -d 'Generate checksum after extraction'
complete -c extractor -s h -l help -d 'Display help message'

# File completions for archives
complete -c extractor -xa '(__fish_extractor_complete_archive_files)'

# Compression level suggestions for strip option
complete -c extractor -n '__fish_seen_subcommand_from --strip -s' -xa '0 1 2 3'

# ============================================================================
# compress / compressor - Archive Compression
# ============================================================================

# Format selection for compress command
complete -c compress -s F -l format -x -a '(__fish_extractor_complete_formats)' -d 'Archive format'

# Basic options for compress command
complete -c compress -s L -l level -x -a '1 2 3 4 5 6 7 8 9' -d 'Compression level (1=fast, 9=best)'
complete -c compress -s t -l threads -x -a '(__fish_extractor_complete_threads)' -d 'Number of threads'
complete -c compress -s e -l encrypt -d 'Enable encryption (zip/7z)'
complete -c compress -s p -l password -r -d 'Encryption password'
complete -c compress -s C -l chdir -r -F -d 'Change to directory before compressing'
complete -c compress -s i -l include-glob -r -d 'Include pattern (can repeat)'
complete -c compress -s x -l exclude-glob -r -d 'Exclude pattern (can repeat)'
complete -c compress -s u -l update -d 'Update existing archive'
complete -c compress -s a -l append -d 'Append to existing archive'
complete -c compress -s q -l quiet -d 'Suppress non-error output'
complete -c compress -s v -l verbose -d 'Enable verbose output'
complete -c compress -l no-progress -d 'Disable progress indicators'
complete -c compress -l smart -d 'Automatically choose best format'
complete -c compress -l solid -d 'Create solid archive (7z only)'
complete -c compress -l checksum -d 'Generate checksum file'
complete -c compress -l split -r -d 'Split archive into parts (e.g., 100M, 1G)'
complete -c compress -l dry-run -d 'Show what would be done'
complete -c compress -s h -l help -d 'Display help message'

# Common glob patterns for include/exclude (compress command)
complete -c compress -n '__fish_seen_subcommand_from --include-glob -i' -xa '
    "*.txt\tText files"
    "*.log\tLog files"
    "*.md\tMarkdown files"
    "*.jpg\tJPEG images"
    "*.png\tPNG images"
    "*.pdf\tPDF files"
    "*.doc\tWord documents"
    "*.xls\tExcel files"
'

complete -c compress -n '__fish_seen_subcommand_from --exclude-glob -x' -xa '
    "*.tmp\tTemporary files"
    "*.log\tLog files"
    "*.cache\tCache files"
    "*~\tBackup files"
    ".git/*\tGit repository"
    ".svn/*\tSVN repository"
    "node_modules/*\tNode modules"
    "__pycache__/*\tPython cache"
    "*.pyc\tPython bytecode"
    "*.class\tJava bytecode"
    ".DS_Store\tmacOS metadata"
    "Thumbs.db\tWindows thumbnails"
    "desktop.ini\tWindows desktop"
'

# Split size suggestions (compress command)
complete -c compress -n '__fish_seen_subcommand_from --split' -xa '
    "10M\t10 megabytes"
    "50M\t50 megabytes"
    "100M\t100 megabytes"
    "500M\t500 megabytes"
    "1G\t1 gigabyte"
    "2G\t2 gigabytes"
    "4G\t4 gigabytes"
'

# Context-aware completions for compress command
complete -c compress -n '__fish_seen_subcommand_from --format -F' -xa '
    backup.tar.zst
    archive.tar.xz
    compressed.zip
    backup.7z
    data.tar.gz
'

# Suggest appropriate compression levels based on format (compress command)
complete -c compress -n '__fish_contains_opt -s F format; and string match -q "*tar.xz*" (commandline -cp)' -s L -l level -xa '6\tDefault 9\tMaximum'
complete -c compress -n '__fish_contains_opt -s F format; and string match -q "*tar.zst*" (commandline -cp)' -s L -l level -xa '3\tFast 6\tDefault 19\tMaximum'
complete -c compress -n '__fish_contains_opt -s F format; and string match -q "*tar.gz*" (commandline -cp)' -s L -l level -xa '6\tDefault 9\tMaximum'
complete -c compress -n '__fish_contains_opt -s F format; and string match -q "*7z*" (commandline -cp)' -s L -l level -xa '5\tDefault 9\tUltra'

# Format selection for compressor command (alias)
complete -c compressor -s F -l format -x -a '(__fish_extractor_complete_formats)' -d 'Archive format'

# Basic options
complete -c compressor -s L -l level -x -a '1 2 3 4 5 6 7 8 9' -d 'Compression level (1=fast, 9=best)'
complete -c compressor -s t -l threads -x -a '(__fish_extractor_complete_threads)' -d 'Number of threads'
complete -c compressor -s e -l encrypt -d 'Enable encryption (zip/7z)'
complete -c compressor -s p -l password -r -d 'Encryption password'
complete -c compressor -s C -l chdir -r -F -d 'Change to directory before compressing'
complete -c compressor -s i -l include-glob -r -d 'Include pattern (can repeat)'
complete -c compressor -s x -l exclude-glob -r -d 'Exclude pattern (can repeat)'
complete -c compressor -s u -l update -d 'Update existing archive'
complete -c compressor -s a -l append -d 'Append to existing archive'
complete -c compressor -s q -l quiet -d 'Suppress non-error output'
complete -c compressor -s v -l verbose -d 'Enable verbose output'
complete -c compressor -l no-progress -d 'Disable progress indicators'
complete -c compressor -l smart -d 'Automatically choose best format'
complete -c compressor -l solid -d 'Create solid archive (7z only)'
complete -c compressor -l checksum -d 'Generate checksum file'
complete -c compressor -l split -r -d 'Split archive into parts (e.g., 100M, 1G)'
complete -c compressor -l dry-run -d 'Show what would be done'
complete -c compressor -s h -l help -d 'Display help message'

# Common glob patterns for include/exclude
complete -c compressor -n '__fish_seen_subcommand_from --include-glob -i' -xa '
    "*.txt\tText files"
    "*.log\tLog files"
    "*.md\tMarkdown files"
    "*.jpg\tJPEG images"
    "*.png\tPNG images"
    "*.pdf\tPDF files"
    "*.doc\tWord documents"
    "*.xls\tExcel files"
'

complete -c compressor -n '__fish_seen_subcommand_from --exclude-glob -x' -xa '
    "*.tmp\tTemporary files"
    "*.log\tLog files"
    "*.cache\tCache files"
    "*~\tBackup files"
    ".git/*\tGit repository"
    ".svn/*\tSVN repository"
    "node_modules/*\tNode modules"
    "__pycache__/*\tPython cache"
    "*.pyc\tPython bytecode"
    "*.class\tJava bytecode"
    ".DS_Store\tmacOS metadata"
    "Thumbs.db\tWindows thumbnails"
    "desktop.ini\tWindows desktop"
'

# Split size suggestions
complete -c compressor -n '__fish_seen_subcommand_from --split' -xa '
    "10M\t10 megabytes"
    "50M\t50 megabytes"
    "100M\t100 megabytes"
    "500M\t500 megabytes"
    "1G\t1 gigabyte"
    "2G\t2 gigabytes"
    "4G\t4 gigabytes"
'

# ============================================================================
# ext-doctor - Environment Diagnostics
# ============================================================================

complete -c ext-doctor -s v -l verbose -d 'Show detailed information'
complete -c ext-doctor -s q -l quiet -d 'Only show errors'
complete -c ext-doctor -l fix -d 'Suggest fixes for issues'
complete -c ext-doctor -l export -d 'Export diagnostic report'
complete -c ext-doctor -s h -l help -d 'Display help message'

# ============================================================================
# Context-Aware Completions
# ============================================================================

# For compressor, suggest common output filenames based on format
complete -c compressor -n '__fish_seen_subcommand_from --format -F' -xa '
    backup.tar.zst
    archive.tar.xz
    compressed.zip
    backup.7z
    data.tar.gz
'

# Suggest appropriate compression levels based on format
complete -c compressor -n '__fish_contains_opt -s F format; and string match -q "*tar.xz*" (commandline -cp)' -s L -l level -xa '6\tDefault 9\tMaximum'
complete -c compressor -n '__fish_contains_opt -s F format; and string match -q "*tar.zst*" (commandline -cp)' -s L -l level -xa '3\tFast 6\tDefault 19\tMaximum'
complete -c compressor -n '__fish_contains_opt -s F format; and string match -q "*tar.gz*" (commandline -cp)' -s L -l level -xa '6\tDefault 9\tMaximum'
complete -c compressor -n '__fish_contains_opt -s F format; and string match -q "*7z*" (commandline -cp)' -s L -l level -xa '5\tDefault 9\tUltra'
