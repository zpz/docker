#!/bin/bash

if [ -n "${HOST_UID}" ] && [ -n "${HOST_GID}" ]; then
    usermod -u ${HOST_UID} docker-user
    groupmod -g ${HOST_GID} docker-user
fi

exec "$@"
