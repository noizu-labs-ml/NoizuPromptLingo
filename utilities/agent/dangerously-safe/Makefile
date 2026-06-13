INSTALL_DIR := $(HOME)/.local/bin
INSTALL_FILE := dangerously-safe
SRC := bin/$(INSTALL_FILE)

.PHONY: compile test install

compile:
	@true

test:
	@bash -n $(SRC)
	@echo "✓ Syntax OK"

install:
	mkdir -p $(INSTALL_DIR)
	install -m 755 $(SRC) $(INSTALL_DIR)/$(INSTALL_FILE)
	@echo "✓ Installed to $(INSTALL_DIR)/$(INSTALL_FILE)"
