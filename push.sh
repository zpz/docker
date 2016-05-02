thisfile="${BASH_SOURCE[0]}"
thisdir="$( cd "$( dirname "${thisfile}" )" && pwd )"

function push_one() {
    if [[ -f ./build.sh && -f ./version ]]; then
        name=zppz/$(basename $(pwd)):$(cat ./version)
        echo pushing "$name"...
        docker push "$name"
        (( $? == 0 )) || exit 1
        for f in *; do
            if [[ -d "$f" && ! -L "$f" ]]; then
                ( cd "$f"; push_one )
                (( $? ==0 )) || exit 1
            fi
        done
    fi
}


echo pushing images to the cloud:

echo \
    && ( cd "$thisdir"/py3; push_one ) \
    && ( cd "$thisdir"/latex; push_one )


