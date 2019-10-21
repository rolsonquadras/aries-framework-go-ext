#
# Copyright SecureKey Technologies Inc. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

ARG GO_VER=1.12.5
ARG ALPINE_VER=3.9
ARG FABRIC_PEER_EXT_IMAGE
ARG FABRIC_PEER_EXT_TAG

FROM golang:${GO_VER}-alpine${ALPINE_VER} as golang
RUN apk add --no-cache \
	gcc \
	musl-dev \
	git \
	libtool \
	bash \
	make;
ADD . $GOPATH/src/trustbloc/aries-framework-go-ext
WORKDIR $GOPATH/src/trustbloc/aries-framework-go-ext
ARG GO_TAGS
ARG GOPROXY
RUN make GO111MODULE=on GO_TAGS=${GO_TAGS} GOPROXY=${GOPROXY} bdd-test-fabric-peer



FROM ${FABRIC_PEER_EXT_IMAGE}:${FABRIC_PEER_EXT_TAG}
COPY --from=golang /go/src/trustbloc/aries-framework-go-ext/.build/bin /usr/local/bin
CMD ["fabric-peer"]
