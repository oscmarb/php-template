.DEFAULT_GOAL := start

start: build composer-install ## Initialize project

.PHONY: help
help: ## Displays this list of targets with descriptions
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}'

build: ## Build docker image
	docker build -t php-template .

require: ## Install package. Arguments: package
	make run-composer-command-on-container command="require $(package)"

require-dev: ## Install dev package. Arguments: package
	make run-composer-command-on-container command="require --dev $(package)"

erase: ## Remove the docker image of the project.
	docker rmi php-template

composer-install: ## Install composer dependencies
	make run-composer-command-on-container command="install"

composer-update: ## Update composer dependencies
	make run-composer-command-on-container command="update"

phpunit: ## Run PHPUnit
	make run-command-on-container command="vendor/bin/phpunit tests"

phpstan: ## Run PHPStan
	make run-command-on-container command="vendor/bin/phpstan analyse"

fix-cs: ## Fix code style
	docker run --rm -v ${PWD}:/data cytopia/php-cs-fixer fix --verbose --show-progress=dots --rules=@Symfony,-@PSR2 -- src
	docker run --rm -v ${PWD}:/data cytopia/php-cs-fixer fix --verbose --show-progress=dots --rules=@Symfony,-@PSR2 -- tests

validate-cs: ## Validate code style
	docker run --rm -v ${PWD}:/data cytopia/php-cs-fixer fix --dry-run --verbose --show-progress=dots --rules=@Symfony,-@PSR2 -- src
	docker run --rm -v ${PWD}:/data cytopia/php-cs-fixer fix --dry-run --verbose --show-progress=dots --rules=@Symfony,-@PSR2 -- tests

infection: ## Run Infection
	make run-command-on-container command="vendor/bin/infection"

.PHONY: tests
tests: ## Run cs validation, PHPStan, PHPUnit and Infection
	make validate-cs
	make phpstan
	make phpunit
	make infection

run-command-on-container: ## Execute command in the container. Arguments: command
	docker run --rm -v .:/app php-template $(command)

run-composer-command-on-container: ## Execute composer command in the container. Arguments: command
	make run-command-on-container command="composer $(command)"