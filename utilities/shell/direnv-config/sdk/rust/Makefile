.PHONY: test build publish public clean help

help:
	@echo "Targets: test build publish public clean"

test:
	cargo test

build:
	cargo build --release

publish: build
	cargo publish

public: publish

clean:
	cargo clean
