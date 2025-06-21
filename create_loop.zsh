#!/bin/sh

## 定数変数
template='template.md'
startdate=$(date -I -d "30 days ago")
enddate=$(date -I)
verbose=false

# year=${day%%-*}
# year-month=${day%-*}
# "${day%%-*}/${day%-*}/$day.md"
#[ -s 'latest.md' ] && latest=$(date -d '$(cat latest.md)')
# todo: overwrite option...

print -P "日記一括作成スクリプト By Hikali-47041" >&2

if [ "$#" -gt 0 ]
then
    while getopts vht:s:e: opt
    do
        case $opt in
            "v" ) verbose=true ; print -P "%F{012}[info]: verbose flag is true%f" >&2;;
            "t" ) if [ -f "$OPTARG" ]
                    then template="$OPTARG"
                    else print -P "Error: '$OPTARG': No such file" >&2; exit 1
                  fi;;
            "s" ) [ "$(date -d "$OPTARG")" ] && startdate=$(date -I -d "$OPTARG") || exit 1;;
            "e" ) [ "$(date -d "$OPTARG")" ] && enddate=$(date -I -d "$OPTARG")   || exit 1;;
             *  ) print -P "Usage: $0 [OPTIONS]" >&2
                  print -P "OPTIONS:" >&2
                  print -P "  -h         help           show this help" >&2
                  print -P "  -v         verbose        show progress" >&2
                  print -P "  -t [file]  template data  default $template" >&2
                  print -P "  -s [date]  start date     default $startdate" >&2
                  print -P "  -e [date]  end date       default $enddate" >&2
                  [ "$opt" = "h" ] || exit 1 && exit 0 # -h の場合 exit 0
        esac
    done
fi

# swap if $startdate > $enddate
if [ "${startdate//-/}" -gt "${enddate//-/}" ]
then
    print -P "%F{011}Waring: $startdate is the future than $enddate.\n        So swap swap these value.%f" >&2
    tmpdate="$startdate"
    startdate="$enddate"
    enddate="$tmpdate"
else
    $verbose && print -P "%F{012}[info]: Start date is $startdate%f" >&2
    $verbose && print -P "%F{012}[info]: Start date is $enddate%f" >&2
fi


for year in {"${startdate%%-*}".."${enddate%%-*}"}
do

# make start of month
if [ "$year" -eq "${startdate%%-*}" ]
then
    som="${${startdate#*-}%-*}"
    $verbose && print -P "%F{012}[info]: start month is $som ($startdate)%f" >&2
else
    som=01
fi

# make end of month
if [ "$year" -eq "${enddate%%-*}" ]
then
    eom="${${enddate#*-}%-*}"
    $verbose && print -P "%F{012}[info]: end month is $eom ($enddate)%f" >&2
else
    eom=12
fi

for month in {"$som".."$eom"}
do

dirpath="$year/$year-$month"
# mkdir
if [ ! -e "$dirpath" ]
then
    $verbose && print -P "%F{012}[info]: Directory $dirpath does not exist. So creating directory $dirpath%f" >&2
    mkdir -p "$dirpath"
else
    $verbose && print -P "%F{012}[info]: Directory $dirpath already exist%f" >&2
fi

# make start of day
if [ "$year$month" -eq "${${startdate%-*}//-/}" ]
then
    sod="${startdate##*-}"
    $verbose && print -P "%F{012}[info]: start day is $sod ($startdate)%f" >&2
else
    sod=01
fi

# make end of day
if [ "$year$month" -eq "${${enddate%-*}//-/}" ]
then
    eod="${enddate##*-}"
    $verbose && print -P "%F{012}[info]: end day is $eod ($enddate)%f" >&2
else
    eod=$(date '+%d' -d "$(date "+$year-$month-01 1 days ago + 1 month")")
fi

for day in {"$sod".."$eod"}
do

filepath="$dirpath/$year-$month-$day.md"

# fileがない場合作成
if [ ! -e "$filepath" ]
then
    $verbose && print -P "%F{012}[info]: File $filepath does not exist. So creating file $filepath%f"
    touch "$filepath"
else
    $verbose && print -P "%F{012}[info]: file $filepath already exist%f" >&2
fi

# fileが空の場合内容を書き込む
if [ ! -s "$filepath" ]
then
    $verbose && print -P "%F{012}[info]: $filepath is empty file. Making%f" >&2
cat - "$template" << EOF > "$filepath"
## $(date '+%Y/%m/%d %A' -d "$year-$month-$day")

- - -

EOF
else
    $verbose && print -P "%F{012}[info]: $filepath is not empty file%f" >&2
fi


done
done
done

# date "+$year-$month-$day" > latest.md
print -P "%F{012}[info]: だん!%f" >&2
