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

WORKDIR /build_dir
RUN git clone https://github.com/tttapa/docker-arm-cross-toolchain.git
RUN conan remote add tttapa-docker-arm-cross-toolchain ./docker-arm-cross-toolchain
RUN apt-get install -y cmake
RUN conan profile detect
COPY . .
RUN conan install . --build=missing -pr ./docker-arm-cross-toolchain/profiles/aarch64-rpi3-linux-gnu.conan
RUN cmake --preset conan-release -DENABLE_EXAMPLES=ON
RUN cmake --build --preset conan-release
