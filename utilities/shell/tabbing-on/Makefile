INSTALL_DIR := $(HOME)/.local/bin
SHARE_DIR   := $(HOME)/.local/share/tabbing-on

RUST_DIR    := rust
SHELL_DIR   := shell-impl
INK_PLAN_DIR := ink-plan
DIRENV_LIB  := $(HOME)/.config/direnv/lib

SYMLINKS := tabbing-off tabbing-status tabbing-info tabbing-clear tabbing-todo tabbing-report \
            tabbing-history tabbing-recordings tabbing-doctor tabbing-marquee \
            tabbing-init tabbing-theme tabbing-style tabbing-claude-statusline tabbing-plan task-memo \
            demo-runner tabbing-daemon

.PHONY: compile test install install-shell install-ink uninstall uninstall-shell uninstall-ink clean

# --- Rust (default) ---

compile:
	@if ! command -v cargo >/dev/null 2>&1; then \
		echo "tabbing-on: cargo not found; skipping Rust build."; \
	else \
		cd $(RUST_DIR) && cargo build --release; \
	fi

test:
	@if ! command -v cargo >/dev/null 2>&1; then \
		echo "tabbing-on: cargo not found; skipping tests."; \
	else \
		cd $(RUST_DIR) && cargo test; \
	fi

install: compile
	@if ! command -v cargo >/dev/null 2>&1; then \
		echo "tabbing-on: cargo not found; using shell fallback install."; \
		$(MAKE) install-shell; \
	else \
		mkdir -p $(INSTALL_DIR); \
		install -m 755 $(RUST_DIR)/target/release/tabbing-on $(INSTALL_DIR)/tabbing-on; \
		for link in $(SYMLINKS); do \
			ln -sf $(INSTALL_DIR)/tabbing-on $(INSTALL_DIR)/$$link; \
		done; \
		mkdir -p $(SHARE_DIR)/lib $(SHARE_DIR)/shell; \
		install -m 644 $(SHELL_DIR)/lib/*.sh $(SHARE_DIR)/lib/; \
		install -m 644 $(SHELL_DIR)/shell/tabbing.bash $(SHELL_DIR)/shell/tabbing.zsh $(SHARE_DIR)/shell/; \
		mkdir -p $(DIRENV_LIB); \
		install -m 644 $(SHELL_DIR)/direnv/tabbing.sh $(DIRENV_LIB)/tabbing.sh; \
		echo "Installed: tabbing-on (rust) → $(INSTALL_DIR)"; \
		echo "  Symlinks: $(SYMLINKS)"; \
		echo "  Shell libs → $(SHARE_DIR)"; \
		echo "  direnv helper → $(DIRENV_LIB)/tabbing.sh"; \
	fi

uninstall:
	@rm -f $(INSTALL_DIR)/tabbing-on
	@for link in $(SYMLINKS); do rm -f $(INSTALL_DIR)/$$link; done
	@rm -rf $(SHARE_DIR)
	@echo "Removed tabbing-on (rust) from $(INSTALL_DIR) and $(SHARE_DIR)"

clean:
	cd $(RUST_DIR) && cargo clean
	-$(MAKE) -C $(INK_PLAN_DIR) clean 2>/dev/null

# --- Ink Plan (tabbing-plan / task-memo via Node.js) ---

install-ink:
	$(MAKE) -C $(INK_PLAN_DIR) install

uninstall-ink:
	@rm -f $(INSTALL_DIR)/tabbing-plan $(INSTALL_DIR)/task-memo
	@echo "Removed tabbing-plan + task-memo (ink) from $(INSTALL_DIR)"

# --- Shell (legacy) ---

install-shell:
	@mkdir -p $(INSTALL_DIR) $(SHARE_DIR)/lib $(SHARE_DIR)/shell
	@for f in $(SHELL_DIR)/bin/*; do \
		src=$$(realpath "$$f"); dst=$$(realpath "$(INSTALL_DIR)/$$(basename $$f)" 2>/dev/null); \
		if [ "$$src" = "$$dst" ]; then \
			echo "$$(basename $$f): same file — skipping"; \
		else \
			install -m 755 "$$f" $(INSTALL_DIR)/; \
		fi; \
	done
	@install -m 644 $(SHELL_DIR)/lib/*.sh $(SHARE_DIR)/lib/
	@install -m 644 $(SHELL_DIR)/shell/tabbing.bash $(SHELL_DIR)/shell/tabbing.zsh $(SHARE_DIR)/shell/
	@mkdir -p $(DIRENV_LIB)
	@install -m 644 $(SHELL_DIR)/direnv/tabbing.sh $(DIRENV_LIB)/tabbing.sh
	@echo "Installed: bin (shell) → $(INSTALL_DIR), lib+shell → $(SHARE_DIR)"
	@echo "  direnv helper → $(DIRENV_LIB)/tabbing.sh"

uninstall-shell:
	@for f in $(SHELL_DIR)/bin/*; do rm -f "$(INSTALL_DIR)/$$(basename $$f)"; done
	@rm -rf $(SHARE_DIR)
	@echo "Removed tabbing-on (shell) from $(INSTALL_DIR) and $(SHARE_DIR)"
