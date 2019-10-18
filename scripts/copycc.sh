#!/bin/bash
#
# Copyright SecureKey Technologies Inc. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

echo "Copying sidetree-fabric cc..."
pwd=$(pwd)
git clone https://github.com/trustbloc/sidetree-fabric ./.build/sidetree-fabric
cd ./.build/sidetree-fabric || exist
git checkout $SIDETREE_FABRIC_VERSION
make build-cc
mv ./.build/cc ../
cd ..
rm -rf sidetree-fabric
cd $pwd || exit
