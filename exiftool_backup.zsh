#!/bin/zsh
# Exif 情報をもとに画像を仕分けするスクリプト
# TODO スペースを含むファイル/ディレクトリの処理

# functions
# 再帰的にファイルを処理する関数
dir_recursive_process() {
    local args=("$@")
    local dirpath="${args[1]}"
    # ディレクトリ内のすべてのエントリをループ
    # TODO -e dirpath, emptydir
    if [ -f "$dirpath" ]; then
        $verbose && print -P "%F{012}[info] file: $dirpath%f" >&2
        drp_file_process "$dirpath" ${args[2,-1]}
    elif [ -n "$(print -rl -- "$dirpath"/*(N))" ]; then
        for entry in "$dirpath"/*; do
            if [ -f "$entry" ]; then
                # エントリがファイルの場合、処理を行う
                $verbose && print -P "%F{012}[info] file: $entry%f" >&2
                drp_file_process "$entry" ${args[2, -1]}
            elif [ -d "$entry" ]; then
                # エントリがディレクトリの場合、再帰的に呼び出す
                $verbose && print -P "%F{012}[info] Directory: $entry%f" >&2
                dir_recursive_process "$entry" ${args[2, -1]}
            fi
        done
    else
        $verbose && print -P "%F{012}[info] Directory: $entry is empty%f" >&2
    fi
}

# 再帰基底の処理をする関数
drp_file_process() {
    local args=("$@")
    exifdate="$(get_exifdate ${args[1]})"
    if [ "$exifdate" ]; then
        destpath="${args[2]}/${exifdate%%-*}/${exifdate%-*}"
        move_file_mkdir_dest "${args[1]}" "$destpath"
    else
        $verbose && print -P "%F{012}[info] skip mv: ${args[1]} %f" >&2
    fi
}

# dirpath: $1 -> str: ISO8601 Date
# requried: exiftool
get_exifdate() {
    local srcfile="$1"
    # get srcfile exifdate (need exiftool)
    exifdate=${$(exiftool -b -DateTimeOriginal $srcfile)[1]//:/-}
    # exifdate="2023-04-01"
    $verbose && print -P "%F{012}[info] exifdate = $exifdate%f" >&2
    # varidation
    [ "$exifdate" ] \
        && print "$exifdate" \
        || print -P "%F{011}[warning] exif data is not found in $srcfile %f" >&2
}

# dirpaths dirpath -> status(void)
# mkdir $-1 + mv $1..-2 $-1
move_file_mkdir_dest() {
    local args=("$@")
    local srcfiles=${args[1,-2]}
    local destdir="${args[-1]}"
    # mkdir if destdir is not exist
    if [ ! -d "$destdir" ]; then
        $verbose && print -P "%F{012}[info] mkdir $destdir%f" >&2
        $dry_run \
            && print -P "%F{010}[dry-run] mkdir -p $destdir" >&2 \
            || mkdir -p "$destdir"
    fi
    # move file
    # for srcfile in $srcfiles; do
    #     [ -e "$destdir/$srcfile" ] \
    #        && print -P "%F{011}[warning] $srcfile is already exists in $destdir, skip %f" >&2
    # done
    if $dry_run; then
        print -P "%F{010}[dry-run] mv $srcfiles $destdir%f" >&2
    else
        $verbose && print -P "%F{012}[info] mv $srcfiles $destdir%f" >&2
        mv -n $srcfiles "$destdir"
    fi
}


# - - - - - - - - - - - - - - - -
verbose=false
dry_run=false
$verbose && print -P "%F{012}[info] dry-run = $dry_run %f" >&2

# check exiftool installed
if ! type exiftool > /dev/null 2>&1; then
    print -P "%F{009}[error] exiftool is not found %f" >&2
    exit 127
fi

src="$1"
if [ -z "$1" ]; then
    print -P "%F{009}[error] src = $src is not set" >&2
    exit 126
fi
$verbose && print -P "%F{012}[info] src = $src %f" >&2

destroot="${2:-/mnt/pictures/photos}"
$verbose && print -P "%F{012}[info] destroot = $destroot %f" >&2

# file or directory detection
dir_recursive_process "$src" "$destroot"

