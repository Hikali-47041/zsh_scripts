#!/bin/bash

# 日付指定日記選択スクリプト

# usage: zsh edit.zsh 2025-04-09
# default editor is vim. if you want to use other editor,
#  : EDITOR=nano zsh edit.zsh 2025-01-31

debug=false
auto_create=true
editor="${EDITOR:-vim}"
day="$(date -I -d "${1:-today}")"
filepath="./${day%%-*}/${day%-*}/$day.md"
create_script="./create_loop.zsh"
script_args="(-s $day -e $day)"
"$debug" && print "[debug] editor= $editor, day = $day, filepath = $filepath"

if [ "$auto_create" ] && [ ! -e "$filepath" ]; then
    "$debug" && print "[debug] file is not found. so creating: $filepath"
    if [ -e "$create_script" ]; then
        "$debug" && print "[debug] running: $create_script $filepath"
        source "$create_script" "$script_args"
    else
        print -P "%F{009}[error] $create_script is not found."
    fi
fi

day="$(date -I -d "${1:-today}")"
filepath="./${day%%-*}/${day%-*}/$day.md"
"$debug" && print "[debug] Command: $editor $filepath"
# run
$editor "$filepath"
