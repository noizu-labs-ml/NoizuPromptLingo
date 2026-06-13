SUBDIR_TARGETS ?= build compile test install clean
SUBDIR_PREFIX ?=
SUBDIR_DESCRIPTION ?= Utilities

.PHONY: $(SUBDIR_TARGETS) help $(SUBDIRS)

help:
	@echo "$(SUBDIR_DESCRIPTION)"
	@echo "Targets: $(SUBDIR_TARGETS)"
	@echo "Subdirs: $(SUBDIRS)"

$(SUBDIR_TARGETS):
	@set -e; \
	for dir in $(SUBDIRS); do \
		if [ -f "$$dir/Makefile" ]; then \
			target="$@"; \
			if ! $(MAKE) -C "$$dir" -pn "$$target" 2>/dev/null | awk -v target="$$target" 'BEGIN { found = 0 } /^\.PHONY:/ { for (i = 2; i <= NF; i++) if ($$i == target) found = 1 } END { exit found ? 0 : 1 }'; then \
				if [ "$$target" = "build" ] && $(MAKE) -C "$$dir" -pn compile 2>/dev/null | awk 'BEGIN { found = 0 } /^\.PHONY:/ { for (i = 2; i <= NF; i++) if ($$i == "compile") found = 1 } END { exit found ? 0 : 1 }'; then \
					target="compile"; \
				fi; \
			fi; \
			if $(MAKE) -C "$$dir" -pn "$$target" 2>/dev/null | awk -v target="$$target" 'BEGIN { found = 0 } /^\.PHONY:/ { for (i = 2; i <= NF; i++) if ($$i == target) found = 1 } END { exit found ? 0 : 1 }'; then \
				echo "--- $(SUBDIR_PREFIX)$$dir ($@ -> $$target) ---"; \
				$(MAKE) -C "$$dir" "$$target"; \
			else \
				echo "--- $(SUBDIR_PREFIX)$$dir ($@ skipped: no target) ---"; \
			fi; \
		fi; \
	done

$(SUBDIRS):
	@$(MAKE) -C "$@"
