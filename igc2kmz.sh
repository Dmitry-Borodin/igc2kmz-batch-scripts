#!/bin/bash
#
# Uses perfetct lib https://github.com/twpayne/igc2kmz to convert
# all *.igc files in dir to *.kmz
# Put color.txt with color line like FF00FFFF in each subfolder to define track color

IGC2KMZ="/home/dmitry/apps/converting/igc2kmz/bin/igc2kmz.py"
PY="/usr/bin/python2.7"

echo "Start script for converting tracks"

usage() { echo "Usage: $0 [-d <string> directory to search for igc files]" 1>&2; exit 1; }

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


OIFS="$IFS"
IFS=$'\n'

for f in $(find ${d} -name "*.igc" -type f); do
    dirname="$(dirname ${f})"
    color="FFFFFFFF"

    if [ -f "${dirname}/color.txt" ]; then
        color=$(head -n 1 "${dirname}/color.txt");
    fi

    pname=$(echo $dirname|xargs basename)

    out="${f}.kmz"

    if [ ! -f "$out" ]; then
        $PY $IGC2KMZ -i "${f}" -o "${out}" -c $color -n $pname
        echo "Converted ${f} to ${out} with color=${color} and pilot=${pname}"
    fi
done
IFS="$OIFS"


