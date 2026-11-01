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
        'cvxpy'


RUN apt-update \
    && apt-install \
        libopenmpi-dev libopenmpi2 \
    && ldconfig \
    && apt-clean \
    && pip-install \
        'lightgbm'


RUN pip-install \
        'nltk' \
        'textblob' \
    && python -m nltk.downloader -d /usr/share/nltk_data \
        brown punkt wordnet averaged_perceptron_tagger \
        conll2000 movie_reviews \
    && pip-install 'spacy' \
    && python -m spacy download en


RUN pip-install \
        'bokeh' 'holoviews' 'chartify' \
        'matplotlib' 'seaborn' 'altair' \
        'plotly'

RUN pip-install dask
