INSTALL_DIR ?= $(HOME)/.local/bin

.PHONY: compile test install

compile:
	@true

test:
	@true

install:
	@mkdir -p $(INSTALL_DIR)
	@ln -sf $(CURDIR)/bin/liquibase-shell "$(INSTALL_DIR)/liquibase-shell"
	@ln -sf $(CURDIR)/bin/liquibase-update "$(INSTALL_DIR)/liquibase-update"
	@install -m 755 bin/tsdb-snapshot "$(INSTALL_DIR)/tsdb-snapshot"
	@echo "✓ Installed liquibase-shell, liquibase-update (symlinked), tsdb-snapshot"
	@echo "Note: SQL files are templates — copy and customize manually"
