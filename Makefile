UID=$(shell id -u)
GID=$(shell id -g)
DOCKER_PHP_SERVICE=php

SHELL=/bin/bash

.DEFAULT_GOAL := start

start: build composer-install ## Initialize project

.PHONY: help
help: ## Displays this list of targets with descriptions
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}'

build:
		docker build -t php-template .

erase: ## Remove the Docker containers of the project.
		docker rmi php-template

composer-install: ## Install composer dependencies
		docker run --rm -v .:/app php-template composer install

composer-update: ## Update composer dependencies
		docker run --rm -v .:/app php-template composer update

phpunit: ## Run PHPUnit
		docker run --rm -v .:/app php-template vendor/bin/phpunit tests

phpstan: ## Run PHPStan
		docker run --rm -v ${PWD}:/app ghcr.io/phpstan/phpstan analyse ./src -l 8

fix-cs: ## Fix code standards
		docker run --rm -v ${PWD}:/data cytopia/php-cs-fixer fix --verbose --show-progress=dots --rules=@Symfony,-@PSR2 -- src
		docker run --rm -v ${PWD}:/data cytopia/php-cs-fixer fix --verbose --show-progress=dots --rules=@Symfony,-@PSR2 -- tests

validate-cs: ## Validate code standards
		docker run --rm -v ${PWD}:/data cytopia/php-cs-fixer fix --dry-run --verbose --show-progress=dots --rules=@Symfony,-@PSR2 -- src
		docker run --rm -v ${PWD}:/data cytopia/php-cs-fixer fix --dry-run --verbose --show-progress=dots --rules=@Symfony,-@PSR2 -- tests

.PHONY: tests
tests: ## Run cs validation, PHPStan and PHPUnit
	make validate-cs
	make phpstan
	make phpunit