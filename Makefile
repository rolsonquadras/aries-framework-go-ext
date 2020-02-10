# Copyright SecureKey Technologies Inc.
#
# SPDX-License-Identifier: Apache-2.0


# Tool commands (overridable)
DOCKER_CMD ?= docker

# Local variables used by makefile
PROJECT_NAME       = aries-framework-go-ext
ARCH               = $(shell go env GOARCH)
CONTAINER_IDS      = $(shell docker ps -a -q)
DEV_IMAGES         = $(shell docker images dev-* -q)

# Fabric tools docker image (overridable)
FABRIC_TOOLS_IMAGE   ?= hyperledger/fabric-tools
FABRIC_TOOLS_VERSION ?= 2.0.0-alpha
FABRIC_TOOLS_TAG     ?= $(ARCH)-$(FABRIC_TOOLS_VERSION)

# Fabric peer ext docker image (overridable)
FABRIC_PEER_EXT_IMAGE   ?= trustbloc/fabric-peer
FABRIC_PEER_EXT_VERSION ?= 0.1.1
FABRIC_PEER_EXT_TAG     ?= $(ARCH)-$(FABRIC_PEER_EXT_VERSION)

# This can be a commit hash or a tag (or any git ref)
export ARIES_FRAMEWORK_VERSION = v0.1.1
export FABRIC_CLI_EXT_VERSION ?= 3fd66894726c1afcd904413dcfa3b4d586ea6c92


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
bdd-test: clean populate-fixtures docker-thirdparty copy-aries-feature-file fabric-cli
	@scripts/check_integration.sh

.PHONY: copy-aries-feature-file
copy-aries-feature-file: clean
	@scripts/copy_aries_feature_file.sh

.PHONY: docker-thirdparty
docker-thirdparty:
	docker pull couchdb:2.2.0
	docker pull hyperledger/fabric-orderer:$(ARCH)-2.0.0-alpha

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

fabric-cli:
	@scripts/build_fabric_cli.sh

.PHONY: clean
clean:
	rm -Rf ./.build
	rm -Rf ./test/bdd/fixtures/fabric/channel
	rm -Rf ./test/bdd/fixtures/fabric/crypto-config
	rm -Rf ./test/bdd/.fabriccli
	rm -Rf ./test/bdd/db
	rm -Rf ./test/bdd/aries_feature
	rm -Rf ./test/bdd/*.log

clean-images:
	@echo "Stopping all containers, pruning containers and images, deleting dev images"
ifneq ($(strip $(CONTAINER_IDS)),)
	@docker stop $(CONTAINER_IDS)
endif
	@docker system prune -f
ifneq ($(strip $(DEV_IMAGES)),)
	@docker rmi $(DEV_IMAGES) -f
endif
