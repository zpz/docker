set -Eeuo pipefail

thisfile="${BASH_SOURCE[0]}"
thisdir="$( cd $( dirname ${thisfile} ) && pwd )"
source "${thisdir}/common.sh"

# Usually this script is run w/o any argument, to build everything:
#
#   $ bash build.sh
#
# After at least one successful build of everything,
# you can specify a particular image to build, using that image's name
# as the argument.

IMAGE_TO_BUILD=""
if (( $# > 0 )); then
    IMAGE_TO_BUILD="$1"
    shift
fi

if (( $# > 0 )); then
    echo "Unknown arguments $@"
    exit 1
fi


function build-simple {
    BUILDDIR="$1"
    PARENT="$2"
    NAME="$(basename ${BUILDDIR})"

    VERSION="$(date -u +%Y%m%dT%H%M%SZ)"
    # UTC. This command with these arguments work the same on Mac and Linux.
    # Version format is like this:
    #    20180923T081243Z
    # which indicates full datetime accurate to seconds in UTC.
    # VERSION="$(date -u +%Y%m%d)"

    FULLNAME="${NAME}:${VERSION}"

    echo
    echo
    echo "=== building $FULLNAME, based on ${PARENT} ==="
    echo
    docker build --build-arg PARENT="${PARENT}" -t "${FULLNAME}" "${BUILDDIR}" >&2

    # set -x
    # docker tag ${FULLNAME} ${NAME}:latest
    # set +x
}


function build-one {
    name="$1"
    builddir="${thisdir}/${name}"
    parent=$(cat "${builddir}/parent")
    if [[ "$parent" != *:* ]]; then
        parent=${parent}:$(find-newest-tag ${parent})
    fi
    build-simple "${builddir}" "${parent}"
}


if [[ ${IMAGE_TO_BUILD} == "" ]]; then
    IMAGES=( py3 ml nlp visual py3x dl py3zpz)
    for img in "${IMAGES[@]}"; do
        build-one $img
    done
else
    build-one ${IMAGE_TO_BUILD}
fi
