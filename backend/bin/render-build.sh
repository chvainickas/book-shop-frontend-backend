#!/usr/bin/env bash
# exit on error
set -o errexit

bundle install
bundle exec rails db:migrate

# Reseed if books are missing cover URLs (after migration adds the column)
bundle exec rails runner "exit(Book.where(cover_url: nil).exists? ? 1 : 0)" || bundle exec rails db:seed
