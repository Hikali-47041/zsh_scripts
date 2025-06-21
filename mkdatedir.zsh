#!/bin/zsh

# mkdir $base_dir/YYYY/YYYY-MM directories
# default: make today's directoy in current directory


# set default value
start_date="$(date -I)"
end_date="$start_date"
dry_run_flag=false

# show help message
show_help() {
    print -P "mkdir YYYY/YYYY-MM directories" >&2
    print -P "Usage: $0 [OPTIONS] [basedir]\n" >&2
    print -P "Options:" >&2
    print -P "  -d, --dry-run          Enable dry run mode (no actual changes will be made)." >&2
    print -P "  -e, --end-date DATE    Specify the end date (format: YYYY-MM-DD). default: today $(date -I)" >&2
    print -P "  -s, --start-date DATE  Specify the start date (format: YYYY-MM-DD). default: today $(date -I)" >&2
    print -P "  -h, --help             Show this help message and exit." >&2
    print -P "  basedir                Set mkdir base directory. default: current directory $PWD" >&2
    print -P "" >&2
    print -P "Examples:" >&2
    print -P "  $0 -d" >&2
    print -P "  $0 -e 2025-03-02" >&2
    print -P "  $0 -s 2025-03-06" >&2
    print -P "  $0 --help" >&2
}

# overwhite args
# TODO: 引数の内容の解析
POSITIONAL_ARGS=()
while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--dry-run) dry_run_flag=true; shift;;
        -e|--end-date) [ -n "$2" ] && end_date=$(date -I -d "$2") || {print -P "%F{009} [Error] Invalid args %f" >&2; show_help $0; exit 1}; shift 2;;
        -e=*|--end-date=*) ARG="$1"; end_date=$(date -I -d "${ARG#*=}"); unset ARG; shift;;
        -h|--help) show_help $0; exit 0;;
        -s|--start-date) [ -n "$2" ] && start_date=$(date -I -d "$2") || {print -P "%F{009} [Error] Invalid args %f" >&2; show_help $0; exit 1}; shift 2;;
        -s=*|--start-date=*) ARG="$1"; start_date=$(date -I -d "${ARG#*=}"); unset ARG; shift;;
        --) shift;  POSITIONAL_ARGS+=("$@"); set --;;
        -*) print -P "%F{009}[ERROR] Unknown option $1%f" >&2; show_help $0; exit 1;;
        --*) print -P "%F{009}[ERROR] Unknown option $1%f" >&2; show_help $0; exit 1;;
        *)  POSITIONAL_ARGS+=("$1"); shift;;
    esac
done
set -- "${POSITIONAL_ARGS[@]}"  #// set $1, $2, ...
unset POSITIONAL_ARGS

base_dir="${1:-$PWD}"

# swap if start_date > end_date in year level
if [ "${start_date//-/}" -gt "${end_date//-/}" ]
then
    tmp_date=$start_date
    start_date=$end_date
    end_date=$tmp_date
fi

# make year array
year_month_dir_array=()

# make year-month array
# there is 4 partten blace -> 1.{start..end} (single_year), 2.{start..12}, 3.{01..12}, 4. {01..end}
if [ "${start_date%%-*}" -eq ${end_date%%-*} ]
then
    # single year
    year_month_dir_array=("$base_dir/${start_date%%-*}/${start_date%%-*}-"{${${start_date#*-}%%-*}..${${end_date#*-}%%-*}})
else
    # multi year
    year_array=({"${start_date%%-*}".."${end_date%%-*}"})
    # start year
    year_month_dir_array+=("$base_dir/${start_date%%-*}/${start_date%%-*}-"{${${start_date#*-}%%-*}..12})
    # between years
    for year in "${year_array[@]:1:${#year_array[@]}-2}"
    do
        year_month_dir_array+=("$base_dir/$year/$year-"{01..12})
    done
    # end year
    year_month_dir_array+=("$base_dir/${end_date%%-*}/${end_date%%-*}-"{01..${${end_date#*-}%%-*}})
fi

# run mkdir
if "$dry_run_flag"
then
    print -P "%F{014}[dry_run] mkdir -p $year_month_dir_array%f" >&2
else
    # mkdir
    # print -P "%F{012} mkdir -p $year_month_dir_array%f" >&2
    mkdir -p $year_month_dir_array
fi
