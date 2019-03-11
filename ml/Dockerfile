# machine learning

ARG PARENT

FROM ${PARENT}
USER root


RUN pip-install \
        'numpy==1.16.0' \
        'scipy==1.2.0' \
        'numba==0.42.0' \
        \
        'pandas==0.24.0' \
        'scikit-learn==0.20.2' \
        'statsmodels==0.9.0' \
        'xgboost==0.81' \
        'cvxpy==1.0.14' \
        'lifelines==0.17.5'


RUN echo "deb http://ftp.us.debian.org/debian testing main contrib non-free" >> /etc/apt/sources.list.d/myextrarepo.list \
    && apt-update \
    && apt-install \
        libopenmpi-dev=3.1.3-10 libopenmpi3=3.1.3-10 \
    && ldconfig \
    && rm -f /etc/apt/sources.list.d/myextrarepo.list \
    && apt-clean \
    && pip-install \
        'lightgbm==2.2.2'


RUN pip-install \
        'bokeh==1.0.4' 'holoviews==1.11.2' 'chartify==2.3.5' \
        'matplotlib==3.0.2' 'seaborn==0.9.0' 'altair==2.3.0' \
        'plotly==3.5.0' 'dash==0.36.0'

# 'gif' support in Holoviews requires ImageMagick
RUN apt-update \
    && apt-install \
        imagemagick=8:6.9.7.4+dfsg-11+deb9u6 \
    && apt-clean
