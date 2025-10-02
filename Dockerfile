FROM ubuntu:16.04

# Avoid interactive tzdata prompts
ENV DEBIAN_FRONTEND=noninteractive \
    APP_HOME=/app \
    RUBY_VERSION=1.9.3-p551 \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_APP_CONFIG=/usr/local/bundle \
    LANG=C.UTF-8

# System deps for building Ruby and gems
RUN apt-get update -y && apt-get install -y --no-install-recommends \
    build-essential \
    curl ca-certificates \
    git \
    libssl-dev \
    zlib1g-dev \
    libreadline-dev \
    libyaml-dev \
    libxml2-dev libxslt1-dev \
    libmysqlclient-dev \
    pkg-config \
    imagemagick \
    && rm -rf /var/lib/apt/lists/*

# Build Ruby 1.9.3 from source (works with OpenSSL 1.0 on xenial)
RUN curl -fsSL https://cache.ruby-lang.org/pub/ruby/1.9/ruby-${RUBY_VERSION}.tar.gz -o /tmp/ruby.tar.gz \
 && cd /tmp \
 && tar -xzf ruby.tar.gz \
 && cd ruby-${RUBY_VERSION} \
 && ./configure --disable-install-doc \
 && make \
 && make install \
 && rm -rf /tmp/ruby* \
 && ruby -v

# Install a Bundler compatible with this era
RUN gem install bundler -v 1.17.3 --no-ri --no-rdoc \
 && bundle -v

WORKDIR ${APP_HOME}

# Prime bundler layer: copy only Gemfile(s) first
COPY Gemfile Gemfile.lock* ${APP_HOME}/

# Configure builds for mysql2 (use system mysql_config) and nokogiri (system libs if available)
ENV BUNDLE_BUILD__MYSQL2="--with-mysql-config=/usr/bin/mysql_config" \
    BUNDLE_BUILD__NOKOGIRI="--use-system-libraries"

# Install gems (development and test for dev container)
RUN bundle _1.17.3_ install --without test

# Copy the rest of the app
COPY . ${APP_HOME}

# Provide a Docker-specific database.yml and entrypoint to copy it on first run
COPY config/database.docker.yml ${APP_HOME}/config/database.docker.yml

EXPOSE 3000

# Simple entrypoint: ensure database.yml exists, then boot the legacy server
CMD ["bash", "-lc", "\
  if [ ! -f config/database.yml ]; then cp config/database.docker.yml config/database.yml; fi && \
  bundle _1.17.3_ install --without test && \
  bundle exec script/server -p 3000 -b 0.0.0.0 "]
