FROM ubuntu:22.04 AS build-stage

ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH \
    RUST_VERSION=1.63.0

RUN apt-get update && \
    apt-get install -y wget python3 python3-pip git

RUN set -eux; \
    rustArch="x86_64-unknown-linux-gnu"; \
    url="https://static.rust-lang.org/rustup/archive/1.25.1/${rustArch}/rustup-init"; \
    wget --quiet "$url"; \
    chmod +x rustup-init; \
    ./rustup-init -y --no-modify-path --default-toolchain $RUST_VERSION --default-host ${rustArch}; \
    rm rustup-init; \
    chmod -R a+w $RUSTUP_HOME $CARGO_HOME; \
    rustup --version; \
    cargo --version; \
    rustc --version;

RUN python3 --version; pip install maturin

RUN git clone https://github.com/pravega/pravega-client-rust.git; \
    cd pravega-client-rust/python && \
    cargo build && \
    maturin build --release --strip --manylinux off

FROM scratch AS export-stage
COPY --from=build-stage /pravega-client-rust/target/wheels/*.whl /
