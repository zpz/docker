set -o nounset
set -o pipefail

thisfile="${BASH_SOURCE[0]}"
thisdir="$( cd "$( dirname "${thisfile}" )" && pwd )"
workdir="${HOME}/work"
bindir="${workdir}/bin"


datadir="${workdir}/data"
if [[ -d "${datadir}" ]]; then
    if [[ -L "${datadir}" ]]; then
        echo "!!! ERROR !!! '${datadir}' is not a real directory but is a symlink. Please delete it and try again."
        return 1
    fi
else
    mkdir -p "${datadir}"
fi


imgname=$(cat "${thisdir}/name")
imgversion=$(cat "${thisdir}/version")

containername="local-docker-mysql"

cmdname=start-mysql
target="${bindir}/${cmdname}"
echo installing "'${cmdname}'" into "'${bindir}'"
if [[ -f "${target}" ]]; then
    if ! grep -q 'docker run' "${target}"; then
        echo "'${target}' already exists and it doesn't look like a file I created before; don't know how to proceed!"
        exit 1
    fi
fi
cat > "${target}" <<EOF
#!/usr/bin/env bash

container_id="\$(docker ps --filter 'name=${containername}' -aq)"

if [[ -z "\$container_id" ]]; then
    echo starting container ${containername}...
    docker run \\
        --name ${containername} \\
        -e MYSQL_ROOT_PASSWORD=1234 \\
        -v ${datadir}/${containername}:/var/lib/mysql \\
        -d \\
        -p 3306:3306 \\
        ${imgname}:${imgversion}
else
    status=\$(expr "\$(docker ps --filter "id=\${container_id}" -a --format '{{.Status}}')" : '\([a-zA-Z]*\) .*')
    if [[ "\$status" != "Up" ]]; then
        echo restarting container ${containername} ...
        docker restart ${containername}
    fi
fi

container_ip=\$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' "${containername}")

(( $? == 0 )) && echo "local PostgreSQL server running in container '${containername}' at '\${container_ip}:5432'"
EOF
chmod +x "${target}"


cmdname=stop-mysql
target="${bindir}/${cmdname}"
echo installing "'${cmdname}'" into "'${bindir}'"
if [[ -f "${target}" ]]; then
    if ! grep -q 'docker stop' "${target}"; then
        echo "'${target}' already exists and it doesn't look like a file I created before; don't know how to proceed!"
        return 1
    fi
fi
cat > "${target}" <<EOF
#!/usr/bin/env bash

container_id="\$(docker ps --filter 'name=${containername}' -aq)"

if [[ -n "\$container_id" ]]; then
    status=\$(expr "\$(docker ps --filter "id=\${container_id}" -a --format '{{.Status}}')" : '\([a-zA-Z]*\) .*')
    if [[ "\$status" == "Up" ]]; then
        echo stopping container ${containername} ...
        docker stop ${containername}
    fi
fi
EOF
chmod +x "${target}"


cmdname=ip-mysql
target="${bindir}/${cmdname}"
echo installing "'${cmdname}'" into "'${bindir}'"
if [[ -f "${target}" ]]; then
    if ! grep -q 'docker inspect' "${target}"; then
        echo "'${target}' already exists and it doesn't look like a file I created before; don't know how to proceed!"
        return 1
    fi
fi
cat > "${target}" <<EOF
#!/usr/bin/env bash

container_id="\$(docker ps --filter 'name=${containername}' -aq)"

if [[ -n "\$container_id" ]]; then
    status=\$(expr "\$(docker ps --filter "id=\${container_id}" -a --format '{{.Status}}')" : '\([a-zA-Z]*\) .*')
    if [[ "\$status" == "Up" ]]; then
        container_ip=\$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' "${containername}")
        echo "local MySQL server running in container '${containername}' at '\${container_ip}:3306'"
    else
        echo container '${containername}' is not running
    fi
else
    echo container '${containername}' does not exist
fi
EOF
chmod +x "${target}"


