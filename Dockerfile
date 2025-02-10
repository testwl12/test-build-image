FROM rust:1.82 AS builder
WORKDIR /usr/src

RUN apt-get update -y && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    clang \
    curl \
    protobuf-compiler \
    libprotobuf-dev \
    mold \
    wget \
    && rm -rf /var/lib/apt/lists/*


# Download and configure OpenSSL
ARG OPENSSL_VERSION=3.1.0 # 
RUN wget https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz && \
    tar -xzf openssl-${OPENSSL_VERSION}.tar.gz && \
    cd openssl-${OPENSSL_VERSION} && \
    ./Configure --prefix=/usr/local --disable-shared --with-zlib-include=/usr/include --with-zlib-lib=/usr/lib CFLAGS="-O2 -g0" && \ # Optimize tu use less memory
    make -j2 && \ # 2 cores limited
    make install && \
    cd .. && \
    rm -rf openssl-${OPENSSL_VERSION}* 
ENV OPENSSL_DIR="/usr/local/ssl"
ENV OPENSSL_INCLUDE_DIR="/usr/local/include"
ENV OPENSSL_LIB_DIR="/usr/local/lib"
RUN apt-get update -y && apt-get install -y --no-install-recommends libssl-dev && rm -rf /var/lib/apt/lists/*

RUN rustup component add rustfmt clippy \
    && rustup target add wasm32-unknown-unknown \
    && cargo install wasm-tools
