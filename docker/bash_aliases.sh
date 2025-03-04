# Define a global alias for the base command
alias -g BASE='docker compose -f "docker-compose.development.yml"'

docker-clean(){
  docker stop $(docker ps -aq)
  docker rmi -f $(docker images -aq)
  rm ./docker/development/tmp/.db-created
  rm ./docker/development/tmp/.db-seeded
}

# Development commands
# Build image
alias docker-build='BASE build'

# Run project
alias docker-up='BASE up'

# Run project in detached mode
alias docker-up-d='BASE up -d'

# Stop containers
alias docker-down='BASE down'

# Stop all containers
alias docker-stop='docker stop $(docker ps -aq)'

# Remove all images
alias docker-rmi='docker rmi -f $(docker images -aq)'

# Rails specific commands
# Run rails related commands
alias docker-rails='BASE exec web bundle exec rails'

# Run bundle related commands
alias docker-bundle='BASE exec web bundle'

# Alias to run rake related commands
alias docker-rake='BASE exec web bundle exec rake'

# Alias to start the Rails console
alias docker-console='BASE exec web rails console'

# Alias to run Rubocop
alias docker-rubocop='BASE exec web bundle exec rubocop'

# Alias to run RSpec tests
alias docker-rspec='BASE exec web bundle exec rspec'
