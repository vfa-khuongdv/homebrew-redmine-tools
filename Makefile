# Makefile for redmine-tools

# App version (can be overridden by VERSION env var)
VERSION ?= $(shell git describe --tags --always --dirty 2>/dev/null || echo "dev")

# Binary name
BINARY_NAME = redmine-tools

# Build directory
BUILD_DIR = build

# Platforms to build for
PLATFORMS = darwin/amd64 darwin/arm64 linux/amd64 linux/arm64 windows/amd64

.PHONY: all build clean install test release help

# Default target
all: build

# Build for current platform
build:
	@echo "Building $(BINARY_NAME) v$(VERSION) for current platform..."
	@mkdir -p $(BUILD_DIR)
	@go build -ldflags "-X main.version=$(VERSION)" -o $(BUILD_DIR)/$(BINARY_NAME) ./cmd

# Build for all platforms
release:
	@echo "Building $(BINARY_NAME) v$(VERSION) for all platforms..."
	@mkdir -p $(BUILD_DIR)
	$(foreach platform,$(PLATFORMS), \
		$(eval GOOS=$(word 1,$(subst /, ,$(platform)))) \
		$(eval GOARCH=$(word 2,$(subst /, ,$(platform)))) \
		$(eval EXTENSION=$(if $(filter windows,$(GOOS)),.exe,)) \
		echo "Building for $(GOOS)/$(GOARCH)..." && \
		GOOS=$(GOOS) GOARCH=$(GOARCH) go build \
			-ldflags "-X main.version=$(VERSION)" \
			-o $(BUILD_DIR)/$(BINARY_NAME)-$(GOOS)-$(GOARCH)$(EXTENSION) ./cmd; \
	)

# Install locally
install:
	@echo "Installing $(BINARY_NAME)..."
	@go install -ldflags "-X main.version=$(VERSION)" ./cmd

# Run tests
test:
	@echo "Running tests..."
	@go test -v ./...

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	@rm -rf $(BUILD_DIR)

# Create GitHub release archives
archives: release
	@echo "Creating release archives..."
	@cd $(BUILD_DIR) && \
	for binary in redmine-tools-*; do \
		if [[ "$$binary" == *".exe" ]]; then \
			zip "$${binary%.exe}.zip" "$$binary"; \
		else \
			tar -czf "$$binary.tar.gz" "$$binary"; \
		fi; \
	done

# Help
help:
	@echo "Available targets:"
	@echo "  build     - Build for current platform"
	@echo "  release   - Build for all platforms"
	@echo "  install   - Install locally"
	@echo "  test      - Run tests"
	@echo "  clean     - Clean build artifacts"
	@echo "  archives  - Create release archives"
	@echo "  help      - Show this help"
