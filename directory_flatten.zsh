#!/bin/zsh


dir_recursive_process() {
    local dir="$1"
    # ディレクトリ内のすべてのエントリをループ
    for entry in "$dir"/*; do
        if [ -d $entry ]; then
            $debug && print -P "%F{012}[debug] Directory: $entry%f" >&2
            # エントリがディレクトリの場合、再帰的に呼び出す
            dir_recursive_process "$entry"
        elif [ -f $entry ]; then
            $debug && print -P "%F{012}[debug] file: $entry%f" >&2
            # エントリがファイルの場合、処理を行う
            move_file "$entry"
        fi
    done
}

# move file
move_file() {
    local srcfile="$1"
    if $dry_run_flag; then
        print -P "%F{010}[dry-run] mv $srcfile $destroot%f" >&2
    else
        $debug && print -P "%F{012}[debug] mv $srcfile $destroot%f" >&2
        mv -u "$srcfile" "$destroot"
    fi
}

# TODO get path
debug=false

dry_run_flag=false
$debug && print -P "%F{012}[debug] dry-run = $dry_run_flag %f" >&2

src="${1:-$PWD}"
$debug && print -P "%F{012}[debug] src = $src %f" >&2

destroot="${2:-$PWD}"
$debug && print -P "%F{012}[debug] destroot = $destroot %f" >&2

# file or directory detection
if [ -f "$src" ]; then
    $debug && print -P "%F{012}[debug] $src is file%f" >&2
    copy_file "$src"
else
    $debug && print -P "%F{012}[debug] $src is directory%f" >&2
    dir_recursive_process "$src"
fi

