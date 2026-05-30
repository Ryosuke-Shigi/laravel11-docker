DC ?= docker compose
# Default local stack. MinIO is included so Storage::disk('s3') works after a
# normal "make up" without starting object storage by hand.
APP_SERVICES ?= nginx php-fpm queue scheduler mysql redis minio mailpit adminer

cmd ?=
c ?= $(cmd)

.DEFAULT_GOAL := help

.PHONY: help build rebuild up start down stop restart ps logs logs-app shell php artisan art a optimize-clear clear app-clear optimize migrate seed tinker composer composer-dump dump dump-autoload npm npm-install npm-build npm-dev dev vite test queue-up queue scheduler-up scheduler minio-up minio-logs minio-ps

help: ## Show available shortcuts
	@awk 'BEGIN {FS = ":.*##"; printf "\nLaravel Docker shortcuts\n\n"} /^[a-zA-Z0-9_.-]+:.*##/ {printf "  %-16s %s\n", $$1, $$2} END {printf "\nExamples:\n  make up\n  make clear\n  make artisan cmd=\"route:list\"\n  make composer c=\"install\"\n  make npm c=\"run build\"\n\n"}' $(MAKEFILE_LIST)

build: ## Build Docker images
	$(DC) build

rebuild: ## Rebuild Docker images without cache
	$(DC) build --no-cache

up: ## Start nginx, php-fpm, queue, scheduler, mysql, redis, minio, mailpit, and adminer
	$(DC) up -d $(APP_SERVICES)

start: up ## Alias for up

down: ## Stop and remove containers, keeping volumes
	$(DC) down

stop: down ## Alias for down

restart: down up ## Restart the default stack

ps: ## Show container status
	$(DC) ps

logs: ## Follow logs for the default stack
	$(DC) logs -f --tail=100 $(APP_SERVICES)

logs-app: ## Follow nginx and php-fpm logs
	$(DC) logs -f --tail=100 nginx php-fpm

shell: ## Open a shell in the Laravel app directory
	$(DC) run --rm --no-deps php-fpm sh

php: ## Run PHP CLI, for example: make php c="-m"
	$(DC) run --rm php-cli $(c)

artisan: ## Run artisan, for example: make artisan cmd="migrate"
	$(DC) run --rm artisan $(c)

art: artisan ## Alias for artisan

a: artisan ## Short alias for artisan

optimize-clear: ## Run php artisan optimize:clear
	$(DC) run --rm artisan optimize:clear

clear: optimize-clear ## Alias for optimize-clear

# Use the running app container after changing .env values such as AWS_ENDPOINT.
app-clear: ## Run php artisan optimize:clear in the running php-fpm container
	$(DC) exec php-fpm php artisan optimize:clear

optimize: ## Run php artisan optimize
	$(DC) run --rm artisan optimize

migrate: ## Run php artisan migrate
	$(DC) run --rm artisan migrate

seed: ## Run php artisan db:seed
	$(DC) run --rm artisan db:seed

tinker: ## Open php artisan tinker
	$(DC) run --rm artisan tinker

composer: ## Run composer, for example: make composer c="require vendor/package"
	$(DC) run --rm composer $(c)

composer-dump: ## Run composer dump-autoload
	$(DC) run --rm composer dump-autoload

dump: composer-dump ## Alias for composer-dump

dump-autoload: composer-dump ## Alias for composer-dump

npm: ## Run npm, for example: make npm c="install"
	$(DC) run --rm npm $(c)

npm-install: ## Run npm install
	$(DC) run --rm npm install

npm-build: ## Run npm run build
	$(DC) run --rm npm run build

npm-dev: ## Start Vite dev server on 0.0.0.0:5173
	$(DC) run --rm --service-ports npm run dev -- --host 0.0.0.0

dev: npm-dev ## Alias for npm-dev

vite: npm-dev ## Alias for npm-dev

test: ## Run php artisan test
	$(DC) run --rm artisan test

queue-up: ## Start the queue worker
	$(DC) up -d queue

queue: queue-up ## Alias for queue-up

scheduler-up: ## Start the scheduler
	$(DC) up -d scheduler

scheduler: scheduler-up ## Alias for scheduler-up

# Start only object storage when the rest of the stack is already running.
minio-up: ## Start local MinIO
	$(DC) up -d minio

# Useful for checking API/Console startup and credential-related failures.
minio-logs: ## Show recent MinIO logs
	$(DC) logs --tail=50 minio

# Confirms localhost-bound 9000/9001 ports and container health at a glance.
minio-ps: ## Show MinIO container status
	$(DC) ps minio
