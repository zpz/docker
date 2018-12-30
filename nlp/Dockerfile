# natural language processing

ARG PARENT

FROM ${PARENT}
USER root

RUN pip-install \
        'textblob' \
    && python -m nltk.downloader -d /usr/share/nltk_data \
        brown punkt wordnet averaged_perceptron_tagger \
        conll2000 movie_reviews \
    && pip-install \
        'spacy' \
    && python -m spacy download en

