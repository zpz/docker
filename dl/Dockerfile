# deep learning

ARG PARENT

FROM ${PARENT}
USER root


RUN pip-install \
        https://download.pytorch.org/whl/cpu/torch-1.0.1.post2-cp37-cp37m-linux_x86_64.whl \
        torchvision==0.2.1 \
        torchtext==0.3.1

RUN pip-install tensorflow tensorflow-probability

RUN pip-install \
        'nltk==3.4' \
        'textblob==0.15.2' \
    && python -m nltk.downloader -d /usr/share/nltk_data \
        brown punkt wordnet averaged_perceptron_tagger \
        conll2000 movie_reviews \
    && pip-install 'spacy==2.0.18' \
    && python -m spacy download en

RUN pip-install matplotlib==3.0.2