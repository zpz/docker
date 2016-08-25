set -o errexit
set -o nounset
set -o pipefail

if (( $(date +%u) < 6 )); then
    echo Today is not weekend! Please work on other things.
    exit 1
fi

thisfile="${BASH_SOURCE[0]}"
thisdir="$( cd "$( dirname "${thisfile}" )" && pwd )"

function build_one() {
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
( cd "${thisdir}"/py2; build_one )
( cd "${thisdir}"/py3; build_one )
( cd "${thisdir}"/latex; build_one )
( cd "${thisdir}"/jdk; build_one )
( cd "${thisdir}"/jekyll; build_one )

