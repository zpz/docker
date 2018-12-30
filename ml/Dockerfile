# machine learning

ARG PARENT

FROM ${PARENT}
USER root


RUN pip install \
        'scikit-learn' \
        'statsmodels'


RUN echo "deb http://ftp.us.debian.org/debian testing main contrib non-free" >> /etc/apt/sources.list.d/myextrarepo.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        libopenmpi-dev libopenmpi3 \
    && ldconfig \
    && apt-get autoremove -y \
    && rm -f /etc/apt/sources.list.d/myextrarepo.list \
    && rm -rf /var/lib/apt/lists/* /tmp/* \
    && pip install --no-cache-dir --upgrade \
        'lightgbm'


RUN pip install \
        'dask' \
        'distributed' \
        'dask-ml'
