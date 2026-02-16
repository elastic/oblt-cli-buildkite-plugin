.PHONY: all
all: test plugin-lint integration-test

.PHONY: test
test:
	@docker compose run --rm test

.PHONY: integration-test
integration-test:
	@env CI=true docker compose run --rm integration-test

.PHONY: plugin-lint
plugin-lint:
	@docker compose run --rm plugin-lint

.PHONY: shellcheck
shellcheck:
	@docker compose run --rm shellcheck
