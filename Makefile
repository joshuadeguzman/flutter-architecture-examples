ROOT := $(shell git rev-parse --show-toplevel)
FLUTTER := $(shell which flutter)
FLUTTER_BIN_DIR := $(shell dirname $(FLUTTER))
FLUTTER_DIR := $(FLUTTER_BIN_DIR:/bin=)
DART := $(FLUTTER_BIN_DIR)/cache/dart-sdk/bin/dart

.PHONY: pubs
pubs:
	cd mobx; $(FLUTTER) pub get
	cd mobx_graphql; $(FLUTTER) pub get

.PHONY: pub
pub:
	cd $(app); $(FLUTTER) pub get

.PHONY: run
run:
	cd "$(app)"; $(FLUTTER) run

# Git
.PHONY: fetch-main
fetch-main:
	$(shell git fetch origin main)

.PHONY: rebase-main
rebase-main:
	$(shell git pull --rebase origin main)