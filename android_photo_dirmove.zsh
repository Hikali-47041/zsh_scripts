#!/bin/zsh

# スマホ用フォト移動スクリプト

# TODO 最終ファイル引数をとりたい(バリデーションもしたい)
# TODO forループを削減したい -> 配列化してまとめて移動 関数呼び出しは1回にするといいかも

# - - - - - - - - - - - - - - -
# paths path -> status(void)
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
    #         && print -P "%F{011}[warning] $srcfile is already exists in $destdir/$srcfile, skip %f" >&2
    # done
    if $dry_run; then
        print -P "%F{010}[dry-run] mv $srcfiles $destdir%f" >&2
    else
        $verbose && print -P "%F{012}[info] mv $srcfiles $destdir%f" >&2
        mv -n $srcfiles "$destdir"
    fi
}

# - - - - - - - - - - - - - - -
verbose=false
dry_run=false
$verbose && print -P "%F{012}[info] dry-run = $dry_run %f" >&2

args=("$@")

if [ -z "${args[1]}" ]; then
    print -P "%F{009}[error] src is not set" >&2
    exit 126
elif [ -f "${args[-1]}" ]; then
    destroot="$PWD"
    index_end=-1
else
    destroot="${args[-1]}"
    index_end=-2
fi

$verbose && print -P "%F{012}[info] src = ${args[1,index_end]} %f" >&2
$verbose && print -P "%F{012}[info] destroot = $destroot %f" >&2

for src in ${args[1,index_end]}; do
    # skip if $srd is directory
    if [ -d "$src" ]; then
        $verbose && print -P "%F{012}[info] $src is directory, skipping %f" >&2
        continue
    fi

    photo_date="${${src#*_}%%_*}"
    year="${photo_date:0:4}"
    month="${photo_date:4:2}"
    # validation
    if ([[ "$year" =~ [0-9]{4} ]] && [[ "$month" =~ [0-9]{2} ]]); then
        destdir="$destroot/$year/$year-$month/"
        move_file_mkdir_dest "$src" "$destdir"
    else
        print -P "%F{011}[warning] $src is not prefix_YYYYMMDD_suffix format %f"
    fi
done
