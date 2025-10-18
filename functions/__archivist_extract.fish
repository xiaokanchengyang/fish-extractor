# Extraction command: archx
# Supports many formats with smart detection, progress, and options.

function __archivist_extract --description 'Extract archives with smart detection and progress'
    set -l usage "archx - Extract archives\n\nUsage: archx [OPTIONS] FILE...\n\nOptions:\n  -d, --dest DIR          Destination directory (default: derived from archive)\n  -f, --force             Overwrite existing files without prompt\n  -s, --strip NUM         Strip NUM leading components (tar-like)\n  -p, --password PASS     Password for encrypted archives\n  -t, --threads N         Parallelism for multi-part or multi-files\n  -q, --quiet             Reduce output verbosity\n      --no-progress       Disable progress display\n      --list              List archive contents only\n      --dry-run           Show what would happen\n      --help              Show this help\n\nExamples:\n  archx file.zip\n  archx -d ./out file.tar.gz\n  archx --strip 1 src.tar.xz\n  archx -p secret enc.7z\n"

    set -l dest ''
    set -l force 0
    set -l strip 0
    set -l password ''
    set -l threads ''
    set -l quiet 0
    set -l list_only 0
    set -l dry_run 0

    argparse -i 'd/dest=' 'f/force' 's/strip=' 'p/password=' 't/threads=' 'q/quiet' 'no-progress' 'list' 'dry-run' 'help' -- $argv
    or begin
        __archivist__log error "Argument parsing failed"
        echo $usage
        return 2
    end

    if set -q _flag_help
        echo $usage
        return 0
    end
    set -q _flag_dest; and set dest (__archivist__sanitize_path $_flag_dest)
    set -q _flag_force; and set force 1
    set -q _flag_strip; and set strip $_flag_strip
    set -q _flag_password; and set password $_flag_password
    set -q _flag_threads; and set threads $_flag_threads
    set -q _flag_quiet; and set quiet 1
    set -q _flag_list; and set list_only 1
    set -q _flag_dry_run; and set dry_run 1

    set -l files $argv
    if test (count $files) -eq 0
        echo $usage
        return 2
    end

    # Preflight: core tools
    __archivist__require_cmds file iconv
    or return 127

    set -l t (test -n "$threads"; and echo $threads; or echo $ARCHIVIST_DEFAULT_THREADS)

    # Parallel over files
    for f in $files
        set -l abs (__archivist__sanitize_path $f)
        if not test -e $abs
            __archivist__log error "Not found: $f"
            continue
        end
        set -l outdir $dest
        if test -z "$outdir"
            set outdir (__archivist__default_outdir $abs)
        end
        set outdir (__archivist__sanitize_path $outdir)
        if test $dry_run -eq 1
            __archivist__log info "[DRY] Would extract $abs -> $outdir"
            continue
        end
        mkdir -p -- $outdir
        or begin
            __archivist__log error "Cannot create $outdir"
            continue
        end

        set -l mime (__archivist__mime $abs)
        set -l ext (__archivist__ext $abs)

        # Determine extractor and args
        set -l cmd
        set -l args
        set -l listargs

        switch $ext
            case zip
                __archivist__require_cmds unzip
                or continue
                set cmd unzip
                if test $list_only -eq 1
                    set listargs -l
                else
                    set -a args -d $outdir
                    test $force -eq 1; and set -a args -o
                    test -n "$password"; and set -a args -P "$password"
                end
                set -a args -- "$abs"
            case 7z 7zip
                __archivist__require_cmds 7z
                or continue
                set cmd 7z
                if test $list_only -eq 1
                    set listargs l -- "$abs"
                else
                    set args x -y -o"$outdir"
                    test -n "$password"; and set -a args -p"$password"
                    set -a args -- "$abs"
                end
            case rar r00
                __archivist__require_cmds unrar
                or begin
                    __archivist__log warn "unrar missing; trying bsdtar"
                    __archivist__require_cmds bsdtar; or continue
                    set cmd bsdtar
                    if test $list_only -eq 1
                        set listargs -tf -- "$abs"
                    else
                        set args -xpf --no-same-owner -C "$outdir" -- "$abs"
                    end
                    break
                end
                set cmd unrar
                if test $list_only -eq 1
                    set listargs l -- "$abs"
                else
                    set args x -o+ -idq -inul -y
                    test -n "$password"; and set -a args -p"$password"
                    set -a args -- "$abs" "$outdir"
                end
            case gz tgz tar.gz
                __archivist__require_cmds tar
                or continue
                set cmd tar
                if test $list_only -eq 1
                    set listargs -tzf -- "$abs"
                else
                    set args -xzf --strip-components=$strip -C "$outdir" -- "$abs"
                end
            case bz2 tbz2 tar.bz2
                __archivist__require_cmds tar
                or continue
                set cmd tar
                if test $list_only -eq 1
                    set listargs -tjf -- "$abs"
                else
                    set args -xjf --strip-components=$strip -C "$outdir" -- "$abs"
                end
            case xz txz tar.xz
                __archivist__require_cmds tar
                or continue
                set cmd tar
                if test $list_only -eq 1
                    set listargs -tJf -- "$abs"
                else
                    set args -xJf --strip-components=$strip -C "$outdir" -- "$abs"
                end
            case zst tzst tar.zst
                __archivist__require_cmds tar
                or continue
                set cmd tar
                if test $list_only -eq 1
                    set listargs --zstd -tf -- "$abs"
                else
                    set args --zstd -xpf --strip-components=$strip -C "$outdir" -- "$abs"
                end
            case lz4 tlz4 tar.lz4
                __archivist__require_cmds tar
                or continue
                set cmd tar
                if test $list_only -eq 1
                    set listargs --lz4 -tf -- "$abs"
                else
                    set args --lz4 -xpf --strip-components=$strip -C "$outdir" -- "$abs"
                end
            case lz tlz tar.lz
                __archivist__require_cmds tar
                or continue
                set cmd tar
                if test $list_only -eq 1
                    set listargs --lzip -tf -- "$abs"
                else
                    set args --lzip -xpf --strip-components=$strip -C "$outdir" -- "$abs"
                end
            case br tbr tar.br
                __archivist__require_cmds tar
                or continue
                set cmd tar
                if test $list_only -eq 1
                    set listargs --use-compress-program=pbzip2 -tf -- "$abs"
                else
                    set args --use-compress-program=pbzip2 -xpf --strip-components=$strip -C "$outdir" -- "$abs"
                end
            case tar
                __archivist__require_cmds tar
                or continue
                set cmd tar
                if test $list_only -eq 1
                    set listargs -tf -- "$abs"
                else
                    set args -xpf --strip-components=$strip -C "$outdir" -- "$abs"
                end
            case iso
                __archivist__require_cmds bsdtar
                or continue
                set cmd bsdtar
                if test $list_only -eq 1
                    set listargs -tf -- "$abs"
                else
                    set args -xpf -C "$outdir" -- "$abs"
                end
            case '*'
                # Try bsdtar auto
                if command -qs bsdtar
                    set cmd bsdtar
                    if test $list_only -eq 1
                        set listargs -tf -- "$abs"
                    else
                        set args -xpf -C "$outdir" -- "$abs"
                    end
                else if command -qs 7z
                    set cmd 7z
                    if test $list_only -eq 1
                        set listargs l -- "$abs"
                    else
                        set args x -y -o"$outdir" -- "$abs"
                    end
                else
                    __archivist__log error "Unsupported archive: $f"
                    continue
                end
        end

        if test $list_only -eq 1
            __archivist__log info "Listing $abs"
            eval $cmd $listargs
            set -l s $status
            if test $s -ne 0
                __archivist__log error "List failed ($s) for $f"
            end
            continue
        end

        set -l runline "$cmd $args"
        __archivist__log info "Extracting $abs -> $outdir"
        if __archivist__can_progress; and test $cmd = tar; and command -qs pv
            set -l size (stat -c %s -- "$abs" 2>/dev/null)
            if test -n "$size"; and test $size -gt 0
                if string match -q '*zstd*' -- "$args"
                    pv -s $size "$abs" | tar -x -C "$outdir" --strip-components=$strip --zstd -f -
                else if string match -q '*J*' -- "$args"
                    pv -s $size "$abs" | tar -x -C "$outdir" --strip-components=$strip -J -f -
                else if string match -q '*z*' -- "$args"
                    pv -s $size "$abs" | tar -x -C "$outdir" --strip-components=$strip -z -f -
                else
                    pv -s $size "$abs" | tar -x -C "$outdir" --strip-components=$strip -f -
                end
                set -l s $status
                if test $s -ne 0
                    __archivist__log error "Extraction failed ($s) for $f"
                end
                continue
            end
        end
        eval $runline
        set -l s $status
        if test $s -ne 0
            __archivist__log error "Extraction failed ($s) for $f"
        else if test $quiet -eq 0
            __archivist__colorize green "Done: $f -> $outdir\n"
        end
    end
end
