#!/bin/bash
#
# Copyright SecureKey Technologies Inc. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

echo "Copying aries feature file..."
pwd=$(pwd)
git clone -b master https://github.com/hyperledger/aries-framework-go ./.build/aries-framework-go
cd ./.build/aries-framework-go || exit
git checkout "$ARIES_FRAMEWORK_VERSION"
mv test/bdd/features ../../test/bdd/aries_feature
cd .. || exit
rm -rf aries-framework-go
cd $pwd || exit
