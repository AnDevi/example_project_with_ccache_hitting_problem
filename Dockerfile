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
    && qbs config --system profiles.custom_clang.cpp.compilerWrapper ccache \
    && qbs config --system profiles.custom_clang.qbs.toolchainType clang

# Configure ccache
COPY docker_resources/ccache /usr/local/bin/

ENV CCACHE_DIR /ccache
ENV CCACHE_CONFIGPATH /ccache/config

# Modules requires both direct and depend mode.
ENV CCACHE_CPP2=true
ENV CCACHE_DEPEND=true
ENV CCACHE_DIRECT=true
# Faster file copying (cloning).
ENV CCACHE_FILECLONE=true
ENV CCACHE_INODECACHE=true

# Accept more file changes before recompiling.
ENV CCACHE_SLOPPINESS=ivfsoverlay,modules,include_file_mtime,include_file_ctime,time_macros,pch_defines,clang_index_store,system_headers,locale
ENV CCACHE_COMPILERTYPE="clang"

ENV CCACHE_DEBUG=true
ENV CCACHE_DEBUGDIR=/ccache/debug
ENV CCACHE_LOGFILE=/ccache/ccache-log

RUN ccache --max-size 20G

RUN chown -R ${USER_NAME} /build
RUN chown -R ${USER_NAME} /ccache

USER ${USER_NAME}