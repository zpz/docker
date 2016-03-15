# Usage:
#  source this-script

thisfile="${BASH_SOURCE[0]}"
thisdir="$( cd "$( dirname "${thisfile}" )" && pwd )"

echo \
    && ( source "$thisdir"/py3/build.sh ) \
    && ( source "$thisdir"/rr/build.sh ) \
    && ( source "$thisdir"/setup.sh )

