# natural language processing

ARG PARENT

FROM ${PARENT}
USER root

RUN pip-install \
        'nltk==3.4' \
        'textblob==0.15.2' \
    && python -m nltk.downloader -d /usr/share/nltk_data \
        brown punkt wordnet averaged_perceptron_tagger \
        conll2000 movie_reviews \
    && pip-install 'spacy==2.0.18' \
    && python -m spacy download en

