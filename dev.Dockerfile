# Use Ruby version from your .ruby-version
ARG RUBY_VERSION=3.4.2
FROM docker.io/library/ruby:$RUBY_VERSION-slim

# Rails app lives here
WORKDIR /rails

# Install system dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    curl \
    git \
    libjemalloc2 \
    libpq-dev \
    libvips \
    pkg-config \
    postgresql-client \
    libyaml-dev && \
    rm -rf /var/lib/apt/lists/*

# Set development environment
ENV RAILS_ENV=development \
    BUNDLE_WITHOUT="" \
    PATH="${PATH}:/rails/bin"

# Install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy application code
COPY bin/docker-dev-entrypoint /rails/bin/
RUN chmod +x /rails/bin/docker-dev-entrypoint



# Entrypoint



# Set up non-root user
RUN groupadd --gid 1000 rails && \
    useradd --uid 1000 --gid rails --shell /bin/bash --create-home rails && \
    chown -R rails:rails db log storage tmp
USER rails

# Copy application code as non-root user
COPY --chown=rails:rails . .

# Precompile bootsnap
RUN bundle exec bootsnap precompile app/ lib/


ENTRYPOINT ["docker-dev-entrypoint"]

# Start server
EXPOSE 3000
CMD ["./bin/rails", "server"]