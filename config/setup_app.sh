#! bin/sh -e

if [[ -f ./tmp/pids/server.pid ]]; then
  rm ./tmp/pids/server.pid
fi

current_date=$(date "+%Y-%m-%d %H:%M:%S")

if ! [[ -f ./docker/tmp/.db-created  ]]; then
  bin/rails db:prepare && echo "Create database in $current_date UTC" >> ./docker/tmp/.db-created 
fi

bin/rails db:migrate

if ! [[ -f ./docker/tmp/.db-seeded ]]; then
  bin/rails db:seed && echo "Seeded database in $current_date UTC" >> ./docker/tmp/.db-seeded
fi

echo "Start app in $current_date UTC" >> ./docker/tmp/.log

foreman start -f Procfile.dev