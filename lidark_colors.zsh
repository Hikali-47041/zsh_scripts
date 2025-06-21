#!/bin/zsh

nc_t=(31363b c6344a 00c944 f15a22 1793d1 a460c7 04bac5 bdc3c7)
nc_a=(3a3a3a d7005f 00af5f ff5f00 0087d7 af5fd7 00afaf c6c6c6)

bc_t=(6b757f e974a3 2cde85 ffac33 3daee9 bb77ff 99d9e8 eff0f1)
bc_a=(808080 ff5faf 00D787 ffaf5f 00afff af87ff 87d7ff eeeeee)

ac_t=(232629 de565d 71a144 ffdb3b 4c7de3 a05b7d 64e9db a7b1ba)
ac_a=(262626 ff005f 5f8700 ffd700 5f87d7 af5f87 5fd7d7 bcbcbc)

fc_t=(3b4045 fea3c4 b4de69 ffe794 5dadec 8e6ae8 76a1ac fcfcfc)
fc_a=(444444 ffafd7 afd75f ffd787 5fafff 875fff 87afaf ffffff)

for i in {1..8}; do
    print -Pn "%F{#$nc_t[i]}#$nc_t[i]%f %K{#$nc_t[i]}    %k"
    print -Pn "%K{#$nc_a[i]}    %k %F{#$nc_a[i]}#$nc_a[i]%f "
    print -Pn "%F{#$ac_t[i]}#$ac_t[i]%f %K{#$ac_t[i]}    %k"
    print -Pn "%K{#$ac_t[i]}    %k %F{#$ac_a[i]}#$ac_a[i]%f "
    print -Pn "%F{#$bc_t[i]}#$bc_t[i]%f %K{#$bc_t[i]}    %k"
    print -Pn "%K{#$bc_a[i]}    %k %F{#$bc_a[i]}#$bc_a[i]%f "
    print -Pn "%F{#$fc_t[i]}#$fc_t[i]%f %K{#$fc_t[i]}    %k"
    print -P  "%K{#$fc_t[i]}    %k %F{#$fc_a[i]}#$fc_a[i]%f"
done
