
build_image() {
    dir="${1}"   # "$(dir-of-Dockerfile)" as 1st argument
    name="${2}"  # image name (including tag) as 2nd argument
    children=("${@}")  # "${children[@]}" as 3nd argument
    retval=0
    if [[ -z "$DRYRUN" ]]; then
        echo "build.sh" > "$dir"/.dockerignore
        for child in "${children[@]}"; do
            echo "$child" >> "$dir"/.dockerignore
        done

        echo
        echo
        echo Building image "${name}"...
        echo
        sudo docker build -t "${name}" "$dir"
        retval=$?
        rm -f "$dir"/.dockerignore
    fi
    return $retval
}


build_children() {
    dir="${1}"  # "$(dir-of-Dockerfile)" as 1st argument
    shift
    children=("${@}")  # "${children[@]}" as 2nd argument
    for child in "${children[@]}"; do
        (
        cd "$dir"/"$child"
        if [[ -f "build.sh" ]]; then
            bash build.sh
        fi
        ) || return $?
    done
}

