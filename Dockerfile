FROM ubuntu:20.04 AS build

RUN mkdir -p /opt/esm && cd /opt/esm && umask 0000

# Anaconda
RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        ca-certificates \
        csh \
        git \
        locales \
        python \
        vim \
        wget && \
    rm -rf /var/lib/apt/lists/*
RUN mkdir -p / && wget -q -nc --no-check-certificate -P / http://repo.anaconda.com/miniconda/Miniconda3-py38_4.8.3-Linux-x86_64.sh && \
    bash /Miniconda3-py38_4.8.3-Linux-x86_64.sh -b -p /opt/esm/anaconda && \
    /bin/bash -c "/opt/esm/anaconda/bin/conda init && \
    ln -s /opt/esm/anaconda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    . /opt/esm/anaconda/etc/profile.d/conda.sh && \
    conda activate base && \
    conda config --add channels conda-forge && \
    conda install -y binutils=2.35 cdo=1.9.9 diffutils=3.7 eccodes=2.20.0 gfortran_linux-64=9.3.0 hdf4=4.2.13 make=4.3 mkl=2020.4 mpich=3.4.1 netcdf-fortran=4.5.3=*mpich* openjpeg=2.4.0 perl-xml-parser=2.44 rsync=3.2.3 subversion=1.14.0 tk=8.6.10 && \
    /opt/esm/anaconda/bin/conda clean -afy && \
    rm -rf /Miniconda3-py38_4.8.3-Linux-x86_64.sh"

RUN wget -q -nc --no-check-certificate -P /opt/esm https://github.com/metomi/fcm/archive/refs/tags/2019.09.0.tar.gz && \
    tar -x -f /opt/esm/2019.09.0.tar.gz -C /opt/esm && \
    rm /opt/esm/2019.09.0.tar.gz

RUN sed -i -e "s/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/" /etc/locale.gen && \
    locale-gen

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

ENV PATH=/opt/esm/fcm-2019.09.0/bin:$PATH \
    USER=ubuntu


