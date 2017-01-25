set -o nounset
set -o pipefail

cmdname=py3skl-dev
hostworkdir="${HOME}/work"
dockeruser=docker-user
defaultcmd=/bin/bash

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

workdir="${dockerworkdir}/src/github-zpz/scikit-learn"

ARGS="\\
    -v "${hostworkdir}":"${dockerworkdir}" \\
    -e CFGDIR="${dockerworkdir}/config" \\
    -e LOGDIR="${dockerworkdir}/log" \\
    -e DATADIR="${dockerworkdir}/data" \\
    -e TMPDIR="${dockerworkdir}/tmp" \\
    -e PYTHONPATH="${dockerworkdir}/src/github-zpz/scikit-learn" \
    -u ${dockeruser} \\
    --rm -it \\
    -e TZ=America/Los_Angeles"

if (( \$# > 0 )); then
    if [[ "\$1" == "ipynb" ]]; then
        ARGS="\${ARGS} \\
    --expose=8888 \\
    -p 8888:8888"
        workdir="${dockerworkdir}"
        shift
        command="jupyter notebook --port=8888 --no-browser --ip=0.0.0.0 \\
            --NotebookApp.notebook_dir='\${workdir}' --NotebookApp.token='' \$@"
    else
        command="\$@"
    fi
else
    command="${defaultcmd}"
fi

ARGS="\${ARGS} \\
    -w "\${workdir}""

docker run \${ARGS} ${imgname}:${imgversion} \$command
EOF


echo "installing '${cmdname}' into '${bindir}'"...
mv -f "${localtarget}" "${target}"
chmod +x "${target}"
