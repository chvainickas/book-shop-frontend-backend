#!/bin/bash
# Simple backend starter

cd "$(dirname "$0")/backend"
export PATH="$HOME/.local/share/gem/ruby/3.2.0/bin:$PATH"
echo "Starting Rails backend on port 3000..."
bundle exec rails server -p 3000
