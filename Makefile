ROOT := $(shell git rev-parse --show-toplevel)
FLUTTER := $(shell which flutter)
FLUTTER_BIN_DIR := $(shell dirname $(FLUTTER))
FLUTTER_DIR := $(FLUTTER_BIN_DIR:/bin=)
DART := $(FLUTTER_BIN_DIR)/cache/dart-sdk/bin/dart

.PHONY: deps
deps:
	cd mobx; $(FLUTTER) pub get
	cd mobx_graphql; $(FLUTTER) pub get

.PHONY: mobx
mobx:
	cd mobx; $(FLUTTER) run

# Git
.PHONY: fetch-main
fetch-main:
	$(shell git fetch origin main)

.PHONY: rebase-main
rebase-main:
	$(shell git pull --rebase origin main)