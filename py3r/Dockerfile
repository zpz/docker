FROM python:3.4


RUN apt-get update && apt-get install -y --no-install-recommends \
    liblapack-dev gfortran \
    libhdf5-8 libhdf5-dev \
    r-base

RUN pip3 install -U pip setuptools wheel && \
      # Numerical, modeling, analytics \
    pip3 install numpy==1.10.4 pandas==0.17.1 && \
    pip3 install matplotlib==1.5.1

RUN \
    pip3 install scipy==0.17.0 patsy==0.4.1 statsmodels==0.6.1 scikit-learn==0.17 seaborn==0.7.0 && \
    pip3 install cvxpy==0.3.7

RUN \
      # Database, data formats \
    pip3 install sqlalchemy==1.0.11 redis==2.10.5 && \
    pip3 install h5py==2.5.0 && \
      # Networking, system
    pip3 install requests==2.9.1 flask==0.10.1 bokeh==0.11.1 && \
      # Development, misc
    pip3 install sh==1.11 arrow==0.7.0 click==6.2 pytest==2.8.7 Sphinx==1.3.5 && \
    pip3 install ipython==4.1.1 notebook==4.1.0

# As of 2/04/2016, cvxpy has trouble
# installing on Python-3.5.

# libatlas-base-dev


# cleanup
RUN dpkg-reconfigure -au && \
    apt-get -y purge libatlas-base-dev liblapack-dev gfortran libhdf5-dev && \
    apt-get -y autoremove && \
    apt-get clean

CMD ipython

