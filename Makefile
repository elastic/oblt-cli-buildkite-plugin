.PHONY: all
all: test lint integration-test

.PHONY: test
test:
	@docker compose run --rm test

.PHONY: integration-test
integration-test:
	@docker compose run --rm integration-test

.PHONY: plugin-lint
plugin-lint:
	@docker compose run plugin-lint
