#!/bin/bash
#
# Uses perfetct lib https://github.com/twpayne/igc2kmz to convert
# all *.igc files in dir to *.kmz
# Put color.txt with color line like FF00FFFF in each subfolder to define track color

#set -xe #for debugging and early abort on error
set -o pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

IGC2KMZ="$SCRIPT_DIR/igc2kmz/bin/igc2kmz.py"
PY="/usr/bin/python3"
OLC_BIN="$SCRIPT_DIR/igc2kmz/contrib/leonardo/olc2002"
OLC2GPX="$SCRIPT_DIR/igc2kmz/bin/olc2gpx.py"
TRACKS_DEFAULT="$SCRIPT_DIR/"

echo "Start script for converting tracks"

usage() { echo "Usage: $0 [-d <string> directory to search for igc files]" 1>&2; exit 1; }

d=$TRACKS_DEFAULT

while getopts ":d:" o; do
    case "${o}" in
        d)
            d=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${d}" ]; then
    usage
fi


if [ ! -d "${d}" ]; then
    echo  "Directory ${d} not found"
    exit 1
fi

if [ ! -x "$OLC_BIN" ]; then
    echo "Building Leonardo optimizer"
    (cd "$SCRIPT_DIR/igc2kmz" && make "contrib/leonardo/olc2002")
fi


OIFS="$IFS"
IFS=$'\n'

for f in $(find ${d} -iname "*.igc" -type f); do
    dirname="$(dirname ${f})"
    color="FFFFFFFF"

    if [ -f "${dirname}/color.txt" ]; then
        color=$(head -n 1 "${dirname}/color.txt");
    fi

    pname=$(echo $dirname|xargs basename)

    out="${f}.kmz"

    extra_args=()
    olc_tmp=
    gpx_tmp=

    olc_tmp="$(mktemp)"
    gpx_tmp="$(mktemp --suffix='.gpx')"
    filtered_igc="$(mktemp --suffix='.igc')"
    target=2000
    b_count=$(grep -c '^B' "$f")
    if [ "$b_count" -le "$target" ] || [ "$b_count" -eq 0 ]; then
        cp "$f" "$filtered_igc"
        filter_status=0
    else
        step=$(( (b_count + target - 1) / target ))
        if ! awk -v step="$step" '
function flush_pending() {
    if (has_pending) {
        print pending_line
        has_pending = 0
    }
}
BEGIN {
    b_idx = 0
    has_pending = 0
}
{
    if ($0 ~ /^B/) {
        b_idx++
        if (b_idx == 1) {
            print
            has_pending = 0
            next
        }
        if ((b_idx % step) == 0) {
            print
            has_pending = 0
        } else {
            pending_line = $0
            has_pending = 1
        }
    } else {
        print
    }
}
END {
    flush_pending()
}
' "$f" > "$filtered_igc"; then
            filter_status=1
        else
            filter_status=0
        fi
    fi
    if [ "$filter_status" -ne 0 ]; then
        echo "Failed to filter ${f}" >&2
        cp "$f" "$filtered_igc"
    fi
    if "$OLC_BIN" "$filtered_igc" > "$olc_tmp"; then
        norm_tmp="${olc_tmp}.normalized"
        sed -E 's/^DEBUG DATE DATE:([0-9]{6}).*/DEBUG DATE \1/' "$olc_tmp" > "$norm_tmp"
        mv "$norm_tmp" "$olc_tmp"
        if $PY "$OLC2GPX" -o "$gpx_tmp" "$olc_tmp"; then
            extra_args=(-x "$gpx_tmp")
        else
            echo "Failed to convert Leonardo output for ${f}" >&2
        fi
    else
        echo "Failed to run Leonardo optimizer for ${f}" >&2
    fi

    if [ ! -f "$out" ]; then
        $PY $IGC2KMZ -i "${f}" -o "${out}" -c $color -n $pname "${extra_args[@]}"
        echo "Converted ${f} to ${out} with color=${color} and pilot=${pname}"
    fi
    rm -f "$olc_tmp" "$gpx_tmp" "$filtered_igc"
done
IFS="$OIFS"
