.PHONY: compile test install uninstall dev

PROJ_DIR := $(shell cd "$(dir $(abspath $(lastword $(MAKEFILE_LIST))))" && pwd)
PREFIX   ?= $(HOME)/.local

compile:
	@true

test:
	@true

install: ## Install deps + symlink claude-assist to ~/.local/bin
	@echo "==> Installing pnpm dependencies..."
	cd "$(PROJ_DIR)" && pnpm install
	@echo "==> Symlinking claude-assist → $(PREFIX)/bin/claude-assist"
	@mkdir -p "$(PREFIX)/bin"
	@ln -sf "$(PROJ_DIR)/bin/claude-assist" "$(PREFIX)/bin/claude-assist"
	@echo "Done. Run 'claude-assist' from anywhere."

uninstall: ## Remove the symlink
	rm -f "$(PREFIX)/bin/claude-assist"

dev: ## Launch (same as running claude-assist)
	"$(PROJ_DIR)/bin/claude-assist"
