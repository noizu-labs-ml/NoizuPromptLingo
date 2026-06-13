INSTALL_DIR := $(HOME)/.local/share/auto-sudo
INSTALL_FILE := auto-sudo.zsh
SOURCE_LINE := source "$(INSTALL_DIR)/$(INSTALL_FILE)"
ZSHRC := $(HOME)/.zshrc

.PHONY: compile test install

compile:
	@true

test:
	@true

install:
	@mkdir -p $(INSTALL_DIR)
	@src=$$(realpath $(INSTALL_FILE)); dst=$$(realpath $(INSTALL_DIR)/$(INSTALL_FILE) 2>/dev/null); \
	if [ "$$src" = "$$dst" ]; then \
		echo "auto-sudo: already installed (same file) — skipping"; \
	else \
		install -m 644 $(INSTALL_FILE) $(INSTALL_DIR)/$(INSTALL_FILE); \
	fi
	@if grep -qF '$(INSTALL_FILE)' $(ZSHRC) 2>/dev/null; then \
		echo "✓ Already sourced in ~/.zshrc"; \
	else \
		echo '' >> $(ZSHRC); \
		echo '# auto-sudo: shims for vim, chown, chgrp, chmod' >> $(ZSHRC); \
		echo '$(SOURCE_LINE)' >> $(ZSHRC); \
		echo "✓ Added source line to ~/.zshrc"; \
	fi
	@echo "Run: source ~/.zshrc   (or open a new shell)"
