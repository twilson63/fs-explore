# fs-explore PowerShell installer script

param(
    [string]$InstallDir = "$env:USERPROFILE\AppData\Local\bin",
    [switch]$Help
)

# Configuration
$Repo = "twilson63/fs-explore"
$BinaryName = "fs-explore.exe"

# Colors for output
function Write-Status {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

# Show help
if ($Help) {
    Write-Host "fs-explore installer for Windows"
    Write-Host ""
    Write-Host "Usage: .\install.ps1 [-InstallDir <path>] [-Help]"
    Write-Host ""
    Write-Host "This script will:"
    Write-Host "  - Detect your Windows architecture"
    Write-Host "  - Download the latest fs-explore binary"
    Write-Host "  - Install it to the specified directory"
    Write-Host ""
    Write-Host "Parameters:"
    Write-Host "  -InstallDir    Installation directory (default: %USERPROFILE%\AppData\Local\bin)"
    Write-Host "  -Help          Show this help message"
    Write-Host ""
    Write-Host "Requirements:"
    Write-Host "  - PowerShell 3.0+"
    Write-Host "  - Internet connection"
    exit 0
}

# Detect architecture
function Get-Architecture {
    $arch = $env:PROCESSOR_ARCHITECTURE
    switch ($arch) {
        "AMD64" { return "amd64" }
        "ARM64" { return "arm64" }
        "x86" { return "386" }
        default {
            Write-Error "Unsupported architecture: $arch"
            exit 1
        }
    }
}

# Get latest release version
function Get-LatestVersion {
    try {
        $response = Invoke-RestMethod -Uri "https://api.github.com/repos/$Repo/releases/latest"
        return $response.tag_name
    }
    catch {
        Write-Error "Failed to get latest version: $_"
        exit 1
    }
}

# Download and install binary
function Install-Binary {
    param(
        [string]$Platform,
        [string]$Version
    )
    
    $downloadUrl = "https://github.com/$Repo/releases/download/$Version/fs-explore-$Platform.zip"
    $tempDir = [System.IO.Path]::GetTempPath() + [System.Guid]::NewGuid()
    $zipFile = "$tempDir\fs-explore.zip"
    
    try {
        # Create temp directory
        New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
        
        Write-Status "Downloading fs-explore $Version for $Platform..."
        Invoke-WebRequest -Uri $downloadUrl -OutFile $zipFile
        
        Write-Status "Extracting binary..."
        Expand-Archive -Path $zipFile -DestinationPath $tempDir -Force
        
        # Create install directory if it doesn't exist
        if (!(Test-Path $InstallDir)) {
            New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
        }
        
        # Install binary
        $sourceBinary = "$tempDir\$BinaryName"
        $targetBinary = "$InstallDir\$BinaryName"
        
        if (Test-Path $sourceBinary) {
            Copy-Item -Path $sourceBinary -Destination $targetBinary -Force
            Write-Success "fs-explore installed to $targetBinary"
        }
        else {
            Write-Error "Binary not found in archive"
            exit 1
        }
        
        # Check if install directory is in PATH
        $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
        if ($currentPath -notlike "*$InstallDir*") {
            Write-Warning "Warning: $InstallDir is not in your PATH"
            Write-Status "Adding $InstallDir to your user PATH..."
            
            $newPath = if ($currentPath) { "$currentPath;$InstallDir" } else { $InstallDir }
            [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
            
            Write-Success "Added to PATH. Please restart your terminal or run:"
            Write-Host "  `$env:Path += ';$InstallDir'" -ForegroundColor Cyan
        }
    }
    catch {
        Write-Error "Installation failed: $_"
        exit 1
    }
    finally {
        # Cleanup
        if (Test-Path $tempDir) {
            Remove-Item -Path $tempDir -Recurse -Force
        }
    }
}

# Main installation
function Main {
    Write-Status "Installing fs-explore..."
    
    # Detect platform
    $arch = Get-Architecture
    $platform = "windows-$arch"
    Write-Status "Detected platform: $platform"
    
    # Get latest version
    $version = Get-LatestVersion
    Write-Status "Latest version: $version"
    
    # Install binary
    Install-Binary -Platform $platform -Version $version
    
    Write-Success "Installation complete!"
    Write-Status "Run 'fs-explore' to start the file explorer"
}

# Run main function
Main