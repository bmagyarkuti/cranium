FROM ruby:2.7.3-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
                      build-essential \
                      wget \
                      libpq-dev \
                      postgresql-client \
                      git-core \
    && export DOCKERIZE_VERSION=v0.6.1 \
    && wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz

RUN mkdir /app
WORKDIR /app

RUN gem install bundler

COPY Gemfile .
COPY cranium.gemspec .

ARG https_proxy
ARG http_proxy
RUN bundle install -j 5
COPY . .
COPY .env.jenkins ./.env
RUN mkdir /tmp/custdata/
