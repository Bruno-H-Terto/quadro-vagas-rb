# Development commands
# Build image
alias docker-build='docker compose -f "docker-compose.development.yml" build'

# Run project
alias docker-up='docker compose -f "docker-compose.development.yml" up'

# Run project in detached mode
alias docker-up-d='docker compose -f "docker-compose.development.yml" up -d'

# Stop containers
alias docker-down='docker compose -f "docker-compose.development.yml" down'

# Stop all containers
alias docker-stop='docker stop $(docker ps -aq)'

# Remove all images
alias docker-rmi='docker rmi -f $(docker images -aq)'

# Rails specific commands
# Run rails related commands
alias docker-rails='docker compose -f "docker-compose.development.yml" exec web bundle exec rails'

# Alias to run rake related commands
alias docker-rake='docker compose -f "docker-compose.development.yml" exec web bundle exec rake'

# Alias to start the Rails console
alias docker-console='docker compose -f "docker-compose.development.yml" exec web rails console'

# Alias to run Rubocop
alias docker-rubocop='docker compose -f "docker-compose.development.yml" exec web bundle exec rubocop'

# Alias to run RSpec tests
alias docker-rspec='docker compose -f "docker-compose.development.yml" exec web bundle exec rspec'

