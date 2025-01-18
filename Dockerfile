FROM ubuntu
LABEL libvad crossbuild-container
RUN apt-get update && \
    apt-get install -y \
    build-essential \
    bash \
    bc \
    binutils \
    build-essential \
    bzip2 \
    cpio \
    g++ \
    gcc \
    git \
    gzip \
    locales \
    libncurses5-dev \
    libdevmapper-dev \
    libsystemd-dev \
    make \
    mercurial \
    whois \
    patch \
    perl \
    python3 \
    rsync \
    sed \
    tar \
    vim \ 
    unzip \
    wget \
    bison \
    flex \
    libssl-dev \
    libfdt-dev \
    file

# Sometimes Buildroot need proper locale, e.g. when using a toolchain
# based on glibc.
RUN locale-gen en_US.utf8
RUN echo 'alias python=python3' > ~/.bashrc
RUN apt-get install -y pipx
RUN pipx ensurepath
RUN pipx install conan
RUN ln -s ~/.local/bin/conan /usr/bin/conan
# ## https://elliottback.medium.com/python-this-environment-is-externally-managed-error-and-docker-6062aac20a6e
# RUN rm /usr/lib/python*/EXTERNALLY-MANAGED && \
#     python3 -m ensurepip && \
#     pip install conan

# Download this repository and add its recipes to Conan
WORKDIR /build_dir
RUN git clone https://github.com/tttapa/docker-arm-cross-toolchain.git
RUN conan remote add tttapa-docker-arm-cross-toolchain ./docker-arm-cross-toolchain
COPY conanfile.txt /build_dir/deps/conanfile.txt
RUN apt-get install -y cmake
RUN conan profile detect
RUN conan install /build_dir/deps/ --build=missing -pr /build_dir/docker-arm-cross-toolchain/profiles/aarch64-rpi3-linux-gnu.conan