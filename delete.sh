thisfile="${BASH_SOURCE[0]}"
thisdir="$( cd "$( dirname "${thisfile}" )" && pwd )"

function delete_one() {
    if [[ -f ./build.sh && -f ./version ]]; then
        for f in *; do
            if [[ -d "$f" && ! -L "$f" ]]; then
                ( cd "$f"; delete_one )
                (( $? ==0 )) || exit 1
            fi
        done
        name=zppz/$(basename $(pwd))
        echo deleting containers based on image like "'$name'"
        docker rm $(docker ps -a | awk '$2 ~ "'"$name"'*" { print $1 }')
        echo deleting images like "'$name'"
        docker rmi -f $(docker images -q "$name") 2>/dev/null
    fi
}


echo deleting docker images:
echo \
    && ( cd "$thisdir"/py3; delete_one ) \
    && ( cd "$thisdir"/latex; delete_one )

echo
echo deleting unused intermediate images ...
docker rmi $(docker images | grep '<none>' | awk '{print $3}') 2>/dev/null

