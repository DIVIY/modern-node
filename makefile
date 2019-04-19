ENV_FILE := ./.env

include ${ENV_FILE}
export

# Color chart and related variables
RESET     := $(shell tput -Txterm sgr0)
BLACK     := $(shell tput -Txterm setaf 0)
RED       := $(shell tput -Txterm setaf 1)
GREEN     := $(shell tput -Txterm setaf 2)
YELLOW    := $(shell tput -Txterm setaf 3)
BLUE      := $(shell tput -Txterm setaf 4)
MAGENTA   := $(shell tput -Txterm setaf 5)
TURQUOISE := $(shell tput -Txterm setaf 6)
WHITE     := $(shell tput -Txterm setaf 7)
SMUL      := $(shell tput smul)
RMUL      := $(shell tput rmul)

define LABEL_MAKER
	@echo ${1}
	@echo ================================================================================
	@echo ${2}
	@echo ================================================================================
	@echo
	@tput -Txterm sgr0 # ${RESET} won't work here for some reason
endef

OUTPUT_MAKE_COMMANDS = \
	%help; \
	use Data::Dumper; \
	while(<>) { \
		if (/^([_a-zA-Z\-]+)\s*:.*\#\#(?:@([a-zA-Z\-_\s]+))?\t(.*)$$/ \
			|| /^([_a-zA-Z\-]+)\s*:.*\#\#(?:@([a-zA-Z\-]+))?\s(.*)$$/) { \
			$$c = $$2; $$t = $$1; $$d = $$3; \
			push @{$$help{$$c}}, [$$t, $$d, $$ARGV] unless grep { grep { grep /^$$t$$/, $$_->[0] } @{$$help{$$_}} } keys %help; \
		} \
	}; \
	for (sort keys %help) { \
		printf("${RED}%24s:${RESET}\n\n", $$_); \
		for (@{$$help{$$_}}) { \
			printf("%s%25s${RESET}%s  %s${RESET}\n", \
				( $$_->[2] eq "Makefile" || $$_->[0] eq "help" ? "${YELLOW}" : "${MAGENTA}"), \
				$$_->[0], \
				( $$_->[2] eq "Makefile" || $$_->[0] eq "help" ? "${GREEN}" : "${WHITE}"), \
				$$_->[1] \
			); \
		} \
		print "\n"; \
	}

OUTPUT_ENV_VARIABLES = \
	%help; \
	use Data::Dumper; \
	while(<>) { \
		if (/^([_a-zA-Z\-\_]*)(=)(.*)/) { \
			push @{$$help{$$2}}, [$$1, $$3, $$ARGV]; \
		} \
	}; \
	for (sort keys %help) { \
		for (@{$$help{$$_}}) { \
			printf("%s%24s${RESET}%s  %s${RESET}\n", "${TURQUOISE}", $$_->[0], "${WHITE}", $$_->[1] ); \
		} \
		print "\n"; \
	}

.DEFAULT_GOAL := help

%: # Enable argument aware commands. # Silently do nothing; Side effect: this swallows 'makefile: undefined make command error' messages.
	@:

help: ##@Utility Show this help.
	@echo ''
	@printf "%36s " "${BLUE}VARIABLES"
	@echo "${RESET}"
	@echo ''
	@perl -e '$(OUTPUT_ENV_VARIABLES)' $(ENV_FILE)
	@printf "%36s " "${YELLOW}COMMANDS"
	@echo "${RESET}"
	@echo ''
	@printf "%s%25s${RESET}%s  %s" "${YELLOW}" "make command" "${GREEN}" "Description of, how to use the, or"
	@echo ''
	@printf "%27s%s" "" "equivalent for this command."
	@echo "${RESET}"
	@echo ''
	@perl -e '$(OUTPUT_MAKE_COMMANDS)' $(MAKEFILE_LIST)

build: stop ##@Installation docker-compose build
	docker-compose \
		-p "${APP}" \
		-f ./docker/docker-compose.yml \
		rm \
		-vsf
	docker-compose \
		-p "${APP}" \
		-f ./docker/docker-compose.yml \
		build

dev: quickstart port-start ##@Development Develop the back-end and front-end.
	@-powershell start powershell {make jump ${BACK_END_NAME}}
	@-powershell start powershell {make launch ${BACK_END_NAME} npm run watch}
	@-powershell start powershell {make logs}
	@-powershell start powershell {ngrok http ${APP_HTTP_PORT}}
	@-code -n .
	@-firefox -private ${APP_HOST} \
		${REVERSE_PROXY_NAME}.${APP_HOST} \
		${APP_HOST}:${NGROK_PORT} \
		${APP_HOST}:${PORTAINER_PORT} &

full-dev: start port-start ##@Development Launch full development stack.
	@-powershell start powershell {make jump ${BACK_END_NAME}}
	@-powershell start powershell {make launch ${BACK_END_NAME} npm run watch}
	@-powershell start powershell {make logs}
	@-powershell start powershell {ngrok http ${APP_HTTP_PORT}}
	@-code -n .
	@-firefox -private ${APP_HOST} \
		${METABASE_NAME}.${APP_HOST} \
		${AB_TEST_WEB_NAME}.${APP_HOST} \
		${ANALYTICS_NAME}.${APP_HOST} \
		${REVERSE_PROXY_NAME}.${APP_HOST} \
		${NETDATA_NAME}.${APP_HOST} \
		${APP_HOST}:${NGROK_PORT} \
		${APP_HOST}:${PORTAINER_PORT} &

start: ##@User Commands	docker-compose up
	docker-compose \
		-p "${APP}" \
		-f ./docker/docker-compose.yml \
		up \
		-d

stop: port-stop ##@User Commands	docker-compose down
	docker-compose \
		-p "${APP}" \
		-f ./docker/docker-compose.yml \
		down \
		-v \
		--remove-orphans

quickstart: ##@User Commands	docker-compose up back-end front-end
	docker-compose \
		-p "${APP}" \
		-f ./docker/docker-compose.yml \
		up \
		-d \
		${BACK_END_NAME} 

analyze: ##@TBD -- Static Code Analyzer
	@:

lint: ##@TBD -- Linter
	@:

test: ##@TBD -- Unit and Integration Tests
	@:

compile: ##@TBD -- Compile to Static Binaries
	@:
 
logs: ##@Development docker-compose logs
	docker-compose \
		-p "${APP}" \
		-f ./docker/docker-compose.yml \
		logs \
		-f

launch: ##@Development make run {container_name} {command} ...{args}
	docker-compose \
		-p "${APP}" \
		-f ./docker/docker-compose.yml run \
		$(filter-out $@,$(MAKECMDGOALS))

jump: ##@Development make jump {container_name}
	docker exec -it $(filter-out $@,$(MAKECMDGOALS)) sh


port-start: ##@Infrastructure Management	Run Portainer
	-docker run \
		--name=${PORTAINER_NAME} \
		-d \
		-p ${PORTAINER_PORT}:9000 \
		-v /var/run/docker.sock:/var/run/docker.sock \
		portainer/portainer \
		--no-auth

port-stop: ##@Infrastructure Management	Kill and Remove Portainer
	-docker kill ${PORTAINER_NAME}
	-docker rm ${PORTAINER_NAME}
	
list: ##@Infrastructure Management	List Docker System
	$(call LABEL_MAKER,${TURQUOISE},'List Docker System')
	docker container ls
	@echo ''
	docker image ls
	@echo ''
	docker volume ls

clean: ##@Infrastructure Management	Clean Docker System
	$(call LABEL_MAKER,${RED},'Clean Docker System')
	@echo ''
	docker container prune -f
	docker image prune -f
	docker network prune -f
	docker volume prune -f

hotswap: ##@Infrastructure Management	docker-compose down, build, create, start {target}
	docker-compose \
		-p "${APP}" \
		-f ./docker/docker-compose.yml \
		stop \
		-t 1 \
		$(filter-out $@,$(MAKECMDGOALS))
	docker-compose \
		-p "${APP}" \
		-f ./docker/docker-compose.yml \
		build \
		$(filter-out $@,$(MAKECMDGOALS))
	docker-compose \
		-p "${APP}" \
		-f ./docker/docker-compose.yml \
		up \
		--no-start \
		$(filter-out $@,$(MAKECMDGOALS))
	docker-compose \
		-p "${APP}" \
		-f ./docker/docker-compose.yml \
		start \
		$(filter-out $@,$(MAKECMDGOALS))

target-stop: ##@Infrastructure Management	docker-compose down {target}
	docker-compose \
		-p "${APP}" \
		-f ./docker/docker-compose.yml \
		stop \
		-t 1 \
		$(filter-out $@,$(MAKECMDGOALS))
		
target-build: ##@Infrastructure Management	docker-compose build {target}
	docker-compose \
		-p "${APP}" \
		-f ./docker/docker-compose.yml \
		build \
		$(filter-out $@,$(MAKECMDGOALS))

target-create: ##@Infrastructure Management	docker-compose create {target}
	docker-compose \
		-p "${APP}" \
		-f ./docker/docker-compose.yml \
		up \
		--no-start \
		$(filter-out $@,$(MAKECMDGOALS))

target-start: start ##@Infrastructure Management	docker-compose start {target}
	docker-compose \
		-p "${APP}" \
		-f ./docker/docker-compose.yml \
		start \
		$(filter-out $@,$(MAKECMDGOALS))