thisfile="${BASH_SOURCE[0]}"
thisdir="$( cd "$( dirname "${thisfile}" )" && pwd )"

bash "$thisdir"/clean-docker.sh \
    && bash "$thisdir"/uninstall.sh

