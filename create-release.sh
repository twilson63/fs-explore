#!/bin/bash
# Create GitHub release for fs-explore

set -e

VERSION=${1:-"v1.0.0"}
DIST_DIR="dist"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[RELEASE]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if gh CLI is installed
check_gh() {
    if ! command -v gh &> /dev/null; then
        print_error "GitHub CLI (gh) not found. Please install it first."
        echo "Visit: https://cli.github.com/"
        exit 1
    fi
    print_success "GitHub CLI found: $(gh --version | head -1)"
}

# Check if user is authenticated
check_auth() {
    if ! gh auth status &> /dev/null; then
        print_error "Not authenticated with GitHub. Please run: gh auth login"
        exit 1
    fi
    print_success "GitHub authentication verified"
}

# Check if release files exist
check_files() {
    if [[ ! -d "$DIST_DIR" ]]; then
        print_error "Distribution directory '$DIST_DIR' not found."
        echo "Please run './build-release.sh $VERSION' first to build the release files."
        exit 1
    fi
    
    local file_count=$(ls -1 "$DIST_DIR"/*.tar.gz "$DIST_DIR"/*.zip 2>/dev/null | wc -l)
    if [[ $file_count -eq 0 ]]; then
        print_error "No release archives found in $DIST_DIR/"
        echo "Please run './build-release.sh $VERSION' first."
        exit 1
    fi
    
    print_success "Found $file_count release files"
}

# Create the GitHub release
create_release() {
    print_status "Creating GitHub release $VERSION..."
    
    local release_notes="## fs-explore $VERSION

Cross-platform TUI file explorer with syntax highlighting.

### ✨ Features
- 📁 Smart directory navigation with keyboard shortcuts
- 🎨 Beautiful syntax highlighting for 6+ programming languages  
- 🖥️ Cross-platform support (Linux, macOS, Windows)
- ⌨️ Vim-inspired navigation (Escape/Ctrl+L focus switching)
- 📄 Intelligent file viewing with binary detection
- 🚀 Lightning fast Lua + Hype framework

### 🚀 Installation

**Prerequisites:** Install [Hype framework](https://github.com/twilson63/hype) first.

**Quick Install:**
\`\`\`bash
# Linux/macOS
curl -fsSL https://raw.githubusercontent.com/twilson63/fs-explore/main/install.sh | bash

# Windows (PowerShell)
irm https://raw.githubusercontent.com/twilson63/fs-explore/main/install.ps1 | iex
\`\`\`

**Manual Install:**
1. Download the appropriate binary for your platform below
2. Extract: \`tar -xzf fs-explore-*.tar.gz\` (or unzip for Windows)
3. Move to PATH: \`mv fs-explore /usr/local/bin/\` (or Windows equivalent)
4. Run: \`fs-explore\`

### 📋 Supported Platforms
- **Linux:** x86_64, ARM64
- **macOS:** Intel, Apple Silicon  
- **Windows:** x86_64, ARM64

### 🎨 Syntax Highlighting
Supports Lua, JavaScript, TypeScript, C, Erlang, and Markdown files.

### 📖 Documentation
- [Full Documentation](https://twilson63.github.io/fs-explore)
- [GitHub Repository](https://github.com/twilson63/fs-explore)

### 🐛 Issues & Support
Report issues at: https://github.com/twilson63/fs-explore/issues

---
Built with ❤️ using [Hype TUI framework](https://github.com/twilson63/hype)"

    gh release create "$VERSION" \
        --title "fs-explore $VERSION" \
        --notes "$release_notes" \
        --latest
        
    print_success "Created release $VERSION"
}

# Upload release assets
upload_assets() {
    print_status "Uploading release assets..."
    
    # Upload all archives and checksums
    gh release upload "$VERSION" \
        "$DIST_DIR"/*.tar.gz \
        "$DIST_DIR"/*.zip \
        "$DIST_DIR"/checksums.txt \
        "$DIST_DIR"/README.txt
        
    print_success "Uploaded all release assets"
}

# Main process
main() {
    print_status "Creating GitHub release for fs-explore $VERSION"
    
    check_gh
    check_auth
    check_files
    
    # Check if release already exists
    if gh release view "$VERSION" &> /dev/null; then
        print_error "Release $VERSION already exists!"
        echo "Delete it first with: gh release delete $VERSION"
        exit 1
    fi
    
    create_release
    upload_assets
    
    print_success "Release $VERSION created successfully!"
    echo ""
    print_status "Release URL: https://github.com/twilson63/fs-explore/releases/tag/$VERSION"
    echo ""
    print_status "Users can now install with:"
    echo "curl -fsSL https://raw.githubusercontent.com/twilson63/fs-explore/main/install.sh | bash"
}

# Show help
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "fs-explore GitHub release creator"
    echo ""
    echo "Usage: $0 [version]"
    echo ""
    echo "Arguments:"
    echo "  version    Version tag (default: v1.0.0)"
    echo ""
    echo "Requirements:"
    echo "  - GitHub CLI (gh) installed and authenticated"
    echo "  - Release files built with ./build-release.sh"
    echo ""
    echo "This script will:"
    echo "  1. Create a GitHub release with detailed notes"
    echo "  2. Upload all platform binaries"
    echo "  3. Include checksums and documentation"
    echo ""
    echo "Example:"
    echo "  ./build-release.sh v1.0.0    # Build the binaries"
    echo "  ./create-release.sh v1.0.0   # Create GitHub release"
    exit 0
fi

main "$@"