set -o nounset
set -o pipefail

cmdname=py34
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
    -u ${dockeruser} \\
    -e ENVIRONMENT_NAME=${imgname} \\
    -w "\${workdir}" \\
    --rm -it \\
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

