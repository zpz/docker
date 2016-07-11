set -o errexit
set -o nounset
set -o pipefail

thisfile="${BASH_SOURCE[0]}"
thisdir="$( cd "$( dirname "${thisfile}" )" && pwd )"

function build_one() {
    if [[ -f ./build.sh && -f ./version ]]; then
        bash ./build.sh
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
( cd "${thisdir}"/base; build_one )

