# Copyright 2019 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

PKG=github.com/kubernetes-sigs/aws-efs-csi-driver
IMAGE?=amazon/aws-efs-csi-driver
VERSION=v0.4.0-dirty
GIT_COMMIT?=$(shell git rev-parse HEAD)
BUILD_DATE?=$(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
EFS_CLIENT_SOURCE?=k8s
LDFLAGS?="-X ${PKG}/pkg/driver.driverVersion=${VERSION} \
		  -X ${PKG}/pkg/driver.gitCommit=${GIT_COMMIT} \
		  -X ${PKG}/pkg/driver.buildDate=${BUILD_DATE} \
		  -X ${PKG}/pkg/driver.efsClientSource=${EFS_CLIENT_SOURCE}"
GO111MODULE=on
GOPROXY=direct
GOPATH=$(shell go env GOPATH)

.EXPORT_ALL_VARIABLES:

.PHONY: aws-efs-csi-driver
aws-efs-csi-driver:
	mkdir -p bin
	CGO_ENABLED=0 GOOS=linux go build -ldflags ${LDFLAGS} -o bin/aws-efs-csi-driver ./cmd/

build-darwin:
	mkdir -p bin/darwin/
	CGO_ENABLED=0 GOOS=darwin go build -ldflags ${LDFLAGS} -o bin/darwin/aws-efs-csi-driver ./cmd/

run-darwin: build-darwin
	bin/darwin/aws-efs-csi-driver --version

.PHONY: verify
verify:
	./hack/verify-all

.PHONY: test
test:
	go test -v -race $$(go list ./pkg/... | grep -v /driver)
	# TODO stop skipping controller tests when controller is implemented
	go test -v -race ./pkg/driver/... -ginkgo.skip='\[Controller.Server\]'

.PHONY: test-e2e
test-e2e:
	go get github.com/aws/aws-k8s-tester/e2e/tester/cmd/k8s-e2e-tester@master
	TESTCONFIG=./tester/e2e-test-config.yaml ${GOPATH}/bin/k8s-e2e-tester

.PHONY: image
image:
	docker build -t $(IMAGE):latest .

.PHONY: push
push: image
	docker push $(IMAGE):latest

.PHONY: image-release
image-release:
	docker build -t $(IMAGE):$(VERSION) .

.PHONY: push-release
push-release:
	docker push $(IMAGE):$(VERSION)
