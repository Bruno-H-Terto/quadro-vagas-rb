# syntax=docker/dockerfile:1

# Base Stage
FROM ruby:3.4.2-slim AS base

# Install base libraries required for image setup
RUN apt-get update && \
    apt-get install -y \
    build-essential \
    nodejs \
    libvips-dev \
    imagemagick \
    libmagickwand-dev \
    gnupg2 \
    && rm -rf /var/lib/apt/lists/*

# Build Stage
FROM ruby:3.4.2-slim AS build

# Install base libraries required for build environment
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

# Runner Stage
FROM build AS runner

# Docker not root user
ARG USER_ID=1000
ARG GROUP_ID=1000

# Add permission for docker user (appuser)
RUN addgroup --gid ${GROUP_ID} appuser && \
    adduser --uid ${USER_ID} --gid ${GROUP_ID} --home /home/appuser --disabled-password --gecos "" appuser && \
    echo "appuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Alter user for not root
USER appuser

# Install gems for docker environment
RUN gem install bundler && \
    gem install foreman

WORKDIR /home/app/web

# Copy Rails App for Docker
COPY . ./

# Allowed script and docker user modify app
RUN sudo chmod +x /home/app/web/bin/setup_app.sh && \
    sudo chown -R appuser:appuser /home/app/web

RUN bundle install

# Remove temporary files
RUN sudo rm -rf tmp/* && \
    sudo rm -rf /var/cache/apt/*
