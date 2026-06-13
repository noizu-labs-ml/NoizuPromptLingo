INSTALL_DIR ?= $(HOME)/.local/bin
RUST_DIR     = rust
RUST_BIN     = $(RUST_DIR)/target/release/infisical

.PHONY: all compile test install install-legacy install-rust clean

all: install

# Build the Rust binary
compile:
	@if ! command -v cargo >/dev/null 2>&1; then \
		echo "secret-utils: cargo not found; skipping Rust build."; \
	else \
		cd $(RUST_DIR) && cargo build --release; \
	fi

# Run any tests (stub for now)
test:
	@cd $(RUST_DIR) && cargo test 2>/dev/null || true

# Install the Rust binary (default)
install: compile
	@if ! command -v cargo >/dev/null 2>&1; then \
		echo "secret-utils: cargo not found; skipping Rust install."; \
		$(MAKE) install-legacy; \
	else \
		mkdir -p $(INSTALL_DIR); \
		install -m 755 $(RUST_BIN) $(INSTALL_DIR)/infisical; \
		echo "✓ Installed infisical → $(INSTALL_DIR)/infisical"; \
		echo ""; \
		echo "Usage: infisical <command>"; \
		echo "  infisical verify   infisical fetch <path>   infisical audit"; \
		echo "  infisical populate infisical set <name>     infisical view-dc"; \
		echo "  infisical rebuild  infisical find-dc-line   infisical bootstrap"; \
		$(MAKE) install-legacy; \
	fi

install-rust: install

# Install legacy shell scripts
install-legacy:
	@mkdir -p $(INSTALL_DIR)
	@for f in hydrate-envrc infisical-populate-secrets infisical-bootstrap infisical-fetch-secrets infisical-rebuild export-infisical-secrets infisical-view-dc infisical-find-dc-line infisical-verify infisical-set-secret infisical-audit; do \
		install -m 755 "bin/$$f" "$(INSTALL_DIR)/$$f"; \
		echo "✓ Installed $$f"; \
	done

clean:
	@cd $(RUST_DIR) && cargo clean
