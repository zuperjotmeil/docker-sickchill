FROM ghcr.io/linuxserver/baseimage-alpine:3.15

# set version label
ARG BUILD_DATE
ARG VERSION
ARG SICKCHILL_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="homerr"

# set python to use utf-8 rather than ascii
ENV PYTHONIOENCODING="UTF-8"
ENV HOME=/config

RUN \
  echo "**** install build packages ****" && \
  apk add --no-cache --virtual=build-dependencies \
    cargo \
    g++ \
    gcc \
    git \
    libffi-dev \
    libxslt-dev \
    make \
    openssl-dev \
    python3-dev && \
  echo "**** install packages ****" && \
  apk add --no-cache \
    libmediainfo \
    libssl1.1 \
    libxslt \
    py3-pip \
    python3 && \
  apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/v3.14/main \
    unrar && \
  echo "**** install sickchill ****" && \
  if [ -z ${SICKCHILL_VERSION+x} ]; then \
    SICKCHILL="sickchill"; \
  else \
    SICKCHILL="sickchill==${SICKCHILL_VERSION}"; \
  fi && \
  pip3 install -U \
    pip && \
  pip install -U --find-links https://wheel-index.linuxserver.io/alpine-3.15/ \
    certifi \
    "$SICKCHILL" && \
  ln -s /usr/bin/python3 /usr/bin/python && \
  echo "**** clean up ****" && \
  apk del --purge \
    build-dependencies && \
  rm -rf \
    /root/.cache \
    /root/.cargo \
    /tmp/*

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 8081
VOLUME /config
