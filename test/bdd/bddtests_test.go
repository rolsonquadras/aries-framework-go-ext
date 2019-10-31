/*
Copyright SecureKey Technologies Inc. All Rights Reserved.
SPDX-License-Identifier: Apache-2.0
*/

package bdd

import (
	"flag"
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"testing"
	"time"

	"github.com/DATA-DOG/godog"
	ariesbdd "github.com/hyperledger/aries-framework-go/test/bdd"
	"github.com/hyperledger/aries-framework-go/test/bdd/dockerutil"
	"github.com/spf13/viper"
	"github.com/trustbloc/fabric-peer-test-common/bddtests"
)

var composition []*dockerutil.Composition
var composeFiles = []string{"./fixtures/fabric", "./fixtures/sidetree-fabric"}

func TestMain(m *testing.M) {
	projectPath, err := filepath.Abs("../..")
	if err != nil {
		panic(err.Error())
	}
	if err := os.Setenv("PROJECT_PATH", projectPath); err != nil {
		panic(err.Error())
	}
	tags := "setup_fabric,didresolve,didexchange_public_did"
	flag.Parse()

	format := "progress"
 	if getCmdArg("test.v") == "true" {
 		format = "pretty"
	}

	runArg := getCmdArg("test.run")
	if runArg != "" {
		tags = runArg
	}

	initBDDConfig()
	status := godog.RunWithOptions("godogs", func(s *godog.Suite) {
		s.BeforeSuite(func() {
			if os.Getenv("DISABLE_COMPOSITION") != "true" {
				// Need a unique name, but docker does not allow '-' in names
				composeProjectName := strings.Replace(generateUUID(), "-", "", -1)

				for _, v := range composeFiles {
					newComposition, err := dockerutil.NewComposition(composeProjectName, "docker-compose.yml", v)
					if err != nil {
						panic(fmt.Sprintf("Error composing system in BDD context: %s", err))
					}
					composition = append(composition, newComposition)
				}
			}

		})
		s.AfterSuite(func() {
			for _, c := range composition {
				if c != nil {
					if err := c.GenerateLogs(c.Dir, c.ProjectName+".log"); err != nil {
						panic(err)
					}
					if _, err := c.Decompose(c.Dir); err != nil {
						panic(err)
					}
				}
			}
		})
		FeatureContext(s)
	}, godog.Options{
		Tags:          tags,
		Format:        format,
		Paths:         []string{"features", "aries_feature"},
		Randomize:     time.Now().UTC().UnixNano(), // randomize scenario execution order
		Strict:        true,
		StopOnFailure: true,
	})

	if st := m.Run(); st > status {
		status = st
	}
	os.Exit(status)
}

func getCmdArg(argName string) string {
	cmdTags := flag.CommandLine.Lookup(argName)
	if cmdTags != nil && cmdTags.Value != nil && cmdTags.Value.String() != "" {
		return cmdTags.Value.String()
	}
	return ""
}

func FeatureContext(s *godog.Suite) {
	peersMspID := make(map[string]string)
	peersMspID["peer0.org1.example.com"] = "Org1MSP"
	peersMspID["peer1.org1.example.com"] = "Org1MSP"
	peersMspID["peer0.org2.example.com"] = "Org2MSP"
	peersMspID["peer1.org2.example.com"] = "Org2MSP"

	fabricTestCtx, err := bddtests.NewBDDContext([]string{"peerorg1", "peerorg2"}, "orderer.example.com", "./fixtures/fabric/config/sdk-client/",
		"config.yaml", peersMspID, "../../.build/cc", "./fixtures/testdata")
	if err != nil {
		panic(fmt.Sprintf("Error returned from NewBDDContext: %s", err))
	}
	// Context is shared between tests
	bddtests.NewCommonSteps(fabricTestCtx).RegisterSteps(s)
	NewOffLedgerSteps(fabricTestCtx).RegisterSteps(s)

	ariesTestCtx, err := ariesbdd.NewContext()
	if err != nil {
		panic(fmt.Sprintf("Error returned from NewContext: %s", err))
	}
	// set  args
	ariesTestCtx.Args[ariesbdd.SideTreeURL] = "http://localhost:48326/document"
	ariesTestCtx.Args[ariesbdd.DIDDocPath] = "fixtures/sidetree-fabric/config/client/didDocument.json"

	// Context is shared between tests
	ariesbdd.NewAgentSDKSteps(ariesTestCtx).RegisterSteps(s)
	ariesbdd.NewDIDExchangeSteps(ariesTestCtx).RegisterSteps(s)
	ariesbdd.NewDIDResolverSteps(ariesTestCtx).RegisterSteps(s)

}

func initBDDConfig() {
	replacer := strings.NewReplacer(".", "_")

	viper.AddConfigPath("./fixtures/fabric/config/sdk-client/")
	viper.SetConfigName("config")
	viper.SetEnvPrefix("core")
	viper.AutomaticEnv()
	viper.SetEnvKeyReplacer(replacer)

	err := viper.ReadInConfig()
	if err != nil {
		fmt.Printf("Fatal error reading config file: %s \n", err)
		os.Exit(1)
	}
}

// generateUUID returns a UUID based on RFC 4122
func generateUUID() string {
	id := dockerutil.GenerateBytesUUID()
	return fmt.Sprintf("%x-%x-%x-%x-%x", id[0:4], id[4:6], id[6:8], id[8:10], id[10:])
}
