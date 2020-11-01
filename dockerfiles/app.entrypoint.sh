#!/bin/bash

# Exit immediately if a pipeline, one of commands below fails
set -e

# Delete old server process id
rm -f /var/www/bookstore/tmp/pids/server.pid

# Check missing gems and install
bundle check || bundle install

# Create and migrate db
bundle exec rake db:create db:migrate

# Return to docker execution context
exec "$@"
