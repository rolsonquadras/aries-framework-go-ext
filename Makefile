# Copyright SecureKey Technologies Inc.
#
# SPDX-License-Identifier: Apache-2.0

# This can be a commit hash or a tag (or any git ref)
export SIDETREE_FABRIC_VERSION = 784de6e9f4bd68a1a5f10538fb69d53b26076ed4

.PHONY: all
all: checks bdd-test

.PHONY: checks
checks: license lint

.PHONY: lint
lint:
	@scripts/check_lint.sh

.PHONY: license
license:
	@scripts/check_license.sh

.PHONY: bdd-test
bdd-test: clean build-cc
	@scripts/check_integration.sh

.PHONY: build-cc
build-cc: clean
	@echo "Building cc"
	@mkdir -p ./.build
	@scripts/copycc.sh

.PHONY: clean
clean:
	rm -Rf ./.build
	rm -Rf ./test/bdd/db
	rm -Rf ./test/bdd/fixtures/keys/tls
	rm -Rf ./test/bdd/*.log
