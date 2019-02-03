# deep learning

ARG PARENT

FROM ${PARENT}
USER root


RUN pip-install \
        https://download.pytorch.org/whl/cpu/torch-1.0.0-cp36-cp36m-linux_x86_64.whl \
        torchvision==0.2.1 \
        torchtext==0.3.1

RUN pip-install tensorflow==1.12.0 tensorflow-probability==0.5.0
