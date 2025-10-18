# Common helpers for Archivist (fish 4.12+ syntax)
# Notes:
# - All user-facing messages use colors when ARCHIVIST_COLOR != 'never'
# - Progress bars use pv/rsync-like output when available, else fall back

function __archivist__supports_color --description 'Return 0 if colored output allowed'
    switch "$ARCHIVIST_COLOR"
        case never
            return 1
        case always
            return 0
        case auto '*'
            if isatty stdout
                return 0
            end
            return 1
    end
end

function __archivist__colorize --description 'Colorize message: usage: __archivist__colorize COLOR TEXT'
    set -l color $argv[1]
    set -l text  $argv[2..-1]
    if __archivist__supports_color
        set_color $color
        printf '%s' "$text"
        set_color normal
    else
        printf '%s' "$text"
    end
end

function __archivist__log --description 'Log with level and color'
    set -l level $argv[1]
    set -l msg   $argv[2..-1]
    set -l want (string lower -- $ARCHIVIST_LOG_LEVEL)
    set -l levels debug info warn error
    set -l idx_want (contains -i -- $want $levels; or echo 2)
    set -l idx_this (contains -i -- $level $levels; or echo 2)
    if test $idx_this -lt $idx_want
        return
    end
    switch $level
        case debug
            set -l c blue
        case info
            set -l c green
        case warn
            set -l c yellow
        case error
            set -l c red
        case '*'
            set -l c normal
    end
    if __archivist__supports_color
        set_color $c
        echo "[$level] $msg"
        set_color normal
    else
        echo "[$level] $msg"
    end
end

function __archivist__require_cmds --description 'Ensure required commands exist; prints missing and returns 1 if any missing'
    set -l missing
    for c in $argv
        if not command -qs $c
            set -a missing $c
        end
    end
    if test (count $missing) -gt 0
        __archivist__log error "Missing commands: $missing. Please install them."
        return 1
    end
end

function __archivist__can_progress --description 'Return 0 if we can show progress'
    switch "$ARCHIVIST_PROGRESS"
        case never
            return 1
        case always
            return 0
        case auto '*'
            if isatty stdout
                if command -qs pv
                    return 0
                end
            end
            return 1
    end
end

function __archivist__threads --description 'Resolve threads count'
    set -l t $ARCHIVIST_DEFAULT_THREADS
    if test -n "$argv[1]"; and test $argv[1] -gt 0
        set t $argv[1]
    end
    echo $t
end

function __archivist__ext --description 'Echo lowercase extension of file path'
    set -l f $argv[1]
    set -l base (basename -- $f)
    echo (string lower -- (string split -m1 -r . -- $base)[2])
end

function __archivist__mime --description 'Detect mime using file'
    if command -qs file
        file -b --mime-type -- $argv[1]
    end
end

function __archivist__spinner --description 'Show spinner while a PID runs: __archivist__spinner PID message'
    set -l pid $argv[1]
    set -l msg $argv[2..-1]
    if not isatty stdout
        wait $pid
        return $status
    end
    set -l frames '⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏'
    set -l i 1
    while kill -0 $pid 2>/dev/null
        printf "\r"
        __archivist__colorize cyan "$msg $frames[$i]"
        sleep 0.1
        set i (math 1 + $i)
        if test $i -gt (count $frames)
            set i 1
        end
    end
    printf "\r"
    return 0
end

function __archivist__parallel_map --description 'Run commands in parallel: __archivist__parallel_map THREADS CMD ...ARGS...; items via stdin'
    set -l threads (math max 1 (__archivist__threads $argv[1]))
    set -e argv[1]
    set -l cmd $argv
    set -l fifo (mktemp -u)
    mkfifo $fifo
    while read -l item
        echo $item >> $fifo &
        set -l active (jobs -p | wc -l)
        while test $active -ge $threads
            sleep 0.05
            set active (jobs -p | wc -l)
        end
        read -l token < $fifo
        eval $cmd -- $token &
    end
    wait
    rm -f $fifo
end

function __archivist__mktemp_dir --description 'Create temp dir and echo path'
    set -l d (mktemp -d 2>/dev/null; or mktemp -d -t archivist)
    echo $d
end

function __archivist__sanitize_path --description 'Expand ~ and make absolute'
    set -l p (string replace -r '^~' $HOME -- $argv[1])
    if not string match -q '/*' -- $p
        set p (realpath -m -- $p)
    end
    echo $p
end

function __archivist__default_outdir --description 'Compute default output directory for archive'
    set -l f $argv[1]
    set -l name (basename -- $f)
    set -l without (string replace -r '\\.(tar\\.(gz|bz2|xz|zst|lz|lz4|br)|t[gx]z|zip|7z|rar|xz|gz|bz2|zst|lz|lz4|br)$' '' -- $name)
    echo $without
end

function __archivist__smart_format --description 'Choose best compression format for inputs'
    # Simple heuristic: binary blobs -> zstd, text-heavy -> xz, mixed -> gz
    set -l total 0
    set -l textlike 0
    for f in $argv
        if test -d $f
            continue
        end
        set -l mime (__archivist__mime $f)
        if string match -q 'text/*' -- $mime
            set textlike (math $textlike + 1)
        else if string match -q '*json' -- $mime
            set textlike (math $textlike + 1)
        end
        set total (math $total + 1)
    end
    if test $total -eq 0
        echo zstd
        return
    end
    set -l ratio (math -s0 (math $textlike \* 100 / $total))
    if test $ratio -gt 70
        echo xz
    else if test $ratio -gt 40
        echo gz
    else
        echo zstd
    end
end
