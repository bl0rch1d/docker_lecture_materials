ARG RUBY_VERSION

FROM ruby:$RUBY_VERSION-buster

ARG PG_MAJOR
ARG NODE_MAJOR
ARG BUNDLER_VERSION
ARG YARN_VERSION

# Add PostgreSQL to sources list
RUN curl -sSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
  && echo 'deb http://apt.postgresql.org/pub/repos/apt/ buster-pgdg main' $PG_MAJOR > /etc/apt/sources.list.d/pgdg.list

# Add NodeJS to sources list
RUN curl -sL https://deb.nodesource.com/setup_$NODE_MAJOR.x | bash -

# Add Yarn to sources list
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo 'deb http://dl.yarnpkg.com/debian/ stable main' > /etc/apt/sources.list.d/yarn.list

# Update system
RUN apt-get update -qq; apt-get upgrade -yq

# Install requirments
RUN apt-get install -yq --no-install-recommends \
                         build-essential \
                         postgresql-client-$PG_MAJOR \
                         imagemagick \
                         nodejs \
                         yarn=$YARN_VERSION \
                         awscli \
                         cron \
                         vim

# Clean apt cache
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    truncate -s 0 /var/log/*log

# Setup env variables
ENV RAILS_ROOT /var/www/bookstore
ENV LANG=C.UTF-8 \
    BUNDLE_PATH=$RAILS_ROOT/vendor/bundle \
    BUNDLE_JOBS=20 \
    BUNDLE_RETRY=5

# That allows us to run rails, rake, rspec andother
# binstubbed commands without prefixing them with bundle exec.
ENV BUNDLE_PATH $GEM_HOME
ENV BUNDLE_APP_CONFIG=$BUNDLE_PATH \
  BUNDLE_BIN=$BUNDLE_PATH/bin
ENV PATH /app/bin:$BUNDLE_BIN:$PATH

# Install bundler
RUN gem update --system; gem install bundler:$BUNDLER_VERSION

# Create app dir
RUN mkdir -p $RAILS_ROOT/tmp/pids

# Change directory
WORKDIR $RAILS_ROOT

# Copy Gemfile and Gemfile.lock to our image
COPY Gemfile* ./

# Install app dependencies
RUN bundle install --jobs $BUNDLE_JOBS --retry $BUNDLE_RETRY --path $BUNDLE_PATH

# Copy app code
COPY . .

# Compile assets
RUN bin/rake assets:precompile
