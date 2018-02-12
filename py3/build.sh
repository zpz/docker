set -o nounset
set -o pipefail

thisfile="${BASH_SOURCE[0]}"
thisdir="$( cd "$( dirname "${thisfile}" )" && pwd )"

PARENT="python:3.5.5-slim"

version=$(cat "${thisdir}"/version)
NAME="$(cat "${thisdir}/name"):${version}"


echo
echo =====================================================
echo Creating Dockerfile for "'${NAME}'"
cat > "${thisdir}"/Dockerfile <<EOF
# Dockerfile for image '${NAME}'
# Generated by 'build.sh'.
#
# DO NOT EDIT.

FROM ${PARENT}

USER root
EOF

cp -r ../dotfiles .

cat "$(dirname "${thisdir}")/base.in" >> "${thisdir}/Dockerfile"
cat "$(dirname "${thisdir}")/nvim.in" >> "${thisdir}/Dockerfile"

cat >> "${thisdir}/Dockerfile" <<'EOF'
RUN pip install --no-cache-dir --upgrade \
        'pip==9.0.1' \
        'setuptools==38.5.1' \
        \
        'numpy==1.14.0' \
        'requests==2.18.4' \
        \
        'coverage==4.5.1' \
        'pytest==3.4.0'
EOF

cat ./pydev.in >> "${thisdir}/Dockerfile"

echo
echo Building image "'${NAME}'"
echo
docker build -t "${NAME}" "${thisdir}"
rm -rf dotfiles

