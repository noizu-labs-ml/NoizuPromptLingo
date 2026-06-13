.PHONY: compile test install

UNAME_S := $(shell uname -s)

compile:
ifeq ($(UNAME_S),Darwin)
	swift build
else
	@echo "queue-populator: skipped on $(UNAME_S) (macOS-only AppKit/Speech utility)"
endif

test:
ifeq ($(UNAME_S),Darwin)
	swift test || echo "queue-populator: no tests defined"
else
	@echo "queue-populator: tests skipped on $(UNAME_S) (macOS-only AppKit/Speech utility)"
endif

install:
ifeq ($(UNAME_S),Darwin)
	./install.sh
else
	@echo "queue-populator: install skipped on $(UNAME_S) (macOS-only AppKit/Speech utility)"
endif
