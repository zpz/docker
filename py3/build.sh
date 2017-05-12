set -o nounset
set -o pipefail

thisfile="${BASH_SOURCE[0]}"
thisdir="$( cd "$( dirname "${thisfile}" )" && pwd )"

PARENT="python:3.5.3-slim"

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

cat "$(dirname "${thisdir}")/base.in" >> "${thisdir}/Dockerfile"

cat >> "${thisdir}/Dockerfile" <<'EOF'

# Documentation, testing, debugging, code analysis, code formatting.
# IPython, Jupyter Notebook.
# Notebook requires (and will install if not available) ipython, pyzmq, tornado, jinja2 and some other things.

RUN pip install --no-cache-dir --upgrade \
        'pip==9.0.1' \
        'setuptools==35.0.2' \
    && pip install --no-cache-dir --upgrade \
        'coverage==4.3.4' \
        'memory_profiler==0.47' \
        'mypy==0.510' \
        'pylint==1.7.1' \
        'pytest==3.0.7' \
    && pip install --no-cache-dir --upgrade \
        'ipdb==0.10.3' \
        'ipython==6.0.0' \
        'notebook==5.0.0' \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        graphviz \
    && pip install --no-cache-dir --upgrade \
        'Sphinx>=1.5.5' \
    && apt-get install -y --no-install-recommends \
        gcc \
        libc6-dev \
    && pip install --no-cache-dir --upgrade \
        'line_profiler==2.0' \
    && apt-get purge -y --auto-remove \
        gcc \
        libc6-dev \
    && rm -rf /var/lib/apt/lists/* /tmp/* \
    && pip install --no-cache-dir --upgrade \
        'numpy==1.12.1'

# Installing `line_profiler` needs gcc.
# Use `snakeviz` to view profiling stats.
# `snakeviz` is not installed in this Docker image as it's better
# installed on the hosting machine 'natively'.
#

# By default, Jupyter Notebook uses port 8888.
# Launch a container with Jupyter Notebook server like this:
# $docker run --rm -it --expose=8888 -p 8888:8888 imagename jupyter notebook --port=8888 --no-browser --ip=0.0.0.0 --NotebookApp.notebook_dir=/home/docker-user --NotebookApp.token=''

# EXPOSE 8888
#
# RUN echo '#!/usr/bin/env bash' > /usr/local/bin/ipynb \
#     && echo >> /usr/local/bin/ipynb \
#     && echo "jupyter notebook --port=8888 --no-browser --ip=0.0.0.0 --NotebookApp.notebook_dir=\~ --NotebookApp.token=''" >> /usr/local/bin/ipynb \\
#     && chmod +x /usr/local/bin/ipynb

# Other useful packages:
#    flake8
#    pudb
#    pyflakes
#    radon
#    yapf
#    cython
#    easycython

# Other packages often useful for software development:
#    autoconf=2.69-8 \
#    automake=1:1.14.1-4+deb8u1 \
#    binutils=2.25-5
#    libtool=2.4.2-1.11 \
#    zlib1g-dev=1:1.2.8.dfsg-2+b1 \
#    gcc=4:4.9.2-2 \
#    libc6-dev=2.19-18+deb8u7 \
#    make=4.0-8.1 \
#
# `binutils` contains `gprof`.
# To use `gprof`, use option `-pg` during both compiling and linking.
EOF

echo
echo Building image "'${NAME}'"
echo
docker build -t "${NAME}" "${thisdir}"

