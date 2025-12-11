#!/bin/bash
# Rails server startup script

cd "$(dirname "$0")"
$HOME/.local/share/gem/ruby/3.2.0/bin/bundle exec rails server
