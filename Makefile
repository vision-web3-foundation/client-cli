VISION_CLIENT_CLI_VERSION := $(shell poetry version -s)
PYTHON_FILES := vision/cli tests

.PHONY: check-version
check-version:
	@if [ -z "$(VERSION)" ]; then \
		echo "Error: VERSION is not set"; \
		exit 1; \
	fi
	@VERSION_FROM_POETRY=$$(poetry version -s) ; \
	if test "$$VERSION_FROM_POETRY" != "$(VERSION)"; then \
		echo "Version mismatch: expected $(VERSION), got $$VERSION_FROM_POETRY" ; \
		exit 1 ; \
	else \
		echo "Version check passed" ; \
	fi

.PHONY: dist
dist: wheel docker

.PHONY: build
build:
	poetry build

.PHONY: code
code: check format lint sort bandit test

.PHONY: check
check:
	poetry run mypy $(PYTHON_FILES)

.PHONY: format
format:
	poetry run yapf --in-place --recursive $(PYTHON_FILES)

.PHONY: format-check
format-check:
	poetry run yapf --diff --recursive $(PYTHON_FILES)

.PHONY: lint
lint:
	poetry run flake8 $(PYTHON_FILES)

.PHONY: sort
sort:
	poetry run isort --force-single-line-imports $(PYTHON_FILES)

.PHONY: sort-check
sort-check:
	poetry run isort --force-single-line-imports $(PYTHON_FILES) --check-only

.PHONY: bandit
bandit:
	poetry run bandit -r $(PYTHON_FILES) --quiet --configfile=.bandit

.PHONY: bandit-check
bandit-check:
	poetry run bandit -r $(PYTHON_FILES) --configfile=.bandit

.PHONY: test
test:
	poetry run python3 -m pytest tests

.PHONY: coverage
coverage:
	poetry run python3 -m pytest --cov-report term-missing --cov=vision tests

.PHONY: wheel
wheel:
	poetry build

.PHONY: docker
docker:
	docker build -t vsnw3/vision-client .

.PHONY: install
install: dist/vision_client_cli-$(VISION_CLIENT_CLI_VERSION)-py3-none-any.whl
	poetry run python3 -m pip install dist/vision_client_cli-$(VISION_CLIENT_CLI_VERSION)-py3-none-any.whl

.PHONY: uninstall
uninstall:
	poetry run python3 -m pip uninstall -y vision-client-cli

.PHONY: local-common
local-common:
ifndef DEV_VISION_COMMON
	$(error Please define DEV_VISION_COMMON variable)
endif
	$(eval CURRENT_COMMON := $(shell echo .venv/lib/python3.*/site-packages/vision/common))
	@if [ -d "$(CURRENT_COMMON)" ]; then \
		rm -rf "$(CURRENT_COMMON)"; \
		ln -s "$(DEV_VISION_COMMON)" "$(CURRENT_COMMON)"; \
	else \
		echo "Directory $(CURRENT_COMMON) does not exist"; \
	fi

.PHONY: local-client-library
local-client-library:
ifndef DEV_VISION_CLIENT_LIBRARY
	$(error Please define DEV_VISION_CLIENT_LIBRARY variable)
endif
	$(eval CURRENT_CLIENT_LIBRARY := $(shell echo .venv/lib/python3.*/site-packages/vision/client))
	@if [ -d "$(CURRENT_CLIENT_LIBRARY)" ]; then \
		rm -rf "$(CURRENT_CLIENT_LIBRARY)"; \
		ln -s "$(DEV_VISION_CLIENT_LIBRARY)" "$(CURRENT_CLIENT_LIBRARY)"; \
	else \
		echo "Directory $(CURRENT_CLIENT_LIBRARY) does not exist"; \
	fi

.PHONY: clean
clean:
	rm -r -f build/
	rm -r -f dist/
	rm -r -f vision_client_cli.egg-info/
ifneq ($(shell docker images -q vsnw3/vision-client 2>/dev/null),)
	docker rmi -f vsnw3/vision-client
endif
