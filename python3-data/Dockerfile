# docker build -t zppz/python3-data .

FROM python:3.4

RUN pip3 install --upgrade pip

RUN apt-get update

# development
RUN pip3 install sh arrow click
RUN pip3 install pytest

# numpy, scipy, analytics, modeling
RUN pip3 install numpy
RUN pip3 install pandas

RUN apt-get install -y --no-install-recommends libatlas-base-dev liblapack-dev gfortran
RUN pip3 install scipy
RUN pip3 install patsy statsmodels
RUN pip3 install scikit-learn
RUN pip3 install matplotlib seaborn

# As of 2/04/2016, cvxpy has trouble
# installing on Python-3.5.
RUN pip3 install cvxpy

# database
RUN pip3 install sqlalchemy

# web
RUN pip3 install requests
RUN pip3 install flask
RUN pip3 install bokeh

# HDF5
RUN apt-get install -y --no-install-recommends libhdf5-8 libhdf5-dev
RUN pip3 install h5py

# cleanup
RUN dpkg-reconfigure -au
RUN apt-get -y purge libatlas-base-dev liblapack-dev gfortran libhdf5-dev
RUN apt-get -y autoremove
RUN apt-get clean

