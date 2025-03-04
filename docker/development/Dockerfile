# syntax=docker/dockerfile:1

# Base
FROM ruby:3.4.2-slim AS base

RUN apt-get update && \
    apt-get install -y \
    build-essential \
    nodejs \
    libvips-dev \
    imagemagick \
    libmagickwand-dev \
    gnupg2 \
    && rm -rf /var/lib/apt/lists/*

# Build
FROM ruby:3.4.2-slim AS build

RUN apt-get update && \
    apt-get install -y \
    libpq-dev \
    watchman \
    chromium \
    sudo \
    build-essential \
    libssl-dev \
    libreadline-dev \
    zlib1g-dev \
    libyaml-dev \
    && rm -rf /var/lib/apt/lists/*

# Runner
FROM build AS runner

# Docker user
ARG USER_ID=1000
ARG GROUP_ID=1000

RUN addgroup --gid ${GROUP_ID} appuser && \
    adduser --uid ${USER_ID} --gid ${GROUP_ID} --home /home/appuser --disabled-password --gecos "" appuser && \
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
    sudo rm -rf /var/cache/apt/*
