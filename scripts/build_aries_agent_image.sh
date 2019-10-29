#!/bin/bash
#
# Copyright SecureKey Technologies Inc. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

echo "Building aries agent images..."
mkdir -p ./.build
BASE_VERSION="${BASE_VERSION:-0.1.0}"
IS_RELEASE="${IS_RELEASE:-false}"
ARIES_REVISION="${ARIES_REVISION:-master}"
pwd=$(pwd)
git clone https://github.com/hyperledger/aries-framework-go ./.build/aries-framework-go
cd ./.build/aries-framework-go || exit
git checkout "$ARIES_REVISION" || exit
ARCH=$(go env GOARCH)
if [ "$IS_RELEASE" == false ]
then
  EXTRA_VERSION=snapshot-$(git rev-parse --short=7 HEAD)
  PROJECT_VERSION=$BASE_VERSION-$EXTRA_VERSION
else
  PROJECT_VERSION=$BASE_VERSION
fi
make all
cd ..
rm -rf ./.build/aries-framework-go
cd $pwd || exit
export AGENT_IMAGE_TAG=$ARCH-$PROJECT_VERSION

