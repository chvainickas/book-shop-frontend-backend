#!/usr/bin/env bash
# exit on error
set -o errexit

bundle install
bundle exec rails db:migrate

# Seed database if no books exist
bundle exec rails runner "exit(Book.count > 0 ? 0 : 1)" || bundle exec rails db:seed
