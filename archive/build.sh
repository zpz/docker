# Usage:
#
#   bash build.sh
#
# Recursively build images defined in the subdirectories.
# Build is attempted for a directory and its subdirectories only if
# the files `name` and `build.sh` both exist in the directory.


set -o nounset
set -o pipefail
set -o errexit

thisfile="${BASH_SOURCE[0]}"
thisdir="$( cd "$( dirname "${thisfile}" )" && pwd )"

function build_one() {
    echo
    echo in "'$(pwd)'"
    if [[ -f ./build.sh && -f ./name ]]; then
        bash ./build.sh
        echo
        for f in *; do
            if [[ -d "$f" && ! -L "$f" ]]; then
                ( cd "$f"; build_one )
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

