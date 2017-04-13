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

#===========================
# Generated by 'build.sh'.
#
# DO NOT EDIT.
#===========================

FROM ${PARENT}

USER root
WORKDIR /

EOF

cat "$(dirname "${thisdir}")/base.in" >> "${thisdir}/Dockerfile"
cat "$(dirname "${thisdir}")/dev.in" >> "${thisdir}/Dockerfile"

cat >> "${thisdir}/Dockerfile" <<'EOF'

# Documentation
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        graphviz \
    && pip install --no-cache-dir --upgrade \
        'Sphinx>=1.5.5' \
    && rm -rf /var/lib/apt/lists/* /tmp/* \
    && apt-get autoremove -y \
    && apt-get clean -y

# Testing, Debugging, code analysis, code formatting.
# IPython, Jupyter Notebook, other commomly useful packages.
# Notebook requires (and will install if not available) ipython, pyzmq, tornado, jinja2 and some other things.

RUN pip install --no-cache-dir --upgrade \
        'pip' \
        'setuptools' \
    && pip install --no-cache-dir --upgrade \
        'coverage>=4.3.4' \
        'Faker>=0.7.11' \
        'flake8>=3.2.1' \
        'line_profiler>=2.0' \
        'memory_profiler>=0.45' \
        'mypy>=0.501' \
        'pudb>=2016.2' \
        'pyflakes>=1.5.0' \
        'pylint>=1.6.5' \
        'pytest>=3.0.7' \
        'radon>=1.4.2' \
        'yapf>=0.15.2' \
    && pip install --no-cache-dir --upgrade \
        'ipdb>=0.10.2' \
        'ipython==5.3.0' \
        'notebook==5.0.0' \
    && pip install --no-cache-dir --upgrade \
        'numpy==1.12.1' \
        'requests==2.13.0'


# Use `snakeviz` to view profiling stats.
# `snakeviz` is not installed in this Docker image as it's better
# installed on the hosting machine 'natively'.

# By default, Jupyter Notebook uses port 8888.
# Launch a container with Jupyter Notebook server like this:
# $docker run --rm -it --expose=8888 -p 8888:8888 imagename jupyter notebook --port=8888 --no-browser --ip=0.0.0.0 --NotebookApp.notebook_dir=/home/docker-user --NotebookApp.token=''

# EXPOSE 8888
#
# RUN echo '#!/usr/bin/env bash' > /usr/local/bin/ipynb \
#     && echo >> /usr/local/bin/ipynb \
#     && echo "jupyter notebook --port=8888 --no-browser --ip=0.0.0.0 --NotebookApp.notebook_dir=\~ --NotebookApp.token=''" >> /usr/local/bin/ipynb \\
#     && chmod +x /usr/local/bin/ipynb


CMD ["python"]
EOF

echo
echo Building image "'${NAME}'"
echo
docker build -t "${NAME}" "${thisdir}"

