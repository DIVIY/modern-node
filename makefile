# https://news.ycombinator.com/item?id=19052830
# https://news.ycombinator.com/item?id=14836340
# https://news.ycombinator.com/item?id=15041986

# mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
# current_dir := $(notdir $(patsubst %/,%,$(dir $(mkfile_path))))
# project = $(current_dir)
# project = $(notdir $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST))))))

include ./.env
export

# fix front-end so the server stands up and stays up.

# This has an example of example what i am trying to do.
# https://github.com/mrcoles/node-react-docker-compose

# setup redis
# tests for express and for code nad stuff.
# compile, or is that tied to react?

# site speeder upper : https://news.ycombinator.com/item?id=19122727

dev: up port-up
	@-powershell start powershell {make jump ${BACK_END_NAME}}
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
		${APP_HOST}:${PORTAINER_PORT} & # This needs to be the last step.

up:
	docker-compose -p "${APP}" -f ./docker/docker-compose.yml up -d

down: port-down
	docker-compose -p "${APP}" -f ./docker/docker-compose.yml down -v --remove-orphans

build:
	docker-compose -p "${APP}" -f ./docker/docker-compose.yml rm -vsf
	docker-compose -p "${APP}" -f ./docker/docker-compose.yml down -v --remove-orphans
	docker-compose -p "${APP}" -f ./docker/docker-compose.yml build

##########################################

test:
	@:

compile:
	@:
 
##########################################

logs:
	docker-compose -p "${APP}" -f ./docker/docker-compose.yml logs -f

# Argument-Aware Run Command. Use like 'make run {container_name} {command} ...{args}'
run:
	docker-compose -p "${APP}" -f ./docker/docker-compose.yml run $(filter-out $@,$(MAKECMDGOALS))

# Argument-Aware Jump Command. Use like 'make jump {container_name}'
jump:
	docker exec -it $(filter-out $@,$(MAKECMDGOALS)) sh

%: # Any non-defined command ends up here; enables us to accept any arbitrary arguments used in Jump
	@: # Silently do nothing; Side effect: this swallows 'undefined make command error' messages.

# Docker Management Commands
port-up:
	-docker run --name=${PORTAINER_NAME} -d -p ${PORTAINER_PORT}:9000 -v /var/run/docker.sock:/var/run/docker.sock portainer/portainer --no-auth

port-down:
	-docker kill ${PORTAINER_NAME}
	-docker rm ${PORTAINER_NAME}
	
list:
	@echo '----- List Docker System' & echo ''
	docker container ls
	docker image ls
	docker volume ls

clean:
	@echo '----- Clean Docker System' & echo ''
	docker container prune -f
	docker image prune -f
	docker network prune -f
	docker volume prune -f