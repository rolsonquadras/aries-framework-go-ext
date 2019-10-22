module github.com/trustbloc/aries-framework-go-ext/test/bdd

go 1.13

require (
	github.com/DATA-DOG/godog v0.7.13
	github.com/hyperledger/aries-framework-go/test/bdd v0.0.0-20191022173724-1e6b282c5649
	github.com/hyperledger/fabric-protos-go v0.0.0-20190823190507-26c33c998676
	github.com/spf13/viper v1.3.2
	github.com/trustbloc/fabric-peer-test-common v0.0.0-20191001161824-e89c26cf9121

)

replace github.com/hyperledger/aries-framework-go => github.com/hyperledger/aries-framework-go v0.0.0-20191022173724-1e6b282c5649

replace github.com/hyperledger/fabric-protos-go => github.com/trustbloc/fabric-protos-go-ext v0.0.0-20191001172134-1815f5c382ff
