PREFIX ?= $(HOME)/bin
SCRIPTS := revtunnel.sh ngrok-nomachine.sh ngrok-cron.sh

.PHONY: install uninstall help

help:
	@echo "Targets: install uninstall"
	@echo "Set PREFIX to change install dir (default: ~/bin)"

install:
	@mkdir -p $(PREFIX)
	@for s in $(SCRIPTS); do \
		ln -sfn $(CURDIR)/$$s $(PREFIX)/$$s; \
		echo "  $(PREFIX)/$$s -> $(CURDIR)/$$s"; \
	done

uninstall:
	@for s in $(SCRIPTS); do \
		rm -f $(PREFIX)/$$s; \
		echo "  removed $(PREFIX)/$$s"; \
	done
