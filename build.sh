set -Eeuo pipefail

thisfile="${BASH_SOURCE[0]}"
thisdir="$( cd $( dirname ${thisfile} ) && pwd )"

source "${thisdir}/mini/bin/docker_build_utils.sh"


function add-image {
    dd="$1"  # A directory name.
    shift
    if (( $# > 0)); then
        images="${@}"  # Capture all remaining args as a string
    else
        images=''
    fi

    if [ -e "${dd}/parent" ] && [ -e "${dd}/Dockerfile" ]; then
        if [[ " ${images} " != *\ ${dd}\ * ]]; then
            # Not yet processed and added to list.
            parent="$(cat ${dd}/parent)"
            if [[ "${parent}" == zppz/* ]]; then
                images="$(add-image ${parent#zppz/} ${images})"
            fi
            images="${images} ${dd}"
        fi
    fi
    echo "${images}"
}


function find-images {
    images=''
    cd "${thisdir}"
    subdirs=( $(ls -d */) )
    for dd in "${subdirs[@]}"; do
        dd=${dd%%/}
        images="$(add-image $dd ${images})"
    done
    echo "${images}"
}


function main {
    old_images=''
    new_images=''
    for img in "${IMAGES[@]}"; do
        old_img=$(find-latest-image zppz/${img})

        builddir="${thisdir}/${img}"
        parent=$(cat "${builddir}/parent")
        build-image zppz/$img $parent $builddir || return 1

        new_img=$(find-latest-image-local zppz/${img})
        if [[ "${new_img}" == "${old_img}" ]]; then
            new_img=-
        fi
        new_images="${new_images} ${new_img}"
    done

    if [[ "${PUSH}" == yes ]]; then
        echo
        echo
        echo '=== pushing images to Dockerhub ==='
        echo
        new_images=( ${new_images} )
        for img in "${new_images[@]}"; do
            if [[ "${img}" != - ]]; then
                echo
                echo "pushing ${img}"
                docker push "${img}"
            fi
        done
    fi
}


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

PUSH=no
if [[ $# > 0 ]]; then
    # IMAGES=( $@ )
    IMAGES=''
    while [[ $# > 0 ]]; do
        if [[ "$1" == --push ]]; then
            PUSH=yes
        else
            IMAGES="${IMAGES} $1"
        fi
        shift
    done
    if [[ "${IMAGES}" == '' ]]; then
        IMAGES=( $(find-images) )
    else
        IMAGES=( $IMAGES )
    fi
else
    IMAGES=( $(find-images) )
fi

# echo "IMAGES: ${IMAGES[@]}"
main
