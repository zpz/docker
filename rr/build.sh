(

thisfile="${BASH_SOURCE[0]}"
thisdir="$( cd "$( dirname "${thisfile}" )" && pwd )"
dockerdir="$( dirname "$thisdir" )"

source "$dockerdir"/util.sh

NAME="zppz/rr:0.1"
CHILDREN=()

cp -rf "$dockerdir"/dotfiles "$thisdir"/
build_image "$thisdir" "$NAME" "${CHILDREN[@]}"
retval=$?
rm -rf "$thisdir"/dotfiles

(( $retval == 0 )) || exit 1

build_children "$thisdir" "${CHILDREN[@]}"

)
