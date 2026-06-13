.PHONY: test build publish public clean help

help:
	@echo "Targets: test build publish public clean"

test:
	python -m pytest

build:
	python -m build

publish: build
	twine upload dist/*

public: publish

clean:
	rm -rf dist build src/*.egg-info
