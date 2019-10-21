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
	"strconv"
	"strings"
	"testing"
	"time"

	"github.com/DATA-DOG/godog"
	"github.com/hyperledger/aries-framework-go/test/bdd/dockerutil"
	"github.com/spf13/viper"
	"github.com/trustbloc/fabric-peer-test-common/bddtests"
)

var composition []*dockerutil.Composition
var composeFiles = []string{"./fixtures/fabric"}

func TestMain(m *testing.M) {
	projectPath, err := filepath.Abs("../..")
	if err != nil {
		panic(err.Error())
	}
	if err := os.Setenv("PROJECT_PATH", projectPath); err != nil {
		panic(err.Error())
	}
	// default is to run all tests with tag @all
	tags := "all"
	flag.Parse()
	cmdTags := flag.CommandLine.Lookup("test.run")
	if cmdTags != nil && cmdTags.Value != nil && cmdTags.Value.String() != "" {
		tags = cmdTags.Value.String()
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
				fmt.Println("docker-compose up ... waiting for peer to start ...")
				testSleep := 10
				if os.Getenv("TEST_SLEEP") != "" {
					testSleep, _ = strconv.Atoi(os.Getenv("TEST_SLEEP"))
				}
				fmt.Printf("*** testSleep=%d", testSleep)
				time.Sleep(time.Second * time.Duration(testSleep))
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
		Format:        "progress",
		Paths:         []string{"features"},
		Randomize:     time.Now().UTC().UnixNano(), // randomize scenario execution order
		Strict:        true,
		StopOnFailure: true,
	})

	if st := m.Run(); st > status {
		status = st
	}
	os.Exit(status)
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

	composeProjectName := strings.Replace(generateUUID(), "-", "", -1)
	composition, err := bddtests.NewDockerCompose(composeProjectName, "docker-compose.yml", "./fixtures")
	if err != nil {
		panic(fmt.Sprintf("Error creating a Docker-Compose client: %s", err))
	}
	fabricTestCtx.SetComposition(composition)

	// Context is shared between tests - for now
	// Note: Each test after NewcommonSteps. should add unique steps only
	bddtests.NewCommonSteps(fabricTestCtx).RegisterSteps(s)
	NewOffLedgerSteps(fabricTestCtx).RegisterSteps(s)

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
