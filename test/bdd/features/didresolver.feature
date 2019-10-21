#
# Copyright SecureKey Technologies Inc. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

@all
@didresolver
Feature:
  @resolve_valid_did_doc
  Scenario: create valid did doc
    Given DCAS collection config "dcas-mychannel" is defined for collection "dcas" as policy="OR('Org1MSP.member','Org2MSP.member')", requiredPeerCount=1, maxPeerCount=2, and timeToLive=60m
    Given DCAS collection config "docs-mychannel" is defined for collection "docs" as policy="OR('Org1MSP.member','Org2MSP.member')", requiredPeerCount=1, maxPeerCount=2, and timeToLive=60m
    Given off-ledger collection config "meta_data_coll" is defined for collection "meta_data" as policy="OR('Org1MSP.member','Org2MSP.member')", requiredPeerCount=1, maxPeerCount=1, and timeToLive=60m

    Given the channel "mychannel" is created and all peers have joined

    And "system" chaincode "sidetreetxn_cc" is installed from path "github.com/trustbloc/sidetree-fabric/cmd/chaincode/txn" to all peers
    And "system" chaincode "sidetreetxn_cc" is instantiated from path "github.com/trustbloc/sidetree-fabric/cmd/chaincode/txn" on the "mychannel" channel with args "" with endorsement policy "AND('Org1MSP.member','Org2MSP.member')" with collection policy "dcas-mychannel"
    And chaincode "sidetreetxn_cc" is warmed up on all peers on the "mychannel" channel

    And "system" chaincode "document_cc" is installed from path "github.com/trustbloc/sidetree-fabric/cmd/chaincode/doc" to all peers
    And "system" chaincode "document_cc" is instantiated from path "github.com/trustbloc/sidetree-fabric/cmd/chaincode/doc" on the "mychannel" channel with args "" with endorsement policy "OR('Org1MSP.member','Org2MSP.member')" with collection policy "docs-mychannel,meta_data_coll"
    And chaincode "document_cc" is warmed up on all peers on the "mychannel" channel
