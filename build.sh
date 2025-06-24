#!/bin/bash
# Build script for fs-explore releases

set -e

# Configuration
VERSION=${1:-"v1.0.0"}
BUILD_DIR="build"
DIST_DIR="dist"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[BUILD]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Clean previous builds
clean() {
    print_status "Cleaning previous builds..."
    rm -rf "$BUILD_DIR" "$DIST_DIR"
    mkdir -p "$BUILD_DIR" "$DIST_DIR"
}

# Create standalone binary for a platform
create_binary() {
    local platform=$1
    local os=${platform%-*}
    local arch=${platform#*-}
    
    print_status "Creating binary for $platform..."
    
    local binary_name="fs-explore"
    if [[ "$os" == "windows" ]]; then
        binary_name="fs-explore.exe"
    fi
    
    local platform_dir="$BUILD_DIR/$platform"
    mkdir -p "$platform_dir"
    
    # Create the main executable script
    cat > "$platform_dir/$binary_name" << 'EOF'
#!/usr/bin/env lua

-- fs-explore: Embedded Lua application
-- This is a self-contained executable that includes all necessary modules

local app_code = {}

-- Embedded fs.lua module
app_code.fs = [[
-- Cross-platform filesystem module for Hype
local fs = {}

-- Detect operating system
local function getOS()
    local sep = package.config:sub(1,1)
    if sep == '\\' then
        return 'windows'
    else
        return 'unix'
    end
end

local OS = getOS()

-- Execute command and capture output
local function execute(cmd)
    local handle = io.popen(cmd)
    if not handle then
        return nil, "Failed to execute command"
    end
    local result = handle:read("*a")
    local success = handle:close()
    return result, success
end

-- Read directory contents
function fs.readdir(path, callback)
    if not path or path == "" then
        path = "."
    end
    
    local cmd
    if OS == 'windows' then
        cmd = 'dir "' .. path .. '" /B 2>NUL'
    else
        cmd = 'ls -1 "' .. path .. '" 2>/dev/null'
    end
    
    local result, success = execute(cmd)
    
    if not success or not result then
        callback("Directory not found or access denied", nil)
        return
    end
    
    local files = {}
    for file in result:gmatch("[^\r\n]+") do
        if file and file ~= "" then
            table.insert(files, file)
        end
    end
    
    callback(nil, files)
end

-- Get file/directory stats
function fs.stat(path, callback)
    if not path or path == "" then
        callback("Invalid path", nil)
        return
    end
    
    local cmd
    if OS == 'windows' then
        cmd = 'dir "' .. path .. '" 2>NUL | findstr /C:"<DIR>"'
    else
        cmd = 'test -d "' .. path .. '" && echo "directory" || echo "file"'
    end
    
    local result, success = execute(cmd)
    
    if not success then
        callback("Path not found", nil)
        return
    end
    
    local isDirectory = false
    if OS == 'windows' then
        isDirectory = result and result:find("<DIR>") ~= nil
    else
        isDirectory = result and result:find("directory") ~= nil
    end
    
    local stats = {
        isDirectory = isDirectory
    }
    
    callback(nil, stats)
end

-- Read file contents
function fs.readFile(path, callback)
    if not path or path == "" then
        callback("Invalid file path", nil)
        return
    end
    
    local file = io.open(path, "rb")
    if not file then
        callback("Cannot open file", nil)
        return
    end
    
    local content = file:read("*a")
    file:close()
    
    if not content then
        callback("Cannot read file", nil)
        return
    end
    
    -- Check if file is binary by looking for null bytes
    local isBinary = content:find("\0") ~= nil
    
    callback(nil, {
        content = content,
        isBinary = isBinary
    })
end

-- Get home directory
function fs.getHomeDir()
    local home = os.getenv("HOME") or os.getenv("USERPROFILE")
    return home or "."
end

return fs
]]

-- Load embedded module
local function load_module(name)
    if app_code[name] then
        local chunk = load(app_code[name], name)
        return chunk()
    end
    error("Module not found: " .. name)
end

-- Override require for embedded modules
local original_require = require
require = function(name)
    if app_code[name] then
        return load_module(name)
    end
    return original_require(name)
end

-- Main application code would be embedded here
-- This is a placeholder - the actual build would embed the full explorer.lua
print("fs-explore standalone binary")
print("This would contain the full embedded application")
print("Platform: $platform")
EOF

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
    local platforms=(
        "linux-amd64"
        "linux-arm64"
        "darwin-amd64" 
        "darwin-arm64"
        "windows-amd64"
        "windows-arm64"
    )
    
    for platform in "${platforms[@]}"; do
        create_binary "$platform"
    done
}

# Generate checksums
generate_checksums() {
    print_status "Generating checksums..."
    (cd "$DIST_DIR" && sha256sum * > checksums.txt)
    print_success "Generated checksums.txt"
}

# Main build process
main() {
    print_status "Building fs-explore $VERSION"
    
    clean
    build_all
    generate_checksums
    
    print_success "Build complete! Archives available in $DIST_DIR/"
    ls -la "$DIST_DIR/"
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
    echo "This script creates release binaries for:"
    echo "  - Linux (amd64, arm64)"
    echo "  - macOS (amd64, arm64)" 
    echo "  - Windows (amd64, arm64)"
    echo ""
    echo "Output: dist/ directory with platform-specific archives"
    exit 0
fi

main "$@"