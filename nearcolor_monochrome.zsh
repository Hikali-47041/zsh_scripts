#!/bin/zsh

# ref: https://en.wikipedia.org/wiki/ANSI_escape_code#8-bit
# TODO: magic number

debug=false

for arg in "$@"; do
    # convert #rrggbb -> rrggbb
    arg="${arg#\#}"
    # convert rgb -> rrggbb
    if [ "${#arg}" -eq 3 ]; then 
        arg="#${arg:0:1}${arg:0:1}${arg:1:1}${arg:1:1}${arg:2:1}${arg:2:1}"
        $debug && print "[debug] arg=$arg" >&2
    fi

    # print argument color
    print -Pn "%K{#$arg}    %k %F{#$arg}#$arg%f "

    # create #rrggbb -> rgb(R, G, B)
    rgb=("$((0x${arg:0:2}))" "$((0x${arg:2:2}))" "$((0x${arg:4:2}))")
    $debug && print "\n[debug] rgb=$rgb" >&2

    # get "value = max(R, G, B)"
    value="$rgb[1]"
    value="$(($value < $rgb[2] ? $rgb[2] : $value))"
    value="$(($value < $rgb[3] ? $rgb[3] : $value))"
    $debug && print "[debug] value=$value" >&2

    # n :: index
    # n <= 0 -> 016-231 216 colors
    # n >  0 -> 232-255 grayscale colors (shift +1)
    # "darker than #040404 [#000000 - #030303] => #000000"
    if [ "$value" -lt 4 ]; then
        n=0
    else
    # value < 92  -> n, value < 97  -> m, value < 132 -> n,..., value < 217 -> m
        for i in {1..8}; do
            # 92, 97, 132, ..., 217 :: grayscale colors
            if [ "$value" -le "$(((40 * $i - 15 * (-1) ** $i + 129) / 2))" ]; then
                n="$(( $i % 2 ? ($value - 3) / 10 + 1 : (35 - $value) / 40))"
                break
            fi
            # 217 <= value < 247  -> n : 247 <= value <= 255  -> m
            n="$(($value < 4 ? 0 : $value < 247 ? ($value - 3) / 10 + 1 : -5))"
        done
    fi
    $debug && print "[debug] n=$n" >&2

    # index -> num, hex
    num="${(l:3::0:)$(($n > 0 ? 231 + $n : 16 - 43 * $n))}"
    hex="${(l:2::0:)$(($n > 0 ? [##16] ($n - 1) * 10 + 8 : $n ? [##16]  $n * -40 + 55 : 0))}"
    $debug && print "[debug] num=$num\n[debug] hex=$hex" >&2

    # print nearest color
    print -P "%K{#$hex$hex$hex}    %k %F{#$hex$hex$hex}#$hex$hex$hex %f $num"
done
