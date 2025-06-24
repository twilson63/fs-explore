#!/bin/bash
# fs-explore installer script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REPO="twilson63/fs-explore"
BINARY_NAME="fs-explore"
INSTALL_DIR="$HOME/.local/bin"

# Print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detect operating system and architecture
detect_platform() {
    local os=$(uname -s | tr '[:upper:]' '[:lower:]')
    local arch=$(uname -m)
    
    case $os in
        linux*)
            os="linux"
            ;;
        darwin*)
            os="darwin"
            ;;
        cygwin*|mingw*|msys*)
            os="windows"
            ;;
        *)
            print_error "Unsupported operating system: $os"
            exit 1
            ;;
    esac
    
    case $arch in
        x86_64|amd64)
            arch="amd64"
            ;;
        arm64|aarch64)
            arch="arm64"
            ;;
        i386|i686)
            arch="386"
            ;;
        *)
            print_error "Unsupported architecture: $arch"
            exit 1
            ;;
    esac
    
    echo "${os}-${arch}"
}

# Get latest release version
get_latest_version() {
    curl -s "https://api.github.com/repos/$REPO/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'
}

# Download and install binary
install_binary() {
    local platform=$1
    local version=$2
    local download_url="https://github.com/$REPO/releases/download/$version/fs-explore-$platform.tar.gz"
    local temp_dir=$(mktemp -d)
    
    print_status "Downloading fs-explore $version for $platform..."
    
    if ! curl -L -o "$temp_dir/fs-explore.tar.gz" "$download_url"; then
        print_error "Failed to download fs-explore"
        rm -rf "$temp_dir"
        exit 1
    fi
    
    print_status "Extracting binary..."
    tar -xzf "$temp_dir/fs-explore.tar.gz" -C "$temp_dir"
    
    # Create install directory if it doesn't exist
    mkdir -p "$INSTALL_DIR"
    
    # Install binary
    if mv "$temp_dir/$BINARY_NAME" "$INSTALL_DIR/"; then
        chmod +x "$INSTALL_DIR/$BINARY_NAME"
        print_success "fs-explore installed to $INSTALL_DIR/$BINARY_NAME"
    else
        print_error "Failed to install binary"
        rm -rf "$temp_dir"
        exit 1
    fi
    
    # Cleanup
    rm -rf "$temp_dir"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Main installation
main() {
    print_status "Installing fs-explore..."
    
    # Check dependencies
    if ! command_exists curl; then
        print_error "curl is required but not installed"
        exit 1
    fi
    
    if ! command_exists tar; then
        print_error "tar is required but not installed"
        exit 1
    fi
    
    # Detect platform
    local platform=$(detect_platform)
    print_status "Detected platform: $platform"
    
    # Get latest version
    local version=$(get_latest_version)
    if [ -z "$version" ]; then
        print_error "Failed to get latest version"
        exit 1
    fi
    print_status "Latest version: $version"
    
    # Install binary
    install_binary "$platform" "$version"
    
    # Check if install directory is in PATH
    if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
        print_warning "Warning: $INSTALL_DIR is not in your PATH"
        print_status "Add the following line to your shell profile (.bashrc, .zshrc, etc.):"
        echo "export PATH=\"\$PATH:$INSTALL_DIR\""
    fi
    
    print_success "Installation complete!"
    print_status "Run 'fs-explore' to start the file explorer"
}

# Check for help flag
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "fs-explore installer"
    echo ""
    echo "Usage: $0"
    echo ""
    echo "This script will:"
    echo "  - Detect your platform (OS and architecture)"
    echo "  - Download the latest fs-explore binary"
    echo "  - Install it to ~/.local/bin/"
    echo ""
    echo "Requirements:"
    echo "  - curl"
    echo "  - tar"
    echo ""
    echo "Environment variables:"
    echo "  INSTALL_DIR - Override installation directory (default: ~/.local/bin)"
    exit 0
fi

main "$@"