set -o nounset
set -o pipefail

thisfile="${BASH_SOURCE[0]}"
thisdir="$( cd "$( dirname "${thisfile}" )" && pwd )"

image="$(cat "${thisdir}/name"):$(cat "${thisdir}/version")"

bindir="${HOME}/bin"
cmdname=py3
target="${bindir}/${cmdname}"

echo "installing '${cmdname}' into '${bindir}'"
cat > "${target}" <<EOF
#!/usr/bin/env bash

if [[ \$# > 2 ]]; then
    shift
    docker run --rm -it "${image}" \$@
else
    docker run --rm -it "${image}" python
fi
EOF

chmod +x "${target}"

