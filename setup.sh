
thisfile="${BASH_SOURCE[0]}"
thisdir="$( cd "$( dirname "${thisfile}" )" && pwd )"

echo \
    && bash "$thisdir"/build.sh \
    && bash "$thisdir"/install.sh

