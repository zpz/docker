#set -o errexit
set -o pipefail
set -o nounset

thisfile="${BASH_SOURCE[0]}"
thisdir="$( cd "$( dirname "${thisfile}" )" && pwd )"

function delete_one {
    if [[ -f ./build.sh && -f ./version ]]; then
        for f in *; do
            if [[ -d "$f" && ! -L "$f" ]]; then
                ( cd "$f"; delete_one )
            fi
        done
        echo --- in $(pwd) ---
        local name=zppz/$(basename $(pwd))
        if [[ -n $(docker ps -a | awk '$2 ~ "'"$name"'*" { print $1 }') ]]; then
            echo deleting containers based on image like "'$name'"
            docker rm $(docker ps -a | awk '$2 ~ "'"$name"'*" { print $1 }')
        fi
        if [[ -n "$(docker images | grep '<none>' | awk '{print $3}')" ]]; then
            echo
            echo deleting unused intermediate images ...
            docker rmi $(docker images | grep '<none>' | awk '{print $3}')
        fi
        if [[ -n "$(docker images -q "$name")" ]]; then
            echo deleting images like "'$name'"
            docker rmi -f $(docker images -q "$name")
        fi
    fi
}


echo deleting docker images ...
echo
for f in "${thisdir}/*"; do
    if [[ -d "$f" && ! -L "$f" ]]; then
        ( cd "$f"; delete_one )
    fi
done

if [[ -n "$(docker images | grep '<none>' | awk '{print $3}')" ]]; then
    echo
    echo deleting unused intermediate images ...
    docker rmi $(docker images | grep '<none>' | awk '{print $3}') 2>/dev/null
fi


