thisfile="${BASH_SOURCE[0]}"
thisdir="$( cd "$( dirname "${thisfile}" )" && pwd )"
dockerdir="$( dirname "$( dirname "$thisdir" )" )"

source "$dockerdir"/util.sh

NAME="zppz/py3r:0.1"
CHILDREN=()

build_image "$thisdir" "$NAME" "${CHILDREN[@]}" \
    && build_children "$thisdir" "${CHILDREN[@]}"
