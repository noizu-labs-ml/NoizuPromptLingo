.PHONY: test build publish public clean help

help:
	@echo "Targets: test build publish public clean"

test:
	vendor/bin/phpunit

build:
	@echo "PHP: no compile step (interpreted)"

publish:
	@echo "PHP: publish via Packagist (push to GitHub triggers update)"

public: publish

clean:
	rm -rf .phpunit.cache
