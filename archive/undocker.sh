# Usage:
#
#   bash undocker.sh [image]
#
# where `image` is an image name w/ or w/o tag.
# If `image` is an image name w/o tag, all images of that name w/ various tags will be deleted.
# If `image` is an image name w/ tag, image of that exact full name will be deleted.
# In addition, inactive containers based on an image being deleted will be deleted.
# All un-used intermediate images created in this process will be deleted as well.
#
# If `image` is absent, the images defined in this repo in the present working directory
# and its child directories will be deleted, with chain reactions as described above.
# However, this often can not achieve a clean and complete deletion, due to
# changed directory structure and image names, etc.
#
# If cleaning is stuck with no progress, check printouts and look for messages
# about active or inactive containers that are using the images being deleted.
# Stop or remove those containers before trying this command again.

set -o pipefail
set -o nounset


function undocker_intermediate {
    # if [[ -n "$(docker images | grep '<none>' | awk '{print $3}')" ]]; then
    #     echo
    #     echo deleting unused intermediate images ...
    #     docker rmi $(docker images | grep '<none>' | awk '{print $3}')
    # fi
    if [[ -n "$(docker images -f dangling=true -q)" ]]; then
        docker rmi $(docker images -f dangling=true -q)
    fi
}


function uncontainer {
    # Get image name, w/ or w/o tag.
    local name="$1"
    local containers="$(docker ps -a | tail -n +2 | awk '$2 ~ "'"${name}"'" { print $1 }')"
    if [[ -n "${containers}" ]]; then
        echo deleting containers based on image like "'${name}'": ${containers}
        docker rm -v ${containers}
    fi
}


function unimage {
    # Get image name, w/ or w/o tag.
    local name="$1"

    undocker_intermediate

    uncontainer "${name}"

    undocker_intermediate

    local images="$(docker images -q "${name}")"
    if [[ -n "${images}" ]]; then
        echo deleting images like "${name}": ${images}
        docker rmi -f ${images}
    fi

    undocker_intermediate
}


function undocker_one {
    for f in *; do
        if [[ -d "$f" && ! -L "$f" ]]; then
            (cd "$f"; undocker_one )
        fi
    done
    echo --- in $(pwd) ---
    if [[ -f ./build.sh && -f ./name && -f ./version ]]; then
        local name=$(cat ./name)
        unimage "${name}"
    fi
}


if [[ $# == 0 ]]; then
    # thisfile="${BASH_SOURCE[0]}"
    # thisdir=$( cd "$( dirname "${thisfile}" )" && pwd)
    thisdir="$(pwd)"

    ( cd "${thisdir}"; undocker_one )
else
    unimage "$1"
fi

