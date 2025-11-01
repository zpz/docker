#!/usr/bin/bash

if [[ "${USER}" == root ]]; then
    exec "$@"
else
    if [[ -n "${HOST_UID}" && -n "${HOST_GID}" ]]; then
        usermod -u ${HOST_UID} docker-user > /dev/null
        groupmod -g ${HOST_GID} docker-user > /dev/null
    fi

    exec gosu docker-user "$@"
fi
