# There are two ways to specify an image name (except for tag):
#   python
#   somerepo/xyz
#
# The first one means the "official image" 'python'.
# The second one includes namespace such as 'zppz'.

set -Eeuo pipefail


function echoerr {
    >&2 echo "$@"
}


function get-image-tags-local {
    # Input is image name w/o tag.
    # Returns space separated list of tags;
    # '-' if not found.
    name="$1"
    if [[ "${name}" == *:* ]]; then
        echoerr "image name '${name}' already contains tag"
        return 1
    fi
    tags=$(docker images "${name}" --format "{{.Tag}}" )
    if [[ "${tags}" == '' ]]; then
        echo -
    else
        echo $(echo "${tags}")
    fi
}


function get-image-tags-remote {
    # Analogous `get-image-tags-local`.
    #
    # For an "official" image, the image name should be 'library/xyz'.
    # However, the API response is not complete.
    # For now, just work on 'zppz/' images only.
    name="$1"
    if [[ "${name}" == *:* ]]; then
        echoerr "image name '${name}' already contains tag"
        return 1
    fi
    if [[ "${name}" != zppz/* ]]; then
        echoerr "image name '${name}' is not in the 'zppz' namespace; not supported at present"
        return 1
    fi
    url=https://hub.docker.com/v2/repositories/${name}/tags
    tags="$(curl -L -s ${url} | tr -d '{}[]"' | tr ',' '\n' | grep name)"
    if [[ "$tags" == "" ]]; then
        echo -
    else
        tags="$(echo $tags | sed 's/name: //g' | sed 's/results: //g')"
        echo "${tags}"
    fi
}


function has-image-local {
    # Input is image name with tag.
    # Returns whether this image exists locally.

    name="$1"
    if [[ "${name}" != *:* ]]; then
        echoerr "input image '${name}' does not contain tag"
        return 1
    fi
    tag=$(docker images "${name}" --format "{{.Tag}}" )
    if [[ "${tag}" != '' ]]; then
        echo yes
    else
        echo no
    fi
}


function has-image-remote {
    name="$1"
    if [[ "${name}" != *:* ]]; then
        echoerr "input image '${name}' does not contain tag"
        return 1
    fi
    if [[ "${name}" != zppz/* ]]; then
        # In this case, the function `get-image-tags-remote`
        # is not reliable, so just return 'yes'.
        echo yes
    else
        tag="${name##*:}"
        name="${name%:*}"
        tags=$(get-image-tags-remote "${name}")
        if [[ "${tags}" == *" ${tag} "* ]]; then
            echo yes
        else
            echo no
        fi
    fi
}


function find-latest-image-local {
    # Find Docker image of specified name with the latest tag on local machine.
    #
    # For a non-zppz image, must specify exact tag.
    # In this case, this function checks whether that image exists.
    #
    # Returns full image name with tag.
    # Returns '-' if not found

    name="$1"
    if [[ "${name}" == zppz/* ]]; then
        if [[ "${name}" == *:* ]]; then
            if [[ $(has-image-local "${name}") == yes ]]; then
                echo "${name}"
            else
                echo -
            fi
        else
            tag=$(docker images "${name}" --format "{{.Tag}}" | sort | tail -n 1)
            if [[ "${tag}" == '' ]]; then
                echo -
            else
                echo "${name}:${tag}"
            fi
        fi
    else
        if [[ "${name}" != *:* ]]; then
            echoerr "image '${name}' must have its exact tag specified"
            return 1
        fi

        if [[ $(has-image-local "${name}") == yes ]]; then
            echo "${name#library/}"
        else
            echo -
        fi
    fi
}


function find-latest-image-remote {
    name="$1"
    if [[ "${name}" == *:* ]]; then
        if [[ $(has-image-remote "${name}") == yes ]]; then
            echo "${name}"
        else
            echo -
        fi
    else
        if [[ "${name}" != zppz/* ]]; then
            echoerr "image '${name}' must have its exact tag specified"
            return 1
        fi
        tags="$(get-image-tags-remote ${name})"
        if [[ "${tags}" != '-' ]]; then
            tag=$(echo "${tags}" | tr ' ' '\n' | sort -r | head -n 1)
            echo "${name}:${tag}"
        else
            echo -
        fi
    fi
}


function find-latest-image {
    name="$1"
    local=$(find-latest-image-local "${name}")
    remote=$(find-latest-image-remote "${name}")
    if [[ "${local}" == - ]]; then
        echo "${remote}"
    elif [[ "${remote}" == - ]]; then
        echo "${local}"
    elif [[ "${local}" < "${remote}" ]]; then
        echo "${remote}"
    else
        echo "${local}"
    fi
}


function find-image-id-local {
    # Input is a full image name including tag.
    name="$1"
    docker images "${name}" --format "{{.ID}}"
}


function build-image {
    BUILDDIR="$1"
    shift
    BUILD_ARGS="$@"

    NAME=zppz/$(basename "${BUILDDIR}")
    parent=$(cat "${BUILDDIR}/parent")

    PARENT=$(find-latest-image ${parent})
    if [[ "${PARENT}" == - ]]; then
        echoerr "Unable to find parent image '${parent}'"
        return 1
    fi

    old_img=$(find-latest-image ${NAME})
    if [[ "${old_img}" != - ]] && [[ $(has-image-local "${old_img}") == no ]]; then
        echo
        docker pull ${old_img}
    fi

    VERSION="$(date -u +%Y%m%dT%H%M%SZ)"
    # UTC datetime. This works the same on Mac and Linux.
    # Version format is like this:
    #    20180913T081243Z
    FULLNAME="${NAME}:${VERSION}"

    echo
    echo
    echo "=== build image ${FULLNAME}"
    echo "       based on ${PARENT} ==="
    echo "=== $(date) ==="
    echo

    docker build --build-arg PARENT="${PARENT}" ${BUILD_ARGS} -t "${FULLNAME}" "${BUILDDIR}" >&2 || return 1

    new_img="${FULLNAME}"
    if [[ "${old_img}" != - ]]; then
        old_id=$(find-image-id-local "${old_img}")
        new_id=$(find-image-id-local "${new_img}")
        if [[ "${old_id}" == "${new_id}" ]]; then
            echo
            echo "Newly built image is identical to an older build; discarding the new tag..."
            docker rmi "${new_img}"
        fi
    fi
}