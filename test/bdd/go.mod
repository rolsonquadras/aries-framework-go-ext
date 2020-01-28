// Copyright SecureKey Technologies Inc. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0

module github.com/trustbloc/aries-framework-go-ext/test/bdd

go 1.13

require (
	github.com/DATA-DOG/godog v0.7.13
	github.com/hyperledger/aries-framework-go/test/bdd v0.0.0-20200128190217-e98d2597eeea
	github.com/hyperledger/fabric-protos-go v0.0.0
	github.com/spf13/viper v1.3.2
	github.com/trustbloc/fabric-peer-test-common v0.0.0-20191029204148-075911ef5e01

)

replace github.com/hyperledger/aries-framework-go => github.com/hyperledger/aries-framework-go v0.1.1-0.20200128190217-e98d2597eeea

replace github.com/hyperledger/fabric-protos-go => github.com/trustbloc/fabric-protos-go-ext v0.0.0-20191001172134-1815f5c382ff
