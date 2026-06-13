INSTALL_DIR := $(HOME)/.local/bin

.PHONY: compile test install clean

compile:
	npm install --no-audit --no-fund
	npx tsc --noEmit

test:
	npx tsc --noEmit

install: compile
	@mkdir -p $(INSTALL_DIR)
	npm link --force 2>/dev/null || true
	@if command -v tabbing-plan >/dev/null 2>&1; then \
		echo "tabbing-plan: linked globally (tabbing-plan, task-memo)"; \
	else \
		printf '#!/usr/bin/env bash\nexec npx --prefix "%s" tsx "%s/bin.ts" "$$@"\n' \
			"$(CURDIR)" "$(CURDIR)" > $(INSTALL_DIR)/tabbing-plan; \
		chmod 755 $(INSTALL_DIR)/tabbing-plan; \
		ln -sf $(INSTALL_DIR)/tabbing-plan $(INSTALL_DIR)/task-memo; \
		echo "tabbing-plan: installed wrapper → $(INSTALL_DIR)/tabbing-plan"; \
		echo "  alias: task-memo → $(INSTALL_DIR)/task-memo"; \
	fi

clean:
	rm -rf node_modules dist
