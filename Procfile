web: bundle exec rails db:prepare && (sleep 15 && bundle exec sidekiq -c 2 &) && bundle exec bin/rails server -b 0.0.0.0 -p ${PORT:-3000} -e $RAILS_ENV
