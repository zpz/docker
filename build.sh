# Usually this script is run w/o any argument, to build everything:
#
#   $ bash build.sh
#
# After at least one successful build of everything,
# you can specify a particular image to build, using that image's name
# as the argument.
#
# Usage:
#    $ bash build.sh [image-name]


set -Eeuo pipefail

thisfile="${BASH_SOURCE[0]}"
thisdir="$( cd $( dirname ${thisfile} ) && pwd )"


function get-latest-image {
    local name="$1"

    local tag
    local tags
    local localimg
    local remoteimg

    tag=$(docker images "${name}" --format "{{.Tag}}" | sort | tail -n 1)
    [[ $? == 0 ]] || { echo "${tag}"; return 1; }
    if [[ "${tag}" == '' ]]; then
        localimg='-'
    else
        localimg="${name}:${tag}"
    fi

    local url=https://hub.docker.com/v2/repositories/${name}/tags
    tags="$(curl -L -s ${url} | tr -d '{}[]"' | tr ',' '\n' | grep name)" || tags=''
    if [[ "$tags" == "" ]]; then
        remoteimg='-'
    else
        tags="$(echo $tags | sed 's/name: //g' | sed 's/results: //g')" || return 1
        tag=$(echo "${tags}" | tr ' ' '\n' | sort -r | head -n 1) || return 1
        remoteimg="${name}:${tag}"
    fi

    if [[ "${localimg}" == '-' ]]; then
        echo "${remoteimg}"
    else
        if [[ "${remoteimg}" == '-' ]]; then
            echo "${localimg}"
        elif [[ "${localimg}" < "${remoteimg}" ]]; then
            echo "${remoteimg}"
        else
            echo "${localimg}"
        fi
    fi
}


function main {
    local img
    local IMG
    local builddir
    local parent
    for img in "${IMAGES[@]}"; do
        IMG="${NAMESPACE}/${img}"
        builddir="${thisdir}/${img}"
        parent="$(cat ${builddir}/parent)"
        build-image $builddir ${IMG} ${parent} || return 1
        if [[ ${PUSH} == yes ]]; then
            push-image ${IMG}
        fi
    done
}


NAMESPACE=zppz
MINI_IMG_NAME=${NAMESPACE}/mini


IMG=$(get-latest-image ${MINI_IMG_NAME}) || exit 1
if [[ "${IMG}" == '-' ]]; then
    >&2 echo "Unable to find image '${MINI_IMG_NAME}'"
    exit 1
fi

# Need a few functions defined in the bash utility file `build_utils.sh`
rm -f /tmp/build_utils.sh
docker run --rm ${IMG} cat /usr/local/bin/utils.sh > /tmp/build_utils.sh || exit 1
source /tmp/build_utils.sh
rm -f /tmp/build_utils.sh

# The images are pushed to Dockerhub only when built at github
# by the integrated Travis-CI in branch `master`.

if [ -z ${TRAVIS_BRANCH+x} ]; then
    BRANCH=''
    PUSH=no
else
    BRANCH=${TRAVIS_BRANCH}
    PUSH=yes
fi

IMAGES=( py3 )
main
