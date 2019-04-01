# deep learning

ARG PARENT

FROM ${PARENT}
USER root


RUN pip-install \
        https://download.pytorch.org/whl/cpu/torch-1.0.1.post2-cp36-cp36m-linux_x86_64.whl \
        torchvision \
        torchtext

RUN pip-install tensorflow==2.0.0a0 tensorflow-probability

RUN pip-install \
        'nltk' \
        'textblob' \
    && python -m nltk.downloader -d /usr/share/nltk_data \
        brown punkt wordnet averaged_perceptron_tagger \
        conll2000 movie_reviews \
    && pip-install 'spacy' \
    && python -m spacy download en

RUN pip-install matplotlib