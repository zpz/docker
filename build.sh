# Build all the images defined in the subdirectories (recursively) of
# the current directory.
# Usage:
#
#  bash thisscript


set -o nounset
set -o pipefail

thisfile="${BASH_SOURCE[0]}"
thisdir="$( cd "$( dirname "${thisfile}" )" && pwd )"

function build_one() {
    echo
    echo in "'$(pwd)'"
    if [[ -f ./build.sh && -f ./version && -f ./name ]]; then
        bash ./build.sh
        (( $? == 0 )) || exit 1
        echo
        for f in *; do
            if [[ -d "$f" && ! -L "$f" ]]; then
                ( cd "$f"; build_one )
                (( $? ==0 )) || exit 1
            fi
        done
    fi
}


echo
for f in ${thisdir}/*; do
    if [[ -d "$f" && ! -L "$f" ]]; then
        ( cd "$f"; build_one )
    fi
done

