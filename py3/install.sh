set -o nounset
set -o pipefail

cmdname=py3
hostworkdir="${HOME}/work"
dockeruser=docker-user
defaultcmd=python

thisfile="${BASH_SOURCE[0]}"
thisdir="$( cd "$( dirname "${thisfile}" )" && pwd )"
dockerworkdir="/home/${dockeruser}/$(basename "${hostworkdir}")"

imgname=$(cat "${thisdir}/name")
imgversion=$(cat "${thisdir}/version")

bindir="${hostworkdir}/bin"
target="${bindir}/${cmdname}"
localtarget="${thisdir}/${cmdname}"

echo "creating '${cmdname}' in current directory"...
cat > "${localtarget}" <<EOF
#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

launchdir=\$(pwd)
if [[ "\${launchdir}" == "${hostworkdir}"* ]]; then
    workdir="${dockerworkdir}""\${launchdir#${hostworkdir}}"
else
    workdir="${dockerworkdir}"
fi

ARGS="\\
    -v "${hostworkdir}":"${dockerworkdir}" \\
    -e CFGDIR="${dockerworkdir}/config" \\
    -e LOGDIR="${dockerworkdir}/log" \\
    -e DATADIR="${dockerworkdir}/data" \\
    -e TMPDIR="${dockerworkdir}/tmp" \\
    -e ENVIRONMENT_NAME=${imgname} \\
    -u ${dockeruser} \\
    --rm -it \\
    --expose=8888 \\
    -p 8888:8888 \\
    -w "\${workdir}" \\
    -e TZ=America/Los_Angeles"

if (( \$# > 0 )); then
    command="\$@"
else
    command="${defaultcmd}"
fi

docker run \${ARGS} ${imgname}:${imgversion} \$command
EOF


echo "installing '${cmdname}' into '${bindir}'"...
mv -f "${localtarget}" "${target}"
chmod +x "${target}"

