# based on the Dockerfile of the official `rust` Docker image on dockerhub.

ARG PARENT

FROM ${PARENT}
USER root


ENV RUSTUP_HOME=/usr/local/rustup
ENV CARGO_HOME=/usr/local/cargo
ENV PATH=/usr/local/cargo/bin:$PATH

RUN rustArch='x86_64-unknown-linux-gnu'; \
    rustupSha256='c9837990bce0faab4f6f52604311a19bb8d2cde989bea6a7b605c8e526db6f02'; \
    url="https://static.rust-lang.org/rustup/archive/1.11.0/${rustArch}/rustup-init"; \
    curl ${url} -O; \
    echo "${rustupSha256} *rustup-init" | sha256sum -c -; \
    chmod +x rustup-init; \
    ./rustup-init -y --no-modify-path --default-toolchain 1.24.0; \
    rm rustup-init; \
    chmod -R a+w ${RUSTUP_HOME} ${CARGO_HOME}; \
    ln -s /usr/bin/gcc /usr/bin/cc; \
    rustup --version; \
    cargo --version; \
    rustc --version;

# rust will look for linker called `cc`; created a link to use gcc.

