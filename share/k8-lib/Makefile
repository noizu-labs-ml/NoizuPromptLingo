INSTALL_DIR ?= $(HOME)/.local/share/k8-lib
SHELL_FILES := $(wildcard bin/*.sh)

.PHONY: compile test install

compile:
	@true

test:
	@for f in $(SHELL_FILES); do \
		bash -n "$$f" && echo "✓ $$f" || exit 1; \
	done

install:
	@mkdir -p $(INSTALL_DIR)/bin
	@for f in $(SHELL_FILES); do \
		install -m 644 "$$f" "$(INSTALL_DIR)/$$f"; \
	done
	@if [ -f infra-config.yaml.example ]; then \
		install -m 644 infra-config.yaml.example "$(INSTALL_DIR)/infra-config.yaml.example"; \
	fi
	@if [ -f .envrc.k8.dc.example ]; then \
		install -m 644 .envrc.k8.dc.example "$(INSTALL_DIR)/.envrc.k8.dc.example"; \
	fi
	@echo "✓ Installed k8-lib to $(INSTALL_DIR)"
