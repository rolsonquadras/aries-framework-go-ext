# Copyright SecureKey Technologies Inc.
#
# SPDX-License-Identifier: Apache-2.0


# Tool commands (overridable)
DOCKER_CMD ?= docker

# Local variables used by makefile
PROJECT_NAME   = aries-framework-go-ext
ARCH           = $(shell go env GOARCH)

# Fabric tools docker image (overridable)
FABRIC_TOOLS_IMAGE   ?= hyperledger/fabric-tools
FABRIC_TOOLS_VERSION ?= 2.0.0-alpha
FABRIC_TOOLS_TAG     ?= $(ARCH)-$(FABRIC_TOOLS_VERSION)

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
bdd-test: clean checks populate-fixtures build-cc
	@scripts/check_integration.sh

.PHONY: build-cc
build-cc: clean
	@echo "Building cc"
	@mkdir -p ./.build
	@scripts/copycc.sh


.PHONY: crypto-gen
crypto-gen:
	@echo "Generating crypto directory ..."
	@$(DOCKER_CMD) run -i \
		-v /$(abspath .):/opt/workspace/$(PROJECT_NAME) -u $(shell id -u):$(shell id -g) \
		$(FABRIC_TOOLS_IMAGE):$(FABRIC_TOOLS_TAG) \
		//bin/bash -c "FABRIC_VERSION_DIR=fabric /opt/workspace/${PROJECT_NAME}/scripts/generate_crypto.sh"

.PHONY: channel-config-gen
channel-config-gen:
	@echo "Generating test channel configuration transactions and blocks ..."
	@$(DOCKER_CMD) run -i \
		-v /$(abspath .):/opt/workspace/$(PROJECT_NAME) -u $(shell id -u):$(shell id -g) \
		$(FABRIC_TOOLS_IMAGE):$(FABRIC_TOOLS_TAG) \
		//bin/bash -c "FABRIC_VERSION_DIR=fabric/ /opt/workspace/${PROJECT_NAME}/scripts/generate_channeltx.sh"

.PHONY: populate-fixtures
populate-fixtures: clean
	@scripts/populate-fixtures.sh -f

.PHONY: clean
clean:
	rm -Rf ./.build
	rm -Rf ./test/bdd/fixtures/fabric/channel
	rm -Rf ./test/bdd/fixtures/fabric/crypto-config
	rm -Rf ./test/bdd/*.log
