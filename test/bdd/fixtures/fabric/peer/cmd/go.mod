module github.com/trustbloc/aries-framework-go-ext/test/bdd/fixtures/fabric/peer/cmd

require (
	github.com/hyperledger/fabric v2.0.0-alpha+incompatible
	github.com/spf13/viper v1.3.2
	github.com/trustbloc/sidetree-fabric v0.0.0-20191018181606-784de6e9f4bd
)

replace github.com/hyperledger/fabric => github.com/trustbloc/fabric-mod v0.0.0-20190821180934-5941d21b98c6

replace github.com/hyperledger/fabric/extensions => github.com/trustbloc/fabric-peer-ext/mod/peer v0.0.0-20191010163548-1ab7e444ef7c

replace github.com/trustbloc/fabric-peer-ext => github.com/trustbloc/fabric-peer-ext v0.0.0-20191010163548-1ab7e444ef7c

replace github.com/spf13/viper => github.com/spf13/viper v0.0.0-20150908122457-1967d93db724

go 1.13
