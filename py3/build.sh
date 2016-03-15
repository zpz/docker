thisfile="${BASH_SOURCE[0]}"
thisdir="$( cd "$( dirname "${thisfile}" )" && pwd )"
dockerdir="$( dirname "$thisdir" )"

source "$dockerdir"/util.sh

NAME="zppz/py3:0.1"
CHILDREN=("py3r")

cp -rf "$dockerdir"/dotfiles "$thisdir"/
build_image "$thisdir" "$NAME" "${CHILDREN[@]}"
retval=$?
rm -rf "$thisdir"/dotfiles

if [[ $retval == 0 ]]; then
    build_children "$thisdir" "${CHILDREN[@]}"
else
    false
fi
