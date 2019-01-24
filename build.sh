thisfile="${BASH_SOURCE[0]}"
thisdir="$( cd $( dirname ${thisfile} ) && pwd )"

source "${thisdir}/mini/bin/docker_build_utils.sh"


function add-image {
    dd="$1"  # Either a directory name or an external image name
    shift
    if (( $# > 1)); then
        images="${@}"  # Capture all remaining args as a string
    else
        images=''
    fi

    if [[ "${dd}" != *:* ]]; then
        # Now "$dd" is not an external image; must be a directory.
        if [ -e "${dd}/parent" ] && [ -e "${dd}/Dockerfile" ]; then
            if [[ " ${images} " != *\ ${dd}\ * ]]; then
                # Not yet processed and added to list.
                parent="$(cat ${dd}/parent)"
                images="$(add-image ${parent} ${images}) $dd"
            fi
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
        old_img=$(find-latest-image ${img})

        builddir="${thisdir}/${img}"
        parent=$(cat "${builddir}/parent")
        build-image $img $parent $builddir || return 1

        new_img=$(find-latest-image-local ${img})
        if [[ "${new_img}" == "${old_img}" ]]; then
            new_img=-
        fi
        new_images="${new_images} ${new_img}"
    done

    if [[ "$(uname)" != Darwin ]]; then
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

set -Eeuo pipefail

if (( $# > 0 )); then
    IMAGES=( $@ )
else
    IMAGES=( $(find-images) )
fi

# echo "IMAGES: ${IMAGES[@]}"
main
