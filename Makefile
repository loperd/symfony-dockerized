#!/usr/bin/make
# Makefile readme (ru): <http://linux.yaroslavl.ru/docs/prog/gnu_make_3-79_russian_manual.html>
# Makefile readme (en): <https://www.gnu.org/software/make/manual/html_node/index.html#SEC_Contents>

docker_bin := $(shell command -v docker 2> /dev/null)
dc_bin := $(shell command -v docker-compose 2> /dev/null)
dc_app_name = app
cwd = $(shell pwd)

SHELL = /bin/bash
FRONTEND_PORT := 4001
FRONTEND_PORT_SSL := 4002
REDIS_MANAGER_PORT := 4003
REDIS_PORT := 4004
POSTGRES_PORT := 4005
ENV_FILE := .env
CURRENT_USER = $(shell id -u):$(shell id -g)
RUN_APP_ARGS = --rm --user "$(CURRENT_USER)" "$(dc_app_name)"


define print
	printf " \033[33m[%s]\033[0m \033[32m%s\033[0m\n" $1 $2
endef
define print_block
	printf " \e[30;48;5;82m  %s  \033[0m\n" $1
endef
define setup_env
	$(eval include $(ENV_FILE))
	$(eval export sed 's/=.*//' $(ENV_FILE))
endef

.PHONY : help \
		 install init shell test test-cover \
		 up down restart logs clean git-hooks pull
.SILENT : help install up down shell
.DEFAULT_GOAL : help

# This will output the help for each task. thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help: ## Show this help
	@printf "\033[33m%s:\033[0m\n" 'Available commands'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[32m%-18s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

install: ## Install all app dependencies
	$(dc_bin) run -e STARTUP_WAIT_FOR_SERVICES=false $(RUN_APP_ARGS) composer install --no-interaction --ansi --no-suggest --prefer-dist

init: install clean ## Make full application initialization (install, seed, build assets, etc)

shell: ## Start shell into app container
	$(dc_bin) run -e STARTUP_WAIT_FOR_SERVICES=false $(RUN_APP_ARGS) sh

enter:
	$(dc_bin) exec app bash

test: ## Execute app tests
	$(dc_bin) run $(RUN_APP_ARGS) composer test

test-cover: ## Execute app tests with coverage
	$(dc_bin) run --rm --user "0:0" "$(dc_app_name)" sh -c '\
		apk --no-cache add autoconf make g++ && pecl install xdebug-2.7.2 && docker-php-ext-enable xdebug \
		&& su $(shell whoami) -s /bin/sh -c "composer phpunit-cover"'

up: ## Create and start containers
	CURRENT_USER=$(CURRENT_USER) $(dc_bin) up --detach
	$(call print_block, 'Navigate your browser to         ⇒ http://127.0.0.1:$(FRONTEND_PORT)')
	$(call print_block, 'Or navigate your browser to      ⇒ https://127.0.0.1:$(FRONTEND_PORT_SSL)')
	$(call print_block, 'Redis Manager (Redis Web UI)     ⇒ http://127.0.0.1:$(REDIS_MANAGER_PORT)')
	$(call print_block, 'Additional ports (available for connections) - Redis ⇒ $(REDIS_PORT); Postgres ⇒ $(POSTGRES_PORT)')

down: ## Stop and remove containers, networks, images, and volumes
	$(dc_bin) down -t 5

restart: down up ## Restart all containers

logs: ## Show docker logs
	$(dc_bin) logs --follow

clean: ## Make some clean
	-$(dc_bin) run -e STARTUP_WAIT_FOR_SERVICES=false $(RUN_APP_ARGS) composer clear
	$(dc_bin) down -v -t 5

pull: ## Pulling newer versions of used docker images
	$(dc_bin) pull

init-env:
	@$(call setup_env)

build-local-php: init-env
	bash -c "./docker/php/build.sh -t $(APP_NAME)/php:latest"

build-local-app: init-env
	bash -c "./docker/app/build.sh -t $(APP_NAME):latest -m dev --parent $(APP_NAME)/php:latest"

build-local: init-env build-local-php build-local-app # build local application images
