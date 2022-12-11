# Usage:
#
#    bash upload.sh
#
# Recursively walk in subdirectories and upload select images to dockerhub.
# This requires the current machine has logged into docker hub.


set -o nounset
set -o errexit
set -o pipefail

thisfile="${BASH_SOURCE[0]}"
thisdir="$( cd "$( dirname "${thisfile}" )" && pwd )"

function push_one() {
    if [[ -f ./build.sh && -f ./version ]]; then
        local name="$(cat ./name):$(cat ./version)"
        if [[ "${name}" == *'/'* ]]; then
            echo pushing "${name}"...
            docker push "${name}"
            echo
            (( $? == 0 )) || exit 1
        fi
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
for f in ${thisdir}/*; do
    if [[ -d "$f" && ! -L "$f" ]]; then
        ( cd "$f"; push_one )
    fi
done


