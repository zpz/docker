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


# function add-image {
#     local dd="$1"  # A directory name.
#     shift
#     if (( $# > 0)); then
#         local images="${@}"  # Capture all remaining args as a string
#     else
#         local images=''
#     fi

#     if [ -e "${dd}/parent" ] && [ -e "${dd}/Dockerfile" ]; then
#         if [[ " ${images} " != *\ ${dd}\ * ]]; then
#             # Not yet processed and added to list.
#             local parent="$(cat ${dd}/parent)"
#             if [[ "${parent}" == zppz/* ]]; then
#                 images="$(add-image ${parent#zppz/} ${images})"
#             fi
#             images="${images} ${dd}"
#         fi
#     fi
#     echo "${images}"
# }


# function find-images {
#     local images=''
#     cd "${thisdir}"
#     local subdirs=( $(ls -d */) )
#     local dd
#     for dd in "${subdirs[@]}"; do
#         dd=${dd%%/*}
#         images="$(add-image $dd ${images})" || return 1
#     done
#     echo "${images}"
# }


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
    local new_images=''
    local img
    local IMG
    local old_img
    local new_img
    for img in "${IMAGES[@]}"; do
        IMG="${NAMESPACE}/${img}"
        old_img=$(find-latest-image ${IMG}) || return 1

        local builddir="${thisdir}/${img}"
        local parent="$(cat ${builddir}/parent)"
        build-image $builddir ${IMG} ${parent} || return 1

        new_img=$(find-latest-image-local ${IMG}) || return 1
        if [[ "${new_img}" != "${old_img}" ]]; then
            new_images="${new_images} ${new_img}"
        fi
    done

    >&2 echo
    >&2 echo "Finished building new images: ${new_images[@]}"
    >&2 echo

    if [[ "${PUSH}" == yes ]] && [[ "${new_images}" != '' ]]; then
        >&2 echo
        >&2 echo
        >&2 echo '=== pushing images to Dockerhub ==='
        docker login --username ${DOCKERHUBUSERNAME} --password ${DOCKERHUBPASSWORD} || return 1
        >&2 echo
        new_images=( ${new_images} )
        for img in "${new_images[@]}"; do
            >&2 echo
            >&2 echo "pushing ${img}"
            docker push "${img}" || return 1
        done
    fi
}


NAMESPACE=zppz
MINI_IMG_NAME=${NAMESPACE}/mini


IMG=$(get-latest-image ${MINI_IMG_NAME}) || exit 1
if [[ "${IMG}" == '-' ]]; then
    >&2 echo "Unable to find image '${MINI_IMG_NAME}'"
    exit 1
fi

rm -f /tmp/build_utils.sh
docker run --rm ${IMG} cat /usr/local/bin/utils.sh > /tmp/build_utils.sh
[[ $? == 0 ]] || { >&2 echo "${IMG}"; exit 1; }
source /tmp/build_utils.sh
rm -f /tmp/build_utils.sh


if [[ $# > 0 ]]; then
    IMAGES=( $@ )
else
    # IMAGES=( $(find-images) ) || exit 1
    IMAGES=( py3 ml dl py3r )
fi
>&2 echo "IMAGES: ${IMAGES[@]}"

# The images are pushed to Dockerhub only when built at github
# by the integrated Travis-CI in branch `master`.

if [ -z ${TRAVIS_BRANCH+x} ]; then
    BRANCH=''
else
    BRANCH=${TRAVIS_BRANCH}
fi

if [[ ${BRANCH} == master ]]; then
    PUSH=yes
else
    PUSH=no
fi
>&2 echo "PUSH: ${PUSH}"

main
