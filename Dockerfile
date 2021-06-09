FROM ubuntu:21.04

# GNU compiler
RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        g++-10 \
        gcc-10 \
        gfortran-10 && \
    rm -rf /var/lib/apt/lists/*
RUN update-alternatives --install /usr/bin/g++ g++ $(which g++-10) 30 && \
    update-alternatives --install /usr/bin/gcc gcc $(which gcc-10) 30 && \
    update-alternatives --install /usr/bin/gcov gcov $(which gcov-10) 30 && \
    update-alternatives --install /usr/bin/gfortran gfortran $(which gfortran-10) 30

# MPICH version 3.4.2
RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        file \
        gzip \
        make \
        openssh-client \
        perl \
        tar \
        wget && \
    rm -rf /var/lib/apt/lists/*
RUN mkdir -p /var/tmp && wget -q -nc --no-check-certificate -P /var/tmp https://www.mpich.org/static/downloads/3.4.2/mpich-3.4.2.tar.gz && \
    mkdir -p /var/tmp && tar -x -f /var/tmp/mpich-3.4.2.tar.gz -C /var/tmp -z && \
    cd /var/tmp/mpich-3.4.2 &&   ./configure --prefix=/usr/local/mpich --with-device=ch3 FCFLAGS=-fallow-argument-mismatch FFLAGS=-fallow-argument-mismatch && \
    make -j$(nproc) && \
    make -j$(nproc) install && \
    rm -rf /var/tmp/mpich-3.4.2 /var/tmp/mpich-3.4.2.tar.gz
ENV LD_LIBRARY_PATH=/usr/local/mpich/lib:$LD_LIBRARY_PATH \
    PATH=/usr/local/mpich/bin:$PATH

# HDF5 version 1.12.0
RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        bzip2 \
        file \
        make \
        wget \
        zlib1g-dev && \
    rm -rf /var/lib/apt/lists/*
RUN mkdir -p /var/tmp && wget -q -nc --no-check-certificate -P /var/tmp http://www.hdfgroup.org/ftp/HDF5/releases/hdf5-1.12/hdf5-1.12.0/src/hdf5-1.12.0.tar.bz2 && \
    mkdir -p /var/tmp && tar -x -f /var/tmp/hdf5-1.12.0.tar.bz2 -C /var/tmp -j && \
    cd /var/tmp/hdf5-1.12.0 &&  CC=mpicc CXX=mpicxx F77=mpif77 F90=mpif90 FC=mpifort ./configure --prefix=/usr/local/hdf5 --disable-cxx --enable-fortran --enable-parallel --with-zlib && \
    make -j$(nproc) && \
    make -j$(nproc) install && \
    rm -rf /var/tmp/hdf5-1.12.0 /var/tmp/hdf5-1.12.0.tar.bz2
ENV CPATH=/usr/local/hdf5/include:$CPATH \
    HDF5_DIR=/usr/local/hdf5 \
    LD_LIBRARY_PATH=/usr/local/hdf5/lib:$LD_LIBRARY_PATH \
    LIBRARY_PATH=/usr/local/hdf5/lib:$LIBRARY_PATH \
    PATH=/usr/local/hdf5/bin:$PATH

# NetCDF version 4.7.4, NetCDF Fortran version 4.5.3
RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        ca-certificates \
        file \
        libcurl4-openssl-dev \
        m4 \
        make \
        wget \
        zlib1g-dev && \
    rm -rf /var/lib/apt/lists/*
RUN mkdir -p /var/tmp && wget -q -nc --no-check-certificate -P /var/tmp https://github.com/Unidata/netcdf-c/archive/v4.7.4.tar.gz && \
    mkdir -p /var/tmp && tar -x -f /var/tmp/v4.7.4.tar.gz -C /var/tmp -z && \
    cd /var/tmp/netcdf-c-4.7.4 &&  CC=mpicc CXX=mpicxx F77=mpif77 F90=mpif90 FC=mpifort ./configure --prefix=/usr/local/netcdf --enable-netcdf4 && \
    make -j$(nproc) && \
    make -j$(nproc) install && \
    rm -rf /var/tmp/netcdf-c-4.7.4 /var/tmp/v4.7.4.tar.gz
ENV CPATH=/usr/local/netcdf/include:$CPATH \
    LD_LIBRARY_PATH=/usr/local/netcdf/lib:$LD_LIBRARY_PATH \
    LIBRARY_PATH=/usr/local/netcdf/lib:$LIBRARY_PATH \
    PATH=/usr/local/netcdf/bin:$PATH
RUN mkdir -p /var/tmp && wget -q -nc --no-check-certificate -P /var/tmp https://github.com/Unidata/netcdf-fortran/archive/v4.5.3.tar.gz && \
    mkdir -p /var/tmp && tar -x -f /var/tmp/v4.5.3.tar.gz -C /var/tmp -z && \
    cd /var/tmp/netcdf-fortran-4.5.3 &&  CC=mpicc CXX=mpicxx F77=mpif77 F90=mpif90 FC=mpifort ./configure --prefix=/usr/local/netcdf --enable-netcdf4 && \
    make -j$(nproc) && \
    make -j$(nproc) install && \
    rm -rf /var/tmp/netcdf-fortran-4.5.3 /var/tmp/v4.5.3.tar.gz

# OpenBLAS version 0.3.9
RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        make \
        perl \
        tar \
        wget && \
    rm -rf /var/lib/apt/lists/*
RUN mkdir -p /var/tmp && wget -q -nc --no-check-certificate -P /var/tmp https://github.com/xianyi/OpenBLAS/archive/v0.3.9.tar.gz && \
    mkdir -p /var/tmp && tar -x -f /var/tmp/v0.3.9.tar.gz -C /var/tmp -z && \
    cd /var/tmp/OpenBLAS-0.3.9 && \
    make CC=gcc FC=gfortran USE_OPENMP=1 && \
    mkdir -p /usr/local/openblas && \
    cd /var/tmp/OpenBLAS-0.3.9 && \
    make install PREFIX=/usr/local/openblas && \
    rm -rf /var/tmp/OpenBLAS-0.3.9 /var/tmp/v0.3.9.tar.gz
ENV LD_LIBRARY_PATH=/usr/local/openblas/lib:$LD_LIBRARY_PATH

# Eccodes-2.22.0
RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        cmake && \
    rm -rf /var/lib/apt/lists/*
RUN mkdir -p /var/tmp && wget -q -nc --no-check-certificate -P /var/tmp https://confluence.ecmwf.int/download/attachments/45757960/eccodes-2.22.0-Source.tar.gz && \
    mkdir -p /var/tmp && tar -x -f /var/tmp/eccodes-2.22.0-Source.tar.gz -C /var/tmp -z && \
    mkdir -p /var/tmp/eccodes-2.22.0-Source/build && cd /var/tmp/eccodes-2.22.0-Source/build && \
    cmake -DCMAKE_INSTALL_PREFIX=/usr/local/eccodes ../ && \
    make -j$(nproc) && \
    make -j$(nproc) install && \
    rm -rf /var/tmp/eccodes-2.22.0-Source /var/tmp/eccodes-2.22.0-Source.tar.gz
ENV ECCODES_DIR=/usr/local/eccodes \
    CPATH=$ECCODES_DIR/include:$CPATH \
    LD_LIBRARY_PATH=$ECCODES_DIR/lib:$LD_LIBRARY_PATH \
    LIBRARY_PATH=$ECCODES_DIR/lib:$LIBRARY_PATH \
    PATH=$ECCODES_DIR/bin:$PATH

RUN mkdir -p /opt/esm && cd /opt/esm && umask 0000

RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        binutils \
        ca-certificates \
        csh \
        git \
        locales \
        make \
        nano \
        python \
        rsync \
        subversion && \
    rm -rf /var/lib/apt/lists/*

RUN wget -q -nc --no-check-certificate -P /opt/esm https://github.com/metomi/fcm/archive/refs/tags/2021.05.0.tar.gz && \
    tar -x -f /opt/esm/2021.05.0.tar.gz -C /opt/esm && \
    rm /opt/esm/2021.05.0.tar.gz

RUN sed -i -e "s/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/" /etc/locale.gen && \
    locale-gen

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

ENV PATH=/opt/esm/fcm-2019.09.0/bin:$PATH \
    USER=ubuntu
