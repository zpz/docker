set -o nounset
set -o pipefail

if (( $(date +%u) < 6 )); then
    echo Today is not weekend! Please work on other things.
    #exit 1
fi

thisfile="${BASH_SOURCE[0]}"
thisdir="$( cd "$( dirname "${thisfile}" )" && pwd )"

function build_one() {
    echo in "'$(pwd)'"
    if [[ -f ./build.sh && -f ./version ]]; then
        bash ./build.sh
        echo
        (( $? == 0 )) || exit 1
        for f in *; do
            if [[ -d "$f" && ! -L "$f" ]]; then
                ( cd "$f"; build_one )
                (( $? ==0 )) || exit 1
            fi
        done
    fi
}


echo
for f in ${thisdir}/*; do
    if [[ -d "$f" && ! -L "$f" ]]; then
        ( cd "$f"; build_one )
    fi
done

