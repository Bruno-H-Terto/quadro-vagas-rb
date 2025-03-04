# syntax=docker/dockerfile:1

# Base
FROM ruby:3.4.2-alpine AS base

RUN apk update && apk upgrade && \
    apk add --no-cache --virtual \
    build-base \
    nodejs \
    vips-dev \
    pkgconfig \
    curl \
    imagemagick \
    git \
    gnupg \
    bash

# Essentials libs
FROM ruby:3.4.2-alpine AS build

RUN apk update && apk upgrade && \
    apk add --no-cache \
    postgresql-dev \
    postgresql \
    chromium \
    make \
    yaml-dev \
    sudo

# Watchman
# Watchman version
ARG WM_VERSION=v2021.03.01.00

# install watchman
RUN wget https://github.com/facebook/watchman/releases/download/$WM_VERSION/watchman-$WM_VERSION-linux.zip && \
    unzip watchman-$WM_VERSION-linux.zip && \
    cd watchman-$WM_VERSION-linux && \
    mkdir -p /usr/local/{bin,lib} /usr/local/var/run/watchman && \
    cp bin/* /usr/local/bin && \
    cp lib/* /usr/local/lib && \
    chmod 755 /usr/local/bin/watchman && \
    chmod 2777 /usr/local/var/run/watchman && \
    cd .. && \
    rm -fr watchman-$WM_VERSION-linux.zip watchman-$WM_VERSION-linux

# Runner
FROM build AS runner

# Docker user
ARG USER_ID=1000
ARG GROUP_ID=1000

RUN addgroup -g ${GROUP_ID} appuser && \
    adduser -u ${USER_ID} -G appuser -h /home/appuser -D appuser && \
    echo "appuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER appuser

RUN gem install bundler && \
    gem install foreman

WORKDIR /home/app/web

# Copy Rails App for Docker
COPY . ./

# Allowed script and user modify app
RUN sudo chmod +x /home/app/web/bin/setup_app.sh && \
    sudo chown -R appuser:appuser /home/app/web

RUN bundle install

# Remove tmp files
RUN sudo rm -rf tmp/* && \
    sudo rm -rf /var/cache/apk/*
