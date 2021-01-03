#!/bin/bash

set -Eeuo pipefail

TINY=zppz/tiny:21.01.02
TAG=$(docker run --rm ${TINY} make-date-version)
NAMESPACE=zppz
THISDIR=$(cd $( dirname "${BASH_SOURCE[0]}") && pwd )


function build-image {
    name="$1"
    shift
    build_dir="$1"
    shift
    echo
    echo "building $name ..."
    echo
    docker build -t "${name}" "${build_dir}" $@
    echo
    if [ $PUSH ]; then
        echo
        echo pushing ${name} to dockerhub ...
        echo
        docker push ${name}
    fi
}


function build-py3 {
    build-image ${NAMESPACE}/py3:${TAG} ${THISDIR}/py3
}


function build-py3-r {
    cmd="$(docker run --rm ${TINY} cat /usr/tools/find-image)"
    parent=$(bash -c "${cmd}" -- zppz/py3)
    build-image ${NAMESPACE}/py3-r:${TAG} ${THISDIR}/py3-r --build-arg PARENT=${parent}
}


IMAGES=
PUSH=

while [[ $# > 0 ]]; do
    if [[ "$1" == --push ]]; then
        PUSH=yes
    else
        IMAGES="${IMAGES} $1"
    fi
    shift
done

if [ "${IMAGES}" ]; then
    IMAGES=( ${IMAGES} )
else
    IMAGES=( py3 py3-r )
fi

for img in "${IMAGES[@]}"; do
    if [ "${img}" = py3 ]; then
        build-py3
    elif [ "${img}" = py3-r ]; then
        build-py3-r
    else
        >&2 echo "unknown image name '${img}'"
        exit 1
    fi
done

