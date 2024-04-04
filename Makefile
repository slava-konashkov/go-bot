# Variables
APP := $(shell basename $(shell git remote get-url origin))
REGISTRY := sundrop
VERSION_FILE=VERSION
VERSION=$(shell cat $(VERSION_FILE))-$(shell git rev-parse --short HEAD)
# VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
TARGETOS=linux #linux darwin windows
TARGETARCH=amd64 #amd64 arm64

f_build = CGO_ENABLED=0 GOOS=$1 GOARCH=$2 go build -v -o go-bot -ldflags "-X="github.com/burylo/kbot/cmd.appVersion=${VERSION}

format:
	gofmt -s -w ./

lint:
	golint

test:
	go test -v

get:
	go get

build: format get bump-version
	@$(eval VERSION=$(shell cat $(VERSION_FILE)))
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -o go-bot -ldflags "-X="go-bot/cmd.appVersion=v$(VERSION)

image:
	docker build . -t ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}  --build-arg TARGETARCH=${TARGETARCH}

push:
	docker push ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}

bump-version:
	@echo $(VERSION) | awk -F. '{printf("%d.%d.%d", $$1, $$2, $$3+1)}' > $(VERSION_FILE)

ver:
	@echo $(VERSION)

linux: format get
	$(call f_build,linux,amd64)

macos: format get
	$(call f_build,darwin,arm64)

windows: format get
	$(call f_build,windows,amd64)

clean:
	rm -rf go-bot
	docker rmi ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}
