# DevOps Deployment — Universal Makefile
# https://github.com/mosabbir-maruf/devops-deployment

SHELL := /bin/bash
.DEFAULT_GOAL := help

# ---- Project detection ----
HAS_DOCKER   := $(shell command -v docker 2>/dev/null && echo yes)
HAS_NODE     := $(shell command -v node   2>/dev/null && echo yes)
HAS_GO       := $(shell command -v go     2>/dev/null && echo yes)
HAS_PYTHON   := $(shell command -v python3 2>/dev/null && echo yes)

IS_NODE      := $(shell test -f package.json && echo yes)
IS_GO        := $(shell test -f go.mod && echo yes)
IS_PYTHON    := $(shell test -f requirements.txt || test -f pyproject.toml && echo yes)
HAS_DOCKERFILE := $(shell test -f Dockerfile && echo yes)
HAS_COMPOSE  := $(shell test -f docker-compose.yml || test -f docker-compose.yaml && echo yes)

PORT         ?= 3000
DEV_PORT     ?= $(PORT)
PROD_PORT    ?= $(PORT)
IMAGE_NAME   ?= $(notdir $(CURDIR))
COMPOSE_FILE ?= docker-compose.yml

# ---- Helpers ----
define banner
	@echo ""
	@echo "DevOps Deployment — Makefile"
	@echo "============================"
	@printf "  Project: %s\n" "$(notdir $(CURDIR))"
	@printf "  Type:    %s\n" "$(strip $(call project_type))"
	@echo ""
endef

define project_type
	$(if $(IS_NODE),Node.js)$(if $(IS_GO),Go)$(if $(IS_PYTHON),Python)$(if $(HAS_DOCKERFILE), / Docker)
endef

# ---- Target list ----
.PHONY: help dev prod build stop logs shell install \
	lint test clean deep-clean info

help: ## Show this help
	@echo ""
	@echo "DevOps Deployment — Makefile"
	@echo "============================"
	@printf "  Project: %s\n" "$(notdir $(CURDIR))"
	@echo ""
	@echo "Usage: make <target>"
	@echo ""
	@grep -E '^[a-zA-Z0-9_-]+:.*##' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*## "}; {printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2}'
	@echo ""

# ---- Generic dev / prod (Docker) ----
dev: ## Run project in dev mode (hot-reload with Docker)
ifndef HAS_DOCKER
	$(error Docker is required but not installed)
endif
ifneq ($(HAS_COMPOSE),yes)
	$(info No compose file found — using generic dev container)
endif
ifeq ($(IS_NODE),yes)
	docker run --rm -it \
		--name $(IMAGE_NAME)-dev \
		-p $(DEV_PORT):$(DEV_PORT) \
		-v $(PWD):/app \
		-v /app/node_modules \
		-w /app \
		node:24-slim \
		sh -c "npm install && npm run dev"
else ifeq ($(IS_GO),yes)
	@echo "Starting Go dev server on port $(DEV_PORT)..."
	go run . &
else ifeq ($(IS_PYTHON),yes)
	@echo "Starting Python dev server on port $(DEV_PORT)..."
	python3 -m flask run --port $(DEV_PORT) 2>/dev/null || \
	python3 -m uvicorn main:app --port $(DEV_PORT) 2>/dev/null || \
	python3 manage.py runserver 0.0.0.0:$(DEV_PORT) 2>/dev/null || \
	@echo "No known dev server found — start your app manually"
else
	@echo "Unknown project type. Please add a dev target for your project."
endif

build: ## Build Docker image
ifndef HAS_DOCKER
	$(error Docker is required but not installed)
endif
	docker build -t $(IMAGE_NAME) .

prod: build ## Run project in production mode (build + run)
ifndef HAS_DOCKER
	$(error Docker is required but not installed)
endif
	docker run --rm -it \
		--name $(IMAGE_NAME)-prod \
		-p $(PROD_PORT):$(PROD_PORT) \
		$(IMAGE_NAME)

stop: ## Stop all project containers
	docker stop $(IMAGE_NAME)-dev $(IMAGE_NAME)-prod 2>/dev/null || true

logs: ## Follow production container logs
	docker logs -f $(IMAGE_NAME)-prod

# ---- Utility ----
shell: ## Open a shell in a Node container (if Node project)
ifeq ($(IS_NODE),yes)
	docker run --rm -it \
		-v $(PWD):/app \
		-v /app/node_modules \
		-w /app \
		node:24-slim \
		sh
else
	@echo "Shell target is only available for Node.js projects by default."
endif

install: ## Install dependencies
ifeq ($(IS_NODE),yes)
	docker run --rm -it \
		-v $(PWD):/app \
		-v /app/node_modules \
		-w /app \
		node:24-slim \
		npm install
else ifeq ($(IS_GO),yes)
	go mod tidy
else ifeq ($(IS_PYTHON),yes)
	pip install -r requirements.txt 2>/dev/null || pip install -e .
else
	@echo "No known package manager for this project."
endif

lint: ## Run linter
ifeq ($(IS_NODE),yes)
	npm run lint 2>/dev/null || npx eslint . 2>/dev/null || @echo "No linter configured"
else ifeq ($(IS_GO),yes)
	golangci-lint run 2>/dev/null || go vet ./...
else ifeq ($(IS_PYTHON),yes)
	ruff check . 2>/dev/null || pylint .
endif

test: ## Run tests
ifeq ($(IS_NODE),yes)
	npm test 2>/dev/null || npm run test
else ifeq ($(IS_GO),yes)
	go test ./...
else ifeq ($(IS_PYTHON),yes)
	python3 -m pytest 2>/dev/null || python3 -m unittest
else
	@echo "No test command configured for this project."
endif

clean: ## Remove dangling Docker resources
ifdef HAS_DOCKER
	docker container prune -f
endif

deep-clean: ## Remove ALL unused Docker resources (images, containers, volumes)
ifdef HAS_DOCKER
	docker system prune -a -f
endif

info: ## Show project info
	@echo "Project:     $(notdir $(CURDIR))"
	@echo "Type:        $(strip $(call project_type))"
	@echo "Docker:      $(HAS_DOCKER)"
	@echo "Compose:     $(HAS_COMPOSE)"
	@echo "Port (dev):  $(DEV_PORT)"
	@echo "Port (prod): $(PROD_PORT)"
	@echo "Image name:  $(IMAGE_NAME)"
	@echo "Node.js:     $(IS_NODE)"
	@echo "Go:          $(IS_GO)"
	@echo "Python:      $(IS_PYTHON)"
