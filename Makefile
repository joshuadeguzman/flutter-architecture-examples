APPS := mobx mobx_graphql riverpod
FLUTTER ?= flutter
DART ?= dart

# Get dependencies for one example: make pub app=riverpod
.PHONY: pub
pub:
	cd $(app) && $(FLUTTER) pub get

# Get dependencies for every example.
.PHONY: pubs
pubs:
	@for a in $(APPS); do (cd $$a && $(FLUTTER) pub get) || exit 1; done

# Run one example: make run app=riverpod
.PHONY: run
run:
	cd $(app) && $(FLUTTER) run

# Regenerate MobX code after changing a store: make codegen app=mobx
.PHONY: codegen
codegen:
	cd $(app) && $(DART) run build_runner build -d

# Analyze and test every example.
.PHONY: check
check:
	@for a in $(APPS); do \
		echo "== $$a"; \
		(cd $$a && $(FLUTTER) analyze && $(FLUTTER) test) || exit 1; \
	done

# Re-render the diagrams in .github/images. Needs Python 3 and Google Chrome.
.PHONY: diagrams
diagrams:
	python3 docs/diagrams/generate.py docs/diagrams
	python3 docs/diagrams/render.py docs/diagrams
	mv docs/diagrams/*.png .github/images/
	rm -f docs/diagrams/*.html
