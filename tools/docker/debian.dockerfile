# This file is part of the pCloud Console Client.
#
# (c) 2021 Serghei Iakovlev <egrep@protonmail.ch>
#
# For the full copyright and license information, please view
# the LICENSE file that was distributed with this source code.

# To build image from the project source root use the following command:
#
#     docker build -t pcloudcc:debian-10 -f ./tools/docker/debian.dockerfile .

# To run image after build:
#
#     docker run -it --rm pcloudcc:debian-10 bash

FROM debian:buster

LABEL description="Build image to use for CI/CD with Debian Buster" \
      maintainer="Serghei Iakovlev <egrep@protonmail.ch>"

ENV TIMEZONE=UTC \
    LANGUAGE=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    DEBIAN_FRONTEND=noninteractive \
    TERM=xterm \
    PATH="/root/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
    CONAN_USER_HOME="/root"

# Bootstrap
RUN apt-get clean -y \
    && apt-get update -y \
    && apt-get upgrade -y \
    && apt-get install -y locales \
    && export LANGUAGE=${LANGUAGE} \
    && export LANG=${LANG} \
    && export LC_ALL=${LC_ALL} \
    && locale-gen ${LANG} \
    && dpkg-reconfigure --frontend noninteractive locales \
    && apt-get install --no-install-recommends -yq \
        apt-transport-https \
        apt-utils \
        ca-certificates \
        lsb-release \
        software-properties-common \
        tzdata \
        locales \
    && printf "LANGUAGE=\"en_US.UTF-8\"\nLC_ALL=\"en_US.UTF-8\"" >> /etc/environment \
    && sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && echo 'LANG="en_US.UTF-8"' > /etc/default/locale \
    && dpkg-reconfigure --frontend=noninteractive locales \
    && update-locale LANG=${LANG}

# Build and runtime deps
RUN apt-get install --no-install-recommends -yq \
        cmake \
        fuse \
        g++ \
        gcc \
        libfuse-dev \
        libpthread-stubs0-dev \
        make \
        python3 \
        python3-pip \
        python3-setuptools \
        python3-wheel \
    && export PATH="${PATH}" \
    && printf "export PATH=\"%s\"\n" "${PATH}" >> /root/.profile

ADD . /usr/src/pcloudcc

WORKDIR /usr/src/pcloudcc

# Project deps
RUN pip3 install --user -r requirements.txt \
    && mkdir -p /root/.conan/profiles \
    && cp ./tools/conan/profiles/Linux-x64-gcc-8-Release /root/.conan/profiles/default \
    && cp tools/conan/remotes.json "/root/.conan/remotes.json" \
    && export CONAN_USER_HOME="${CONAN_USER_HOME}" \
    && printf "export CONAN_USER_HOME=\"%s\"\n" "${CONAN_USER_HOME}" >> /root/.profile \
    && conan install . -if=build --build=missing

# Build project
RUN cmake -S . -B build \
      -DPCLOUD_MAINTAINER_LOGS=OFF \
      -DPCLOUD_BUILD_DOC=OFF \
      -DCMAKE_BUILD_TYPE=Release \
    && cmake --build build --config Release \
    && cmake --build build --target install \
    && ls -alL $(command -v pcloudcc) \
    && pcloudcc --help

# Cleanup
RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /tmp/* /var/tmp/*
