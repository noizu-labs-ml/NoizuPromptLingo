# skill-manage: multi-source skill / agent / command linker + catalog.
#
# Now invoked via the parent llm-toolkit Makefile (../Makefile); targets here
# are unchanged and still usable directly for local dev.

INSTALL_BIN := $(HOME)/.local/bin
CARGO_TARGET_DIR ?= target
RELEASE_BIN := $(CARGO_TARGET_DIR)/release/skill-manage
SHARE_DIR := $(HOME)/.local/share/skill-manage

.PHONY: compile test install uninstall clean

compile:
	cargo build --release
	@echo "✓ built $(RELEASE_BIN)"

test:
	cargo test
	@echo "✓ tests OK"

install: compile test
	mkdir -p $(INSTALL_BIN) $(SHARE_DIR)/schema
	install -m 755 $(RELEASE_BIN) $(INSTALL_BIN)/skill-manage
	cp -f schema/catalog.example.yaml $(SHARE_DIR)/schema/ 2>/dev/null || true
	cp -f schema/config.example.yaml $(SHARE_DIR)/schema/ 2>/dev/null || true
	@echo "✓ installed skill-manage -> $(INSTALL_BIN)/skill-manage"
	@echo "✓ examples -> $(SHARE_DIR)/schema"

uninstall:
	rm -f $(INSTALL_BIN)/skill-manage
	rm -rf $(SHARE_DIR)

clean:
	cargo clean
