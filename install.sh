#!/usr/bin/env bash

set -Eeuo pipefail

thisfile="${BASH_SOURCE[0]}"
thisdir="$( cd $( dirname ${thisfile} ) && pwd )"

bindir="${HOME}/work/bin"
mkdir -p "${bindir}"

(
    echo "installing 'run-docker' into '${bindir}'"
    cp -f "${thisdir}/run-docker" ${bindir}/run-docker
)

(
    cd latex
    bash install.sh
)


(
    cd jekyll
    bash install.sh
)