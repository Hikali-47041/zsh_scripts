#!/bin/zsh

print -Pn "    | "

for bg_color in {0..15}
do
    print -Pn " %K{$bg_color}%F{default} ${(l:2::0:)bg_color} %f%k "
done
print -P "\n----+-------------------------------------------------------------------------------------------------"

for fg_color in {0..15}
do
    print -Pn " %F{$fg_color}${(l:2::0:)fg_color} %f| " 
    for bg_color in {0..15}
    do
        print -Pn "%F{$fg_color}%K{$bg_color} ${(l:2::0:)fg_color}${(l:2::0:)bg_color} %f%k"
    done
    print ""
done
