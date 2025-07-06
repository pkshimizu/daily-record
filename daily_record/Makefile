.PHONY: help format analyze test clean build

# Default target
help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# Code formatting
format: ## Format all Dart files
	@echo "Formatting Dart files..."
	dart format lib/ test/
	@echo "✅ Formatting complete"

# Static analysis
analyze: ## Run static analysis
	@echo "Running static analysis..."
	flutter analyze
	@echo "✅ Static analysis complete"

# Run tests
test: ## Run all tests
	@echo "Running tests..."
	flutter test
	@echo "✅ Tests complete"

# Clean build
clean: ## Clean build artifacts
	@echo "Cleaning build artifacts..."
	flutter clean
	@echo "✅ Clean complete"

# Build for macOS
build: ## Build for macOS
	@echo "Building for macOS..."
	flutter build macos
	@echo "✅ Build complete"

# Run app
run: ## Run the app on macOS
	@echo "Running app on macOS..."
	flutter run -d macos

# Code quality check (format + analyze)
quality: format analyze ## Format code and run static analysis

# Full check (format + analyze + test)
check: quality test ## Format, analyze, and test

# Install dependencies
deps: ## Install dependencies
	@echo "Installing dependencies..."
	flutter pub get
	@echo "✅ Dependencies installed"

# Update dependencies
update: ## Update dependencies
	@echo "Updating dependencies..."
	flutter pub upgrade
	@echo "✅ Dependencies updated"

# Generate code
generate: ## Generate code (if using code generation)
	@echo "Generating code..."
	flutter packages pub run build_runner build --delete-conflicting-outputs
	@echo "✅ Code generation complete"

# Lint with dart_code_metrics
lint: ## Run dart_code_metrics
	@echo "Running dart_code_metrics..."
	dart run dart_code_metrics:metrics analyze lib/
	@echo "✅ Linting complete"

# Check for outdated packages
outdated: ## Check for outdated packages
	@echo "Checking for outdated packages..."
	flutter pub outdated
	@echo "✅ Outdated check complete" 