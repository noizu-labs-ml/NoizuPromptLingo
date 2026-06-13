INSTALL_DIR ?= $(HOME)/.local/bin
LIB_INSTALL_DIR ?= $(HOME)/.local/lib/media-tools

.PHONY: compile build test install clean uninstall install-legacy

compile: build

build:
	@if ! command -v cargo >/dev/null 2>&1; then \
		echo "media-tool: cargo not found; skipping Rust build."; \
	else \
		cargo build --release; \
		echo "✓ Built target/release/generate-media-prompt"; \
	fi

test:
	@if ! command -v cargo >/dev/null 2>&1; then \
		echo "media-tool: cargo not found; skipping tests."; \
	else \
		cargo build; \
		cargo run -- --dry-run test/; \
		echo "✓ Dry-run test passed"; \
	fi

install: build
	@if ! command -v cargo >/dev/null 2>&1; then \
		echo "media-tool: cargo not found; no Rust binary to install." ; \
		$(MAKE) install-legacy ; \
	else \
		mkdir -p $(INSTALL_DIR); \
		install -m 755 target/release/generate-media-prompt $(INSTALL_DIR)/generate-media-prompt; \
		echo "✓ Installed generate-media-prompt (Rust)"; \
	fi

install-legacy:
	@mkdir -p $(INSTALL_DIR) $(LIB_INSTALL_DIR)
	@install -m 755 bin/generate-media-prompt $(INSTALL_DIR)/generate-media-prompt
	@install -m 644 lib/media-prompt-engine.py $(LIB_INSTALL_DIR)/media-prompt-engine.py
	@echo "✓ Installed generate-media-prompt (Python/bash)"

clean:
	@cargo clean 2>/dev/null || true

uninstall:
	@rm -f $(INSTALL_DIR)/generate-media-prompt
	@rm -rf $(LIB_INSTALL_DIR)
