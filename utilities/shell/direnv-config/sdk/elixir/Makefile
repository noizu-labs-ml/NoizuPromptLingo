.PHONY: test build publish public clean help

help:
	@echo "Targets: test build publish public clean"

test:
	mix test

build:
	mix compile

publish: build
	mix hex.publish

public: publish

clean:
	mix clean
	rm -rf _build deps
