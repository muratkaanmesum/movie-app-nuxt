.PHONY: help setup check-env prod-build prod-start prod-stop prod-logs prod-restart dev-start dev-stop dev-logs dev-restart status shell cleanup

.DEFAULT_GOAL := help

PROD_COMPOSE := docker-compose.yml
DEV_COMPOSE := docker-compose.dev.yml

check-env:
	@[ -f .env ] || (cp .env.example .env && echo "Created .env - add your TMDB API key" && exit 1)
	@grep -q "your_tmdb_api_key_here" .env && (echo "Update TMDB API key in .env" && exit 1) || true

setup:
	@[ ! -f .env ] && cp .env.example .env && echo "Created .env file" || echo ".env already exists"

prod-build:
	@docker-compose -f $(PROD_COMPOSE) build --no-cache

prod-start: check-env
	@docker-compose -f $(PROD_COMPOSE) up -d
	@echo "App running at http://localhost:3000"

prod-stop:
	@docker-compose -f $(PROD_COMPOSE) down

prod-logs:
	@docker-compose -f $(PROD_COMPOSE) logs -f

prod-restart: prod-stop prod-start

dev-start: check-env
	@docker-compose -f $(DEV_COMPOSE) up -d
	@echo "Dev server at http://localhost:3000, DevTools at http://localhost:24678"

dev-stop:
	@docker-compose -f $(DEV_COMPOSE) down

dev-logs:
	@docker-compose -f $(DEV_COMPOSE) logs -f

dev-restart: dev-stop dev-start

status:
	@docker-compose -f $(PROD_COMPOSE) ps
	@docker-compose -f $(DEV_COMPOSE) ps

shell:
	@docker-compose -f $(PROD_COMPOSE) exec movie-app sh

dev-shell:
	@docker-compose -f $(DEV_COMPOSE) exec movie-app-dev sh

cleanup:
	@docker-compose -f $(PROD_COMPOSE) down -v
	@docker-compose -f $(DEV_COMPOSE) down -v
	@docker system prune -f

build-all:
	@docker-compose -f $(PROD_COMPOSE) build --no-cache
	@docker-compose -f $(DEV_COMPOSE) build --no-cache

stop-all:
	@docker-compose -f $(PROD_COMPOSE) down
	@docker-compose -f $(DEV_COMPOSE) down

health:
	@curl -sf http://localhost:3000 > /dev/null && echo "App is healthy" || echo "App not responding"

logs-all:
	@docker-compose -f $(PROD_COMPOSE) logs --tail=20
	@docker-compose -f $(DEV_COMPOSE) logs --tail=20

help:
	@echo "Available commands:"
	@echo "  setup         prod-build    prod-start    prod-stop     prod-logs"
	@echo "  prod-restart  dev-start     dev-stop      dev-logs      dev-restart"
	@echo "  status        shell         dev-shell     cleanup       build-all"
	@echo "  stop-all      health        logs-all      help"
