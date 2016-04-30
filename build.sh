
thisfile="${BASH_SOURCE[0]}"
thisdir="$( cd "$( dirname "${thisfile}" )" && pwd )"

echo \
    && bash "$thisdir"/py3/build.sh \
    && bash "$thisdir"/py3-dev/build.sh

