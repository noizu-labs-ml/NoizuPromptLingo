PLIST      := com.keithbrings.fstab-remount.plist
PLIST_DST  := /Library/LaunchDaemons/$(PLIST)
BIN_SRC    := fstab-remount
BIN_DST    := /usr/local/bin/fstab-remount
FSTAB_STUB := osx-fstab.stub
FSTAB_DST  := /etc/osx-fstab
SUDO       ?= sudo

.PHONY: install uninstall status logs

install:
	@echo "==> Installing fstab-remount"
	@if $(SUDO) -n true 2>/dev/null; then \
		$(SUDO) install -m 755 $(BIN_SRC) $(BIN_DST); \
		$(SUDO) install -m 644 $(PLIST) $(PLIST_DST); \
		if [ ! -f $(FSTAB_DST) ]; then \
			echo "==> Creating stub $(FSTAB_DST)"; \
			$(SUDO) install -m 644 $(FSTAB_STUB) $(FSTAB_DST); \
		else \
			echo "==> $(FSTAB_DST) already exists — skipping"; \
		fi; \
		$(SUDO) launchctl bootout system/$(basename $(PLIST) .plist) 2>/dev/null || true; \
		$(SUDO) launchctl bootstrap system $(PLIST_DST); \
		echo "==> Done. Edit $(FSTAB_DST) then reboot or run: sudo launchctl kickstart system/com.keithbrings.fstab-remount"; \
	else \
		echo "==> Skipping fstab-remount: noninteractive sudo is unavailable"; \
		echo "    Run manually when ready: cd $(CURDIR) && sudo make install"; \
	fi

uninstall:
	@echo "==> Uninstalling fstab-remount"
	$(SUDO) launchctl bootout system/com.keithbrings.fstab-remount 2>/dev/null || true
	$(SUDO) rm -f $(BIN_DST) $(PLIST_DST)
	@echo "==> Removed. $(FSTAB_DST) left in place."

status:
	@$(SUDO) launchctl print system/com.keithbrings.fstab-remount 2>/dev/null || echo "Not loaded"

logs:
	@$(SUDO) tail -50 /var/log/fstab-remount.log
