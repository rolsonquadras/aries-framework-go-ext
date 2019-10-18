# Copyright SecureKey Technologies Inc.
#
# SPDX-License-Identifier: Apache-2.0

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
bdd-test: clean generate-test-keys
	@scripts/check_integration.sh

.PHONY: clean
clean:
	rm -Rf ./test/bdd/db
	rm -Rf ./test/bdd/fixtures/keys/tls
	rm -Rf ./test/bdd/*.log
