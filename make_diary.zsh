#!/bin/zsh

# touch $base_dir/YYYY/YYYY-MM/YYYY-MM-DD.md files

# set default value
base_dir="$PWD"
start_date="$(date -I)"
end_date="$start_date"
dry_run_flag=false
template_file="/dev/null"
template_text=""
ext="md"

# show help message
show_help() {
    print -P "create YYYY/YYYY-MM/YYYY-MM-DD.$ext files" >&2
    print -P "Usage: $0 [OPTIONS]" >&2
    print -P "Options:" >&2
    print -P "  -b, --base-dir <dir>        Specify the base directory." >&2
    print -P "  --extention <ext>           Specify the file extension." >&2
    print -P "  -d, --dry-run               Perform a dry run without making changes." >&2
    print -P "  -e, --end-date <date>       Specify the end date (YYYY-MM-DD)." >&2
    print -P "  -h, --help                  Show this help message." >&2
    print -P "  -s, --start-date <date>     Specify the start date (YYYY-MM-DD)." >&2
    print -P "  -t, --template-file <file>  Specify the template file." >&2
    print -P "Examples:" >&2
    print -P "  $0 --base-dir /path/to/dir --extention txt" >&2
    print -P "  $0 -s 2025-01-01 -e 2025-12-31" >&2
    print -P "Note:" >&2
    print -P "  All date inputs should be in YYYY-MM-DD format." >&2
}

# overwhite args
# TODO: 引数の内容の解析
POSITIONAL_ARGS=()
while [[ $# -gt 0 ]]; do
    case $1 in
        -b|--base-dir) [ -n "$2" ] && base_dir="$2" || {print -P "%F{009} [Error] Invalid args %f" >&2; show_help $0; exit 1}; shift 2;;
        -b=*|--base-dir=*) ARG="$1"; base_dir="${ARG#*=}"; unset ARG; shift;;
        --extention) [ -n "$2" ] && ext="$2" || {print -P "%F{009} [Error] Invalid args %f" >&2; show_help $0; exit 1}; shift 2;;
        --extention=*) ARG="$1"; ext="${ARG#*=}"; unset ARG; shift;;
        -d|--dry-run) dry_run_flag=true; shift;;
        -e|--end-date) [ -n "$2" ] && end_date=$(date -I -d "$2") || {print -P "%F{009} [Error] Invalid args %f" >&2; show_help $0; exit 1}; shift 2;;
        -e=*|--end-date=*) ARG="$1"; end_date=$(date -I -d "${ARG#*=}"); unset ARG; shift;;
        -h|--help) show_help $0; exit 0;;
        -s|--start-date) [ -n "$2" ] && start_date=$(date -I -d "$2") || {print -P "%F{009} [Error] Invalid args %f" >&2; show_help $0; exit 1}; shift 2;;
        -s=*|--start-date=*) ARG="$1"; start_date=$(date -I -d "${ARG#*=}"); unset ARG; shift;;
        -t|--template-file) [ -n "$2" ] && template_file="$2" || {print -P "%F{009} [Error] Invalid args %f" >&2; show_help $0; exit 1}; shift 2;;
        -t=*|--template-file=*) ARG="$1"; template_file="${ARG#*=}"; unset ARG; shift;;
        --) shift;  POSITIONAL_ARGS+=("$@"); set --;;
        -*) print -P "%F{009}[ERROR] Unknown option $1%f" >&2; show_help $0; exit 1;;
        --*) print -P "%F{009}[ERROR] Unknown option $1%f" >&2; show_help $0; exit 1;;
        *)  POSITIONAL_ARGS+=("$1"); shift;;
    esac
done
set -- "${POSITIONAL_ARGS[@]}"  #// set $1, $2, ...
unset POSITIONAL_ARGS


[ -e "$template_file" ] && template_text=$(<"$template_file")

# swap if start_date > end_date in year level
if [ "${start_date%%-*}" -gt "${end_date%%-*}" ]; then
    tmp_date=$start_date
    start_date=$end_date
    end_date=$tmp_date
fi



file_list=()
if [ "${${start_date%-*}//-/}" -eq "${${end_date%-*}//-/}" ]
then
    # single month
    file_list=("$base_dir/${start_date%%-*}/${start_date%-*}/${start_date%-*}-"{"${start_date##*-}".."${end_date##*-}"}".$ext")
elif [ "${start_date%%-*}" -eq ${end_date%%-*} ]
then
    # single year
    # start month
    start_of_day="${start_date##*-}"
    end_of_day=$(date '+%d' -d "$(date "+${start_date%-*}-01 1 days ago + 1 month")")
    file_list+=("$base_dir/${start_date%%-*}/${start_date%-*}/${start_date%-*}-"{"$start_of_day".."$end_of_day"}".$ext")
    # between month
    month_array=({"${${start_date#*-}%%-*}".."${${end_date#*-}%%-*}"})
    for month in ${month_array[@]:1:${#month_array[@]}-2}
    do
        end_of_day=$(date '+%d' -d "$(date "+${start_date%%-*}-$month-01 1 days ago + 1 month")")
        file_list+=("$base_dir/${start_date%%-*}/${start_date%%-*}-$month/${start_date%%-*}-$month-"{01.."$end_of_day"}".$ext")
    done
    # end month
    end_of_day="${end_date##*-}"
    file_list+=("$base_dir/${end_date%%-*}/${end_date%-*}/${end_date%-*}-"{01.."$end_of_day"}".$ext")
else
    # multi years
    year_array=({"${start_date%%-*}".."${end_date%%-*}"})
    # start_date year
    # start month
    start_of_day="${start_date##*-}"
    end_of_day=$(date '+%d' -d "$(date "+${start_date%-*}-01 1 days ago + 1 month")")
    file_list+=("$base_dir/${start_date%%-*}/${start_date%-*}/${start_date%-*}-"{"$start_of_day".."$end_of_day"}".$ext")
    # between month
    month_array=({${${start_date#*-}%%-*}..12})
    for month in ${month_array[@]:1}
    do
        end_of_day=$(date '+%d' -d "$(date "+${start_date%%-*}-$month-01 1 days ago + 1 month")")
        file_list+=("$base_dir/${start_date%%-*}/${start_date%%-*}-$month/${start_date%%-*}-$month-"{01.."$end_of_day"}".$ext")
    done
    # between year
    for year in "${year_array[@]:1:${#year_array[@]}-2}"
    do
        for month in {01..12}
        do
            end_of_day=$(date '+%d' -d "$(date "+$year-$month-01 1 days ago + 1 month")")
            file_list+=("$base_dir/$year/$year-$month/$year-$month-"{01.."$end_of_day"}".$ext")
        done
    done
    # end_date year
    # between month
    month_array=({01..${${end_date#*-}%%-*}})
    for month in ${month_array[@]:0:${#month_array[@]}-1}
    do
        end_of_day=$(date '+%d' -d "$(date "+${end_date%%-*}-$month-01 1 days ago + 1 month")")
        file_list+=("$base_dir/${end_date%%-*}/${end_date%%-*}-$month/${end_date%%-*}-$month-"{01.."$end_of_day"}".$ext")
    done
    # end month
    end_of_day="${end_date##*-}"
    file_list+=("$base_dir/${end_date%%-*}/${end_date%-*}/${end_date%-*}-"{01.."$end_of_day"}".$ext")
fi

# run touch
if "$dry_run_flag"
then
    print -P "%F{014}[dry_run] touch $file_list %f" >&2
else
    # touch
    # print -P "%F{012} touch $file_list%f" >&2
    touch $file_list
fi

# write file
for file_path in $file_list
do
    # is file empty?
    if [ ! -s "$file_path" ]
    then
        if "$dry_run_flag"
        then
            print -P "%F{014}[dry_run] write # ${file_path:t:r} + $template_file content to $file_path%f" >&2
        else
            # add filename and template
            # print -P "%F{014}[dry_run] write # ${file_path:t:r} + $template_file content to $file_path%f" >&2
            print "# ${file_path:t:r}\n$template_text" > "$file_path"
        fi
    fi
done
