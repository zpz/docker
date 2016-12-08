set -o nounset
set -o pipefail

thisfile="${BASH_SOURCE[0]}"
thisdir="$( cd "$( dirname "${thisfile}" )" && pwd )"

PARENT="python:3.5.2-slim"

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

cat "$(dirname "${thisdir}")/img_dev_base" >> "${thisdir}/Dockerfile"

cat >> "${thisdir}/Dockerfile" <<'EOF'

# Documentation
# 'graphviz' and 'make' are to be used with Sphinx.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        graphviz \
        make \
    && pip install --no-cache-dir --upgrade \
        'Sphinx==1.4.8' \
    && rm -rf /var/lib/apt/lists/* /tmp/* \
    && apt-get -y autoremove \
    && apt-get clean

# IPython, Jupyter Notebook
# notebook requires (and will install if not available) ipython, pyzmq, tornado, jinja2 and some other things.

RUN pip install --no-cache-dir --upgrade \
        'ipython==5.1.0' \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
    && pip install --no-cache-dir --upgrade \
        'notebook==4.2.3' \
    && apt-get purge -y --auto-remove \
        build-essential \
    && rm -rf /var/lib/apt/lists/* /tmp/* \
    && apt-get -y autoremove \
    && apt-get clean

# By default, Jupyter Notebook uses port 8888.
# Launch a container with Jupyter Notebook server like this:
# $docker run --rm -it --expose=8888 -p 8888:8888 imagename jupyter notebook --port=8888 --no-browser --ip=0.0.0.0 --NotebookApp.notebook_dir=/home/docker-user

# Testing, Debugging, code analysis, code formatting

RUN pip install --no-cache-dir --upgrade \
        'coverage==4.2' \
        'flake8==3.2.1' \
        'ipdb==0.10.1' \
        'pudb==2016.2' \
        'pyflakes==1.3.0' \
        'pylint==1.6.4' \
        'pytest==3.0.4' \
        'yapf==0.14.0'

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
    && pip install --no-cache-dir --upgrade \
        'line_profiler==2.0' \
    && apt-get purge -y --auto-remove \
        build-essential \
    && rm -rf /var/lib/apt/lists/* /tmp/* \
    && apt-get -y autoremove \
    && apt-get clean

CMD ["python"]
EOF

echo
echo Building image "'${NAME}'"
echo
docker build -t "${NAME}" "${thisdir}"

