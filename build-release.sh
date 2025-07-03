#!/bin/bash
# Build script for fs-explore releases with Hype

set -e

# Configuration
VERSION=${1:-"v1.0.0"}
BUILD_DIR="build"
DIST_DIR="dist"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[BUILD]${NC} $1"
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

# Check if Hype is installed
check_hype() {
    if ! command -v hype &> /dev/null; then
        echo "Error: Hype framework not found. Please install Hype first."
        echo "Visit: https://github.com/twilson63/hype"
        exit 1
    fi
    print_success "Hype framework found: $(hype --version 2>/dev/null || echo 'installed')"
}

# Clean previous builds
clean() {
    print_status "Cleaning previous builds..."
    rm -rf "$BUILD_DIR" "$DIST_DIR"
    mkdir -p "$BUILD_DIR" "$DIST_DIR"
}

# Build binary for a specific platform using Hype
build_platform() {
    local platform=$1
    local os=${platform%-*}
    local arch=${platform#*-}
    
    print_status "Building for $platform using Hype..."
    
    local binary_name="fs-explore"
    if [[ "$os" == "windows" ]]; then
        binary_name="fs-explore.exe"
    fi
    
    local platform_dir="$BUILD_DIR/$platform"
    mkdir -p "$platform_dir"
    
    # Map our platform names to Hype target names
    local hype_target=""
    case "$platform" in
        "linux-amd64")   hype_target="linux" ;;
        "linux-arm64")   hype_target="linux" ;;
        "darwin-amd64")  hype_target="darwin" ;;
        "darwin-arm64")  hype_target="darwin" ;;
        "windows-amd64") hype_target="windows" ;;
        "windows-arm64") hype_target="windows" ;;
        *)
            print_error "Unsupported platform: $platform"
            return 1
            ;;
    esac
    
    # Use Hype to build the executable (creates in current directory)
    if hype build explorer.lua -o "$binary_name" -t "$hype_target"; then
        # Move the created binary to the platform directory
        if [[ -f "$binary_name" ]]; then
            mv "$binary_name" "$platform_dir/"
            print_success "Built binary for $platform"
        else
            print_error "Binary not created for $platform"
            return 1
        fi
    else
        print_error "Failed to build for $platform"
        return 1
    fi
    
    # Make executable on Unix-like systems
    if [[ "$os" != "windows" ]]; then
        chmod +x "$platform_dir/$binary_name"
    fi
    
    # Create archive
    local archive_name="fs-explore-$platform"
    if [[ "$os" == "windows" ]]; then
        # Create ZIP for Windows
        (cd "$platform_dir" && zip -r "../../$DIST_DIR/$archive_name.zip" .)
    else
        # Create tar.gz for Unix-like systems
        tar -czf "$DIST_DIR/$archive_name.tar.gz" -C "$platform_dir" .
    fi
    
    print_success "Created $archive_name archive"
}

# Build for all platforms
build_all() {
    print_status "Building fs-explore $VERSION for all platforms..."
    
    local platforms=(
        "linux-amd64"
        "linux-arm64"
        "darwin-amd64" 
        "darwin-arm64"
        "windows-amd64"
        "windows-arm64"
    )
    
    for platform in "${platforms[@]}"; do
        build_platform "$platform"
    done
}

# Generate checksums
generate_checksums() {
    print_status "Generating checksums..."
    (cd "$DIST_DIR" && shasum -a 256 * > checksums.txt)
    print_success "Generated checksums.txt"
}

# Create a simple README for the release
create_release_readme() {
    cat > "$DIST_DIR/README.txt" << EOF
fs-explore $VERSION

Cross-platform TUI file explorer with syntax highlighting.

Installation:
1. Download the appropriate archive for your platform
2. Extract the archive: tar -xzf fs-explore-*.tar.gz (or unzip for Windows)
3. Move the binary to a directory in your PATH
4. Ensure Hype framework is installed: https://github.com/twilson63/hype
5. Run: fs-explore

Platforms:
- linux-amd64: Linux x86_64
- linux-arm64: Linux ARM64
- darwin-amd64: macOS Intel
- darwin-arm64: macOS Apple Silicon
- windows-amd64: Windows x86_64
- windows-arm64: Windows ARM64

For more information, visit:
https://github.com/twilson63/fs-explore
https://twilson63.github.io/fs-explore

EOF
}

# Main build process
main() {
    print_status "Building fs-explore $VERSION"
    
    check_hype
    clean
    build_all
    generate_checksums
    create_release_readme
    
    print_success "Build complete! Release files available in $DIST_DIR/"
    echo ""
    print_status "Files created:"
    ls -la "$DIST_DIR/"
    echo ""
    print_status "Next steps:"
    echo "1. Test the binaries on target platforms"
    echo "2. Create a GitHub release: gh release create $VERSION"
    echo "3. Upload the files: gh release upload $VERSION dist/*"
}

# Show help
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "fs-explore build script"
    echo ""
    echo "Usage: $0 [version]"
    echo ""
    echo "Arguments:"
    echo "  version    Version tag (default: v1.0.0)"
    echo ""
    echo "Requirements:"
    echo "  - Hype framework installed"
    echo "  - zip (for Windows archives)"
    echo "  - tar (for Unix archives)"
    echo ""
    echo "This script creates release binaries for:"
    echo "  - Linux (amd64, arm64)"
    echo "  - macOS (amd64, arm64)" 
    echo "  - Windows (amd64, arm64)"
    echo ""
    echo "Output: dist/ directory with platform-specific archives"
    exit 0
fi

main "$@"