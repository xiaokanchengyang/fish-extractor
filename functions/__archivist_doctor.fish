# Doctor command: archdoctor
# Performs preflight checks and reports capabilities.

function __archivist_doctor --description 'Check environment and required tools'
    set -l required file tar gzip xz zstd bzip2 lz4 unzip 7z bsdtar
    set -l optional unrar pv pigz pxz lbzip2 pbzip2 plzip

    echo "Archivist doctor:"
    for c in $required
        if command -qs $c
            __archivist__colorize green (printf '%-10s %s\n' $c OK)
        else
            __archivist__colorize red (printf '%-10s %s\n' $c MISSING)
        end
    end
    echo "Optional accelerators:"
    for c in $optional
        if command -qs $c
            __archivist__colorize cyan (printf '%-10s %s\n' $c available)
        else
            printf '%-10s %s\n' $c "-"
        end
    end

    echo "Configuration:"
    printf '  COLOR=%s\n' $ARCHIVIST_COLOR
    printf '  PROGRESS=%s\n' $ARCHIVIST_PROGRESS
    printf '  THREADS=%s\n' $ARCHIVIST_DEFAULT_THREADS
    printf '  SMART_LEVEL=%s\n' $ARCHIVIST_SMART_LEVEL
    printf '  LOG_LEVEL=%s\n' $ARCHIVIST_LOG_LEVEL
end
