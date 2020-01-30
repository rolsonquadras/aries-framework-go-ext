// Copyright SecureKey Technologies Inc. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0

module github.com/trustbloc/aries-framework-go-ext/test/bdd/fixtures/fabric/peer/cmd

require (
	github.com/hyperledger/fabric v2.0.0-alpha+incompatible
	github.com/spf13/viper2015 v1.3.2
	github.com/trustbloc/fabric-peer-ext v0.0.0
	github.com/trustbloc/sidetree-fabric v0.1.1
)

replace github.com/hyperledger/fabric => github.com/trustbloc/fabric-mod v0.1.1

replace github.com/hyperledger/fabric/extensions => github.com/trustbloc/fabric-peer-ext/mod/peer v0.0.0-20200129191645-fad265c678e0

replace github.com/trustbloc/fabric-peer-ext => github.com/trustbloc/fabric-peer-ext v0.1.1

replace github.com/spf13/viper2015 => github.com/spf13/viper v0.0.0-20150908122457-1967d93db724

replace github.com/hyperledger/fabric-protos-go => github.com/trustbloc/fabric-protos-go-ext v0.1.1

go 1.13
