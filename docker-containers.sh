#!/usr/bin/env bash

# Find Docker containers whose image name contains specified substring.
#
# Usage:
#
#   bash docker-container.sh [-q] pattern


quiet=
pattern=

while [[ $# > 0 ]]; do
    if [[ "$1" == '-q' ]]; then
        quiet="yes"
    else
        pattern="$1"
    fi
    shift
done

if [[ -n "${quiet}" ]]; then
    if [[ -n "${pattern}" ]]; then
        docker ps -a | tail -n +2 | awk '$2 ~ "'"${pattern}"'" { print $1 }'
    else
        docker ps -aq
    fi
else
    if [[ -n "${pattern}" ]]; then
        header="$(docker ps | head -n 1)"
        echo "${header}"
        docker ps -a | tail -n +2 | awk '$2 ~ "'"${pattern}"'" { print }'
    else
        docker ps -a
    fi
fi
