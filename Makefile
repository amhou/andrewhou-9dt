DOCKER               ?= docker
DOCKER_COMPOSE       ?= docker-compose

default_target: initialize

initialize:
	$(MAKE) pull
	$(MAKE) build
	@echo "Images are prepped. Run 'make setup' to initialize database, and then run 'make start'."

build: pull
	@echo "Building base"
	@${DOCKER_COMPOSE} build --pull base

pull:
	@echo "Pulling all images"
	@${DOCKER_COMPOSE} pull --ignore-pull-failures

setup: persisted_resources
	@echo "About to create the db structure... (sleeping for 10s to ensure MySQL stands up)" && \
    sleep 10
	${DOCKER_COMPOSE} run shell db_load

persisted_resources:
	@${DOCKER_COMPOSE} up -d mysql

shell:
	@echo "Getting you a shell"
	@${DOCKER_COMPOSE} run shell

console:
	@echo "Getting you a console"
	@${DOCKER_COMPOSE} run shell console

start: persisted_resources
	@echo "Starting Game App"
	@${DOCKER_COMPOSE} up -d game_app

down:
	@${DOCKER_COMPOSE} down

test:
	@${DOCKER_COMPOSE} run shell rspec
