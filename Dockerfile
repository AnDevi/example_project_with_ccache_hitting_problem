FROM ubuntu:20.04

WORKDIR /build

ARG USER_NAME=ubuntu
ARG USER_UID=998
ARG USER_GID=997

ARG DEBIAN_FRONTEND=noninteractive

RUN  apt-get -y update \
    && echo "Setup: user + sudo" \
    && apt-get -qy install --no-install-recommends sudo \
    && if [ $USER_GID != 20 ]; then groupadd -g ${USER_GID} ${USER_NAME} ; fi \
    && useradd -m -u ${USER_UID} -g ${USER_GID} -o -s /bin/bash ${USER_NAME} \
    && usermod -a -G sudo ${USER_NAME} \
    && echo "${USER_NAME}         ALL = (ALL) NOPASSWD: ALL" >> /etc/sudoers 

RUN echo "Install clang" \
    && apt-get -y install clang libc++-dev libc++abi-dev \
    && echo "Install qbs" \
    && apt-get install -y qbs cmake

# Configure qbs
RUN qbs setup-toolchains --detect --system \
    && qbs setup-qt --system /usr/bin/cmake custom_clang \
    && qbs config --system profiles.custom_clang.cpp.cCompilerName clang \
    && qbs config --system profiles.custom_clang.cpp.compilerName clang++ \
    && qbs config --system profiles.custom_clang.cpp.cxxCompilerName clang++ \
    && qbs config --system profiles.custom_clang.cpp.toolchainInstallPath /usr/bin \
    && qbs config --system profiles.custom_clang.qbs.toolchainType clang

# Configure ccache
COPY docker_resources/ccache /usr/local/bin/
ENV CCACHE_CONFIGPATH /ccache/config

RUN mkdir -p /ccache
COPY docker_resources/config /ccache/config
RUN chown -R ${USER_NAME} /build
RUN chown -R ${USER_NAME} /ccache

USER ${USER_NAME}
