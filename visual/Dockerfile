ARG PARENT

FROM ${PARENT}
USER root


RUN pip-install \
        'bokeh' 'holoviews' 'chartify' \
        'matplotlib' 'seaborn' \
        'plotly' 'dash'

# 'gif' support in Holoviews requires ImageMagick
RUN apt-get update \
    && apt-get-install \
        imagemagick \
    && apt-get-clean
