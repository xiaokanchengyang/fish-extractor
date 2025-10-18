# Compression command: archc
# Create archives with smart format selection and options.

function __archivist_compress --description 'Create archives with smart selection and threads'
    set -l usage "archc - Create archives\n\nUsage: archc [OPTIONS] OUTPUT [INPUT ...]\n\nOptions:\n  -F, --format FMT        Format: auto|zip|7z|tar.gz|tar.xz|tar.zst|tar.bz2|tar.lz4|tar\n  -L, --level N           Compression level (1-19 depending on fmt)\n  -t, --threads N         Threads for compressors that support it\n  -e, --encrypt           Enable encryption if supported (zip/7z)\n  -p, --password PASS     Password for encryption (prompt if missing)\n  -C, --chdir DIR         Change to directory before adding inputs\n  -i, --include-glob G    Include only paths matching glob (repeatable)\n  -x, --exclude-glob G    Exclude paths matching glob (repeatable)\n  -q, --quiet             Reduce output verbosity\n      --no-progress       Disable progress display\n      --smart             Choose best format automatically\n      --dry-run           Show what would happen\n      --help              Show this help\n\nExamples:\n  archc out.tar.zst folder\n  archc -F zip out.zip file1 dir2\n  archc --smart out.auto src/*\n"

    set -l format auto
    set -l level ''
    set -l threads ''
    set -l encrypt 0
    set -l password ''
    set -l chdir ''
    set -l inc_globs
    set -l exc_globs
    set -l quiet 0
    set -l smart 0
    set -l dry_run 0

    argparse -i 'F/format=' 'L/level=' 't/threads=' 'e/encrypt' 'p/password=' 'C/chdir=' 'i/include-glob=' 'x/exclude-glob=' 'q/quiet' 'no-progress' 'smart' 'dry-run' 'help' -- $argv
    or begin
        __archivist__log error "Argument parsing failed"
        echo $usage
        return 2
    end

    if set -q _flag_help
        echo $usage
        return 0
    end

    set -q _flag_format; and set format (string lower -- $_flag_format)
    set -q _flag_level; and set level $_flag_level
    set -q _flag_threads; and set threads $_flag_threads
    set -q _flag_encrypt; and set encrypt 1
    set -q _flag_password; and set password $_flag_password
    set -q _flag_chdir; and set chdir (__archivist__sanitize_path $_flag_chdir)
    set -q _flag_include_glob; and set inc_globs $_flag_include_glob
    set -q _flag_exclude_glob; and set exc_globs $_flag_exclude_glob
    set -q _flag_quiet; and set quiet 1
    set -q _flag_smart; and set smart 1
    set -q _flag_dry_run; and set dry_run 1

    if test (count $argv) -lt 1
        echo $usage
        return 2
    end
    set -l output (__archivist__sanitize_path $argv[1])
    set -l inputs $argv[2..-1]
    if test (count $inputs) -eq 0
        set inputs .
    end

    if test $smart -eq 1; or test $format = auto
        set -l guess (__archivist__smart_format $inputs)
        switch $guess
            case xz
                set format tar.xz
            case gz
                set format tar.gz
            case zstd
                set format tar.zst
        end
        __archivist__log info "Smart format: $format"
    end

    set -l t (test -n "$threads"; and echo $threads; or echo $ARCHIVIST_DEFAULT_THREADS)

    set -l run_cmd
    set -l run_args

    if test -n "$chdir"; and not test -d $chdir
        __archivist__log error "Not a directory: $chdir"
        return 1
    end

    # Build file list respecting includes/excludes
    set -l files
    if test -n "$chdir"
        pushd $chdir >/dev/null
    end
    for i in $inputs
        if test -e $i
            set -a files $i
        else
            for m in (eval echo $i)
                if test -e $m
                    set -a files $m
                end
            end
        end
    end

    if test (count $inc_globs) -gt 0
        set -l selected
        for g in $inc_globs
            for f in $files
                if string match -q -- $g $f
                    set -a selected $f
                end
            end
        end
        set files (printf '%s\n' $selected | sort -u)
    end
    if test (count $exc_globs) -gt 0
        set -l kept
        for f in $files
            set -l drop 0
            for g in $exc_globs
                if string match -q -- $g $f
                    set drop 1
                    break
                end
            end
            if test $drop -eq 0
                set -a kept $f
            end
        end
        set files $kept
    end

    if test -n "$chdir"
        popd >/dev/null
    end

    if test (count $files) -eq 0
        __archivist__log warn "No input files"
        return 1
    end

    switch $format
        case zip
            __archivist__require_cmds zip
            or return 127
            set run_cmd zip
            set run_args -r
            test -n "$level"; and set -a run_args -$level
            if test $encrypt -eq 1
                set -a run_args -e
                if test -n "$password"
                    set -x ZIPOPT "-P $password"
                end
            end
            set -a run_args "$output" $files
        case 7z 7zip
            __archivist__require_cmds 7z
            or return 127
            set run_cmd 7z
            set run_args a -y
            test -n "$level"; and set -a run_args -mx=$level
            test $encrypt -eq 1; and set -a run_args -mhe=on
            test -n "$password"; and set -a run_args -p"$password"
            set -a run_args "$output" $files
        case tar.gz
            __archivist__require_cmds tar gzip
            or return 127
            set run_cmd tar
            set -l gzlvl (test -n "$level"; and echo $level; or echo 6)
            set -l comp "--use-compress-program=gzip -$gzlvl"
            set -l prog "gzip -$gzlvl"
            if __archivist__can_progress; and command -qs pv
                set run_args -c $files ^| pv ^| $prog ^> "$output"
            else
                set run_args -czf "$output" $files
            end
        case tar.xz
            __archivist__require_cmds tar xz
            or return 127
            set run_cmd tar
            set -l xzlvl (test -n "$level"; and echo $level; or echo 6)
            set -l threads_flag (test -n "$threads"; and echo "-T $threads")
            set -l prog "xz -$xzlvl $threads_flag"
            if __archivist__can_progress; and command -qs pv
                set run_args -c $files ^| pv ^| $prog ^> "$output"
            else
                set run_args -c $files ^| $prog ^> "$output"
            end
        case tar.zst
            __archivist__require_cmds tar zstd
            or return 127
            set run_cmd tar
            set -l zstlvl (test -n "$level"; and echo $level; or echo 6)
            set -l threads_flag (test -n "$threads"; and echo "-T$threads")
            set -l prog "zstd -$zstlvl $threads_flag -q"
            if __archivist__can_progress; and command -qs pv
                set run_args -c $files ^| pv ^| $prog ^-o "$output"
            else
                set run_args -c $files ^| $prog ^-o "$output"
            end
        case tar.bz2
            __archivist__require_cmds tar bzip2
            or return 127
            set run_cmd tar
            set -l bzlvl (test -n "$level"; and echo $level; or echo 6)
            set -l prog "bzip2 -$bzlvl"
            if __archivist__can_progress; and command -qs pv
                set run_args -c $files ^| pv ^| $prog ^> "$output"
            else
                set run_args -c $files ^| $prog ^> "$output"
            end
        case tar.lz4
            __archivist__require_cmds tar lz4
            or return 127
            set run_cmd tar
            set -l lz4lvl (test -n "$level"; and echo $level; or echo 6)
            set -l threads_flag (test -n "$threads"; and echo "-T$threads")
            set -l prog "lz4 -$lz4lvl $threads_flag -q"
            if __archivist__can_progress; and command -qs pv
                set run_args -c $files ^| pv ^| $prog ^-o "$output"
            else
                set run_args -c $files ^| $prog ^-o "$output"
            end
        case tar
            __archivist__require_cmds tar
            or return 127
            set run_cmd tar
            set run_args -cpf "$output" $files
        case '*'
            __archivist__log error "Unsupported format: $format"
            return 2
    end

    if test $dry_run -eq 1
        __archivist__log info "[DRY] Would run: $run_cmd $run_args"
        return 0
    end

    __archivist__log info "Creating $output"

    if test $run_cmd = tar
        # Build the pipeline using eval to honor carets as pipes
        set -l cmdline (string replace -a '^|' '|' -- "$run_args")
        eval $run_cmd $cmdline
    else
        eval $run_cmd $run_args
    end

    set -l s $status
    if test $s -ne 0
        __archivist__log error "Creation failed ($s)"
        return $s
    end

    if test $quiet -eq 0
        __archivist__colorize green "Done: $output\n"
    end
end
