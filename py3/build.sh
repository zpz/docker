set -Eeuo pipefail

thisfile="${BASH_SOURCE[0]}"
thisdir="$( cd "$( dirname "${thisfile}" )" && pwd )"
parentdir="$( dirname ${thisdir} )"
source "${parentdir}/common.sh"

parent=python:3.6-slim-stretch

build-simple ${thisdir} ${parent}
