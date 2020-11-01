#!/bin/bash

set -e

apt-get moo >> moo.txt

exec "$@"
