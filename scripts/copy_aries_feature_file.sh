#!/bin/bash
#
# Copyright SecureKey Technologies Inc. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

echo "Copying aries feature file..."
git clone -b master https://github.com/hyperledger/aries-framework-go ./.build/aries-framework-go
mv ./.build/aries-framework-go/test/bdd/features ./test/bdd/aries_feature
rm -rf ./.build/aries-framework-go
