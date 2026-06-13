# ── Project identity ─────────────────────────────────────────────
# When running from projects/{domain}/app/, derive PROJECT_DIR from the parent.
# When running from start-app/ or projects/{domain}/ directly, use current dir.
_CURNAME     := $(notdir $(patsubst %/,%,$(CURDIR)))
ifeq ($(_CURNAME),app)
  PROJECT_DIR := $(notdir $(patsubst %/,%,$(dir $(patsubst %/,%,$(CURDIR)))))
else
  PROJECT_DIR := $(_CURNAME)
endif
COMPOSE_NAME := $(subst .,-,$(PROJECT_DIR))
REGISTRY     ?= ops.noizu.com
TAG          ?= latest
PLATFORMS    ?= linux/amd64,linux/arm64

IMAGE_BACKEND  = $(REGISTRY)/$(PROJECT_DIR)/backend:$(TAG)
IMAGE_FRONTEND = $(REGISTRY)/$(PROJECT_DIR)/frontend:$(TAG)
IMAGE_NGINX    = $(REGISTRY)/$(PROJECT_DIR)/nginx:$(TAG)

# ── Host port assignment (nginx → host) ────────────────────────
# Source of truth: docker/ports.yaml
PORT_MAP := \
  bladeofeternity.com=8080 \
  aifighter.com=8081 \
  codefre.sh=8082 \
  derobot.is=8083 \
  gotta.cc=8084 \
  iotgo.io=8085 \
  jailbreakingsite.com=8086 \
  noizurpg.com=8087 \
  robots-unite.com=8088 \
  therobotknows.com=8089 \
  therobotlives.com=8090 \
  therobotmakes.com=8091

# ── Redis DB assignment ──────────────────────────────────────────
REDIS_DB_MAP := \
  bladeofeternity.com=0 \
  aifighter.com=1 \
  codefre.sh=2 \
  derobot.is=3 \
  gotta.cc=4 \
  iotgo.io=5 \
  jailbreakingsite.com=6 \
  noizurpg.com=7 \
  robots-unite.com=8 \
  therobotknows.com=9 \
  therobotlives.com=10 \
  therobotmakes.com=11

# ── Slug derivation ─────────────────────────────────────────────
SLUG_MAP := \
  bladeofeternity.com=boe \
  aifighter.com=aifighter \
  codefre.sh=codefresh \
  derobot.is=derobot \
  gotta.cc=gotta_cc \
  iotgo.io=iotgo \
  jailbreakingsite.com=jailbreaking \
  noizurpg.com=noizurpg \
  robots-unite.com=robots_unite \
  therobotknows.com=therobotknows \
  therobotlives.com=therobotlives \
  therobotmakes.com=therobotmakes

PROJECT_SLUG = $(or $(patsubst $(PROJECT_DIR)=%,%,$(filter $(PROJECT_DIR)=%,$(SLUG_MAP))),starter)
REDIS_DB     = $(or $(patsubst $(PROJECT_DIR)=%,%,$(filter $(PROJECT_DIR)=%,$(REDIS_DB_MAP))),0)
HOST_PORT    = $(or $(patsubst $(PROJECT_DIR)=%,%,$(filter $(PROJECT_DIR)=%,$(PORT_MAP))),8080)
DB_NAME      = $(subst .,_,$(subst -,_,$(PROJECT_DIR)))_dev

# ── Shared build fragments ──────────────────────────────────────
FRONTEND_BUILD_ARGS = \
	--build-arg NEXT_PUBLIC_API_URL=$$(grep NEXT_PUBLIC_API_URL .env 2>/dev/null | cut -d= -f2- || echo "") \
	--secret id=github_token,env=GITHUB_TOKEN

# ══════════════════════════════════════════════════════════════════

# ── Dev compose shorthand ──────────────────────────────────────
DEV_COMPOSE = docker compose -p $(COMPOSE_NAME) -f docker-compose.yaml -f docker-compose.dev.yaml

.PHONY: help init regen \
	build build-no-cache build-push \
	backend backend-no-cache \
	frontend frontend-no-cache \
	nginx nginx-no-cache \
	run stop restart logs clean push \
	run-dev run-dev-d stop-dev logs-dev \
	dev-setup dev-migrate dev-regen \
	dev-shell-backend dev-shell-frontend dev-clean

help: ## Show this help
	@grep -E '^[a-zA-Z/_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-24s\033[0m %s\n", $$1, $$2}'

regen: ## Regenerate design system CSS from theme YAML configs
	cd frontend && npm run regen

init: ## Generate .env + backend/.env + frontend/.env with secrets
	@echo "Initializing: $(PROJECT_DIR) (slug=$(PROJECT_SLUG), db=$(DB_NAME), redis_db=$(REDIS_DB), port=$(HOST_PORT))"
	@./scripts/gen-env.sh "$(PROJECT_SLUG)" "$(DB_NAME)" "$(REDIS_DB)" "$(PROJECT_DIR)" "$(REGISTRY)" "$(HOST_PORT)"

# ── Per-service builds ───────────────────────────────────────────

backend: ## Build backend image
	docker buildx build --load -t $(IMAGE_BACKEND) ./backend

backend-no-cache: ## Build backend image (no cache)
	docker buildx build --no-cache --load -t $(IMAGE_BACKEND) ./backend

frontend: .env ## Build frontend image
	GITHUB_TOKEN=$${GITHUB_TOKEN} docker buildx build --load -t $(IMAGE_FRONTEND) \
		$(FRONTEND_BUILD_ARGS) ./frontend

frontend-no-cache: .env ## Build frontend image (no cache)
	GITHUB_TOKEN=$${GITHUB_TOKEN} docker buildx build --no-cache --load -t $(IMAGE_FRONTEND) \
		$(FRONTEND_BUILD_ARGS) ./frontend

nginx: ## Build nginx image
	docker buildx build --load -t $(IMAGE_NGINX) ./nginx

nginx-no-cache: ## Build nginx image (no cache)
	docker buildx build --no-cache --load -t $(IMAGE_NGINX) ./nginx

# ── Aggregate builds ─────────────────────────────────────────────

build: backend frontend nginx ## Build all images
	@echo ""
	@echo "Built: $(IMAGE_BACKEND) $(IMAGE_FRONTEND) $(IMAGE_NGINX)"

build-no-cache: backend-no-cache frontend-no-cache nginx-no-cache ## Build all images (no cache)
	@echo ""
	@echo "Built (no cache): $(IMAGE_BACKEND) $(IMAGE_FRONTEND) $(IMAGE_NGINX)"

build-push: .env ## Build multi-arch (amd64+arm64) and push to registry
	docker buildx build --platform $(PLATFORMS) --push -t $(IMAGE_BACKEND) ./backend
	GITHUB_TOKEN=$${GITHUB_TOKEN} docker buildx build --platform $(PLATFORMS) --push -t $(IMAGE_FRONTEND) \
		$(FRONTEND_BUILD_ARGS) ./frontend
	docker buildx build --platform $(PLATFORMS) --push -t $(IMAGE_NGINX) ./nginx
	@echo ""
	@echo "Pushed: $(IMAGE_BACKEND) $(IMAGE_FRONTEND) $(IMAGE_NGINX)"

# ── Run / lifecycle ──────────────────────────────────────────────

restart: stop build run ## Stop, rebuild, and start all containers

PROD_COMPOSE = docker compose -p $(COMPOSE_NAME)

run: .env ## Start all containers (nginx + backend + frontend)
	$(PROD_COMPOSE) up -d
	@echo ""
	@echo "App: http://localhost:$$(grep '^PORT=' .env | cut -d= -f2)"
	@echo "  /        → frontend"
	@echo "  /api/*   → backend"
	@echo "  /health  → backend"

stop: ## Stop containers
	$(PROD_COMPOSE) down

logs: ## Tail container logs
	$(PROD_COMPOSE) logs -f

clean: ## Remove containers, volumes, and local images
	$(PROD_COMPOSE) down --rmi local -v
	@echo "Cleaned containers, volumes, and local images."

push: ## Push pre-built images to registry
	docker push $(IMAGE_BACKEND)
	docker push $(IMAGE_FRONTEND)
	docker push $(IMAGE_NGINX)

# ── Dev mode ────────────────────────────────────────────────────

run-dev: .env ## Start dev servers (source-mounted, hot reload, foreground)
	$(DEV_COMPOSE) up --build

run-dev-d: .env ## Start dev servers (detached)
	$(DEV_COMPOSE) up --build -d
	@echo ""
	@echo "Dev: http://localhost:$$(grep '^PORT=' .env | cut -d= -f2)"
	@echo "Logs: make logs-dev"

stop-dev: ## Stop dev containers
	$(DEV_COMPOSE) down

logs-dev: ## Tail dev container logs
	$(DEV_COMPOSE) logs -f

dev-setup: ## Run ecto.setup (create + migrate + seed) in dev backend
	$(DEV_COMPOSE) exec backend mix ecto.setup

dev-migrate: ## Run pending migrations in dev backend
	$(DEV_COMPOSE) exec backend mix ecto.migrate

dev-regen: ## Regenerate CSS inside dev frontend container
	$(DEV_COMPOSE) exec frontend npm run regen

dev-shell-backend: ## Open IEx shell in backend container
	$(DEV_COMPOSE) exec backend iex -S mix

dev-shell-frontend: ## Open shell in frontend container
	$(DEV_COMPOSE) exec frontend sh

dev-clean: ## Remove dev containers and dependency volumes
	$(DEV_COMPOSE) down -v
	@echo "Cleaned dev containers and dependency volumes."

# ── Prerequisite ───────────────────────────────────────────────

.env:
	@echo "No .env found. Run 'make init' first."
	@exit 1
