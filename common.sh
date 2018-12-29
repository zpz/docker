function find-newest-tag {
    docker images "$1" --format "{{.Tag}}" | sort | tail -n 1
}


