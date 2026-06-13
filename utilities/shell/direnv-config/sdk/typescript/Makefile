.PHONY: test build publish public clean help

help:
	@echo "Targets: test build publish public clean"

test:
	npm test

build:
	npm run build

publish: build
	npm publish --access public

public: publish

clean:
	rm -rf dist
