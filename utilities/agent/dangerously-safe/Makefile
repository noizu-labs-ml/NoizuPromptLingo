# agent-sandbox (Rust TUI) + legacy dangerously-safe (bash) installer.
#
# `compile`/`test`/`install` are dispatched by ../../mk/subdirs.mk. The Rust
# binary, snippet library, and templates install to XDG locations; the legacy
# bash script is kept alongside.

INSTALL_BIN  := $(HOME)/.local/bin
SHARE_DIR    := $(HOME)/.local/share/agent-sandbox
CONFIG_DIR   := $(HOME)/.config/agent-sandbox

# Honor a caller-provided CARGO_TARGET_DIR (e.g. when the repo volume is full).
CARGO_TARGET_DIR ?= target
RELEASE_BIN := $(CARGO_TARGET_DIR)/release/agent-sandbox

LEGACY_SCRIPT := dangerously-safe

.PHONY: compile test install clean coverage coverage-install

compile:
	cargo build --release
	@echo "✓ built $(RELEASE_BIN)"

test:
	cargo test
	@bash -n bin/$(LEGACY_SCRIPT)
	@echo "✓ tests + legacy script syntax OK"

install: compile
	mkdir -p $(INSTALL_BIN) $(SHARE_DIR)/snippets $(CONFIG_DIR)/templates
	install -m 755 $(RELEASE_BIN) $(INSTALL_BIN)/agent-sandbox
	install -m 755 bin/$(LEGACY_SCRIPT) $(INSTALL_BIN)/$(LEGACY_SCRIPT)
	cp -R snippets/. $(SHARE_DIR)/snippets/
	cp -R templates/. $(CONFIG_DIR)/templates/
	@echo "✓ installed agent-sandbox -> $(INSTALL_BIN)/agent-sandbox"
	@echo "✓ snippets -> $(SHARE_DIR)/snippets"
	@echo "✓ templates -> $(CONFIG_DIR)/templates"

clean:
	cargo clean

coverage-install:
	@command -v cargo-tarpaulin >/dev/null 2>&1 || cargo install cargo-tarpaulin

coverage: coverage-install
	cargo tarpaulin --out Html --output-dir coverage --timeout 300
	@echo "✓ coverage report -> coverage/index.html"
