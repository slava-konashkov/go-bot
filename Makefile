# Variables
VERSION_FILE=VERSION
VERSION=$(shell cat $(VERSION_FILE))

bump-version:
	@echo $(VERSION) | awk -F. '{printf("%d.%d.%d", $$1, $$2, $$3+1)}' > $(VERSION_FILE)

build: bump-version
	@$(eval VERSION=$(shell cat $(VERSION_FILE)))
	go build -ldflags "-X="go-bot/cmd.appVersion=v$(VERSION)
