#! bin/sh -e

if [[ -f ./tmp/pids/server.pid ]]; then
  rm ./tmp/pids/server.pid
fi

current_date=$(date "+%Y-%m-%d %H:%M:%S")

if ! [[ -f ./docker/development/tmp/.db-created  ]]; then
  bin/rails db:prepare && echo "Create database in $current_date UTC" >> ./docker/development/tmp/.db-created
fi

bin/rails db:migrate

if [[ -f /home/app/web/log/test.log ]]; then
  sudo chmod 0664 /home/app/web/log/test.log
fi

current_date=$(date "+%Y-%m-%d %H:%M:%S")
if ! [[ -f ./docker/development/tmp/.db-seeded ]]; then
  bin/rails db:seed && echo "Seeded database in $current_date UTC" >> ./docker/development/tmp/.db-seeded
fi

foreman start -f Procfile.dev