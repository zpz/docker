# machine learning

ARG PARENT

FROM ${PARENT}
USER root


RUN pip-install \
        'scikit-learn' \
        'statsmodels' \
        'pandas==0.24.0' \
        'scipy==1.2.0' \
        'distributed' \
        'dask'

RUN echo "deb http://ftp.us.debian.org/debian testing main contrib non-free" >> /etc/apt/sources.list.d/myextrarepo.list \
    && apt-get update \
    && apt-get-install \
        libopenmpi-dev libopenmpi3 \
    && ldconfig \
    && apt-get autoremove -y \
    && rm -f /etc/apt/sources.list.d/myextrarepo.list \
    && apt-get-clean \
    && pip-install \
        'lightgbm'
