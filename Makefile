# Quiz Night: common commands. Run `make` (or `make help`) to list them.

SERVER  := quiz_night_server
FLUTTER := quiz_night_flutter
export PATH := $(PATH):$(HOME)/.pub-cache/bin

.DEFAULT_GOAL := help
.PHONY: help setup start phone phone-build build-web test test-server \
        test-flutter analyze format check generate migration icons fonts shots \
        deploy-login deploy-launch deploy clean

help: ## List the commands
	@grep -hE '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | \
	  awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[33mmake %-14s\033[0m %s\n", $$1, $$2}'

# ---- run

setup: ## First-time setup: Serverpod CLI, packages, local secret templates
	dart pub global activate serverpod_cli
	cd $(FLUTTER) && flutter pub get
	@test -f $(SERVER)/.env || cp $(SERVER)/.env.example $(SERVER)/.env
	@echo "Fill in $(SERVER)/.env and $(SERVER)/config/passwords.yaml (see the .example files)."

start: ## Run server + Flutter app locally with hot reload (localhost only)
	cd $(SERVER) && serverpod start

phone: ## Run reachable from any phone via ngrok (reuses the last web build)
	cd $(SERVER) && tool/start_with_ngrok.sh

phone-build: ## Rebuild the web app, then run via ngrok for phones
	cd $(SERVER) && tool/start_with_ngrok.sh --build

build-web: ## Build the Flutter web app into the server (what deploys run)
	cd $(SERVER) && serverpod run flutter_build

# ---- quality

test: test-server test-flutter ## Run all tests

test-server: ## Server unit + integration tests (embedded Postgres, no Docker)
	cd $(SERVER) && dart test

test-flutter: ## Flutter unit, cubit and widget tests
	cd $(FLUTTER) && flutter test

analyze: ## Static analysis for server and app
	cd $(SERVER) && dart analyze
	cd $(FLUTTER) && flutter analyze

format: ## Format all Dart code
	dart format $(SERVER)/lib $(SERVER)/test $(FLUTTER)/lib $(FLUTTER)/test

check: analyze test ## Analyze and test everything (run before committing)

# ---- code generation

generate: ## Regenerate Serverpod server + client code after model/endpoint changes
	cd $(SERVER) && serverpod generate

migration: generate ## Create a database migration after changing a model with a table
	cd $(SERVER) && serverpod create-migration

icons: ## Re-render the favicon and home-screen icons from the crest
	cd $(FLUTTER) && flutter test tool/generate_icons_test.dart

shots: ## Re-render the README screenshots into docs/screenshots
	cd $(FLUTTER) && SHOT_DIR=$(CURDIR)/docs/screenshots flutter test test/widgets/readme_shots_test.dart
	mkdir -p docs/screenshots/.landing
	cd $(FLUTTER) && SHOT_DIR=$(CURDIR)/docs/screenshots/.landing flutter test test/widgets/landing_test.dart --plain-name "home page on a desktop"
	mv docs/screenshots/.landing/home_desktop_0.png docs/screenshots/landing.png && rm -rf docs/screenshots/.landing

fonts: ## Rebuild the bundled font subsets (needs fonttools; see tool/make_fonts.py)
	@echo "Download the source fonts listed in $(FLUTTER)/tool/make_fonts.py into SRC, then:"
	@echo "  python3 $(FLUTTER)/tool/make_fonts.py SRC $(FLUTTER)/assets/fonts"

# ---- deploy (Serverpod Cloud, see DEPLOY.md)

deploy-login: ## Sign in to Serverpod Cloud (opens the browser)
	serverpod cloud auth login

deploy-launch: ## First deploy: create the Cloud project and launch
	cd $(SERVER) && serverpod cloud launch

deploy: ## Redeploy the current code to Serverpod Cloud
	cd $(SERVER) && serverpod cloud deploy

# ---- housekeeping

clean: ## Remove build output (web build, Flutter build cache)
	rm -rf $(SERVER)/web/app
	cd $(FLUTTER) && flutter clean
