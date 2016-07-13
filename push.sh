set -o nounset
set -o errexit
set -o pipefail

thisfile="${BASH_SOURCE[0]}"
thisdir="$( cd "$( dirname "${thisfile}" )" && pwd )"

function push_one() {
    if [[ -f ./build.sh && -f ./version ]]; then
        local name=zppz/$(basename $(pwd)):$(cat ./version)
        echo pushing "${name}"...
        docker push "${name}"
        echo
        (( $? == 0 )) || exit 1
        for f in *; do
            if [[ -d "$f" && ! -L "$f" ]]; then
                ( cd "$f"; push_one )
                (( $? ==0 )) || exit 1
            fi
        done
    fi
}


echo pushing images to the cloud:
echo
(cd "${thisdir}"/base; push_one )


