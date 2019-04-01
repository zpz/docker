# machine learning

ARG PARENT

FROM ${PARENT}
USER root


RUN pip-install \
        'numpy' \
        'scipy' \
        'numba' \
        \
        'pandas' \
        'scikit-learn' \
        'statsmodels' \
        'xgboost' \
        'cvxpy' \
        'lifelines'


RUN apt-update \
    && apt-install \
        libopenmpi-dev libopenmpi2 \
    && ldconfig \
    && apt-clean \
    && pip-install \
        'lightgbm'


RUN pip-install \
        'bokeh' 'holoviews' 'chartify' \
        'matplotlib' 'seaborn' 'altair' \
        'plotly' 'dash'

# 'gif' support in Holoviews requires ImageMagick
RUN apt-update \
    && apt-install \
        imagemagick \
    && apt-clean
