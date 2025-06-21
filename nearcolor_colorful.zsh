#!/bin/zsh

# ref: https://en.wikipedia.org/wiki/ANSI_escape_code#8-bit
# TODO: magicnumber

debug=false
# warp_level [0..3]
warp_level=2

for arg in "$@"; do
    # convert #rrggbb -> rrggbb
    arg="${arg#\#}"
    # error if $arg is not hex color
    # if [[ "$arg" =~ ^#?([\da-fA-F]{6}|[\da-fA-F]{3})$ ]]; then
    #     print "Error: $arg is not rrggbb or rgb" 
    #    exit 1
    # fi
    # convert rgb -> rrggbb
    if [ "${#arg}" -eq 3 ]; then 
        arg="${arg:0:1}${arg:0:1}${arg:1:1}${arg:1:1}${arg:2:1}${arg:2:1}"
        $debug && print "[debug] arg=$arg" >&2
    fi

    # print argument color
    print -Pn "%K{#$arg}    %k %F{#$arg}#$arg%f "

    # create #rrggbb -> rgb(R, G, B)
    rgb=("$((0x${arg:0:2}))" "$((0x${arg:2:2}))" "$((0x${arg:4:2}))")
    $debug && print "\n[debug] rgb=$rgb" >&2

    # R, G, B -> c = 40 * n + 55
    nchex=""
    ncl=()
    cp_n=()
    for c in "$rgb[@]"; do
        # (75) <-(-20)- 95 <-(+-20)-> (115) <-> 135 <-> (155) <-> 175 <-> ... <-> 255
        # 75, 115, 155, 195, 235 :: generalization => 40m + 35
        # c < 75 -> 00
        ncl+=("$(($c < 75 ? 0 : ($c - 35) / 40))")
        # 55 = 35 + 40 / 2
        nchex+="${(l:2::0:)$(([##16] $c < 75 ? 0 : ($c - 35) / 40 * 40 + 55))}"
        # c < 55 -> c = 55, c > 215 -> c = 215
        c_padding_n="$(($c < 55 ? 55 : $c > 215 ? 215 : $c))"
        cp_n+=("$((($c_padding_n - 55) / 40))" "$((($c_padding_n - 55) / 40 + 1))")
    done
    debug && print "[debug] nchex=$nchex\n[debug] cp_n=$cp_n" >&2

    # show nearest color
    # number = 16 + 36 * R + 6 * G + B
    print -P "==>  %K{#$nchex}    %k %F{#$nchex}#$nchex ${(l:3::0:)$(( 16 + 36 * $ncl[1] + 6 * $ncl[2] + $ncl[3] ))}%f"

    # show near color pallete
    for r in ${cp_n:0:$((${#cp_n}/3))}; do
        hex_r="$(($r ? [##16] $r * 40 + 55 : 0))"
        for g in ${cp_n:$((${#cp_n}/3)):$((${#cp_n}/3))}; do
            hex_g="$(($g ? [##16] $g * 40 + 55 : 0))"
            for b in ${cp_n:$((${#cp_n}/3 * 2)):$((${#cp_n}/3))}; do
                hex_b="$(($b ? [##16] $b * 40 + 55 : 0))"
                hex="${(l:2::0:)hex_r}${(l:2::0:)hex_g}${(l:2::0:)hex_b}"
                print -Pn "%K{#$hex}    %k %F{#$hex}#$hex%f ${(l:3::0:)$(( 16 + 36 * $r + 6 * $g + $b ))}  "
                [ "$warp_level" -eq 3 ] && print ""
            done
            [ "$warp_level" -eq 2 ] && print ""
        done
        [ "$warp_level" -eq 1 ] && print ""
    done
    print ""

    # show near color pallete 2
    # count=0
    # for r in ${cp_n:0:$((${#cp_n}/3))}; do
    #     hex_r="$(($r ? [##16] $r * 40 + 55 : 0))"
    #     for g in ${cp_n:$((${#cp_n}/3)):$((${#cp_n}/3))}; do
    #         hex_g="$(($g ? [##16] $g * 40 + 55 : 0))"
    #         for b in ${cp_n:$((${#cp_n}/3 * 2)):$((${#cp_n}/3))}; do
    #             hex_b="$(($b ? [##16] $b * 40 + 55 : 0))"
    #             hex="${(l:2::0:)hex_r}${(l:2::0:)hex_g}${(l:2::0:)hex_b}"
    #             print -Pn "%K{#$hex}  %k"
    #             count="$(($count + 1))"
    #             if [ "$count" -eq 4 ]; then
    #                 print -Pn "%K{#$arg}  %k"
    #                 count="$(($count + 1))"
    #             elif [ $(("$count" % 3)) -eq 0 ]; then
    #                 print ""
    #             fi
    #         done
    #     done
    # done
    # print ""
done
