#!/bin/sh
# C3.ai CLI installer script
# Usage: curl -fsSL https://raw.githubusercontent.com/C3-CaseySiebel/c3cli-releases/master/install.sh | sh

set -e

REPO="C3-CaseySiebel/c3cli-releases"
INSTALL_DIR="${INSTALL_DIR:-/usr/local/bin}"
BINARY_NAME="c3"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

info() {
    printf "${GREEN}[info]${NC} %s\n" "$1"
}

warn() {
    printf "${YELLOW}[warn]${NC} %s\n" "$1"
}

error() {
    printf "${RED}[error]${NC} %s\n" "$1"
    exit 1
}

# Detect OS and architecture
detect_platform() {
    OS="$(uname -s)"
    ARCH="$(uname -m)"

    case "$OS" in
        Darwin)
            OS="darwin"
            ;;
        Linux)
            OS="linux"
            ;;
        *)
            error "Unsupported operating system: $OS"
            ;;
    esac

    case "$ARCH" in
        x86_64|amd64)
            ARCH="x86_64"
            ;;
        arm64|aarch64)
            ARCH="aarch64"
            ;;
        *)
            error "Unsupported architecture: $ARCH"
            ;;
    esac

    PLATFORM="${OS}-${ARCH}"
    info "Detected platform: $PLATFORM"
}

# Get latest release version from GitHub
get_latest_version() {
    LATEST_URL="https://raw.githubusercontent.com/${REPO}/master/releases/latest"

    if command -v curl >/dev/null 2>&1; then
        VERSION=$(curl -fsSL "$LATEST_URL" 2>/dev/null | tr -d '[:space:]')
    elif command -v wget >/dev/null 2>&1; then
        VERSION=$(wget -qO- "$LATEST_URL" 2>/dev/null | tr -d '[:space:]')
    else
        error "Neither curl nor wget found. Please install one of them."
    fi

    if [ -z "$VERSION" ]; then
        error "Failed to get latest version. Check your internet connection or try again later."
    fi

    info "Latest version: $VERSION"
}

# Download and install
download_and_install() {
    TARBALL="c3cli-${PLATFORM}.tar.gz"
    DOWNLOAD_URL="https://raw.githubusercontent.com/${REPO}/master/releases/${VERSION}/${TARBALL}"

    info "Downloading from: $DOWNLOAD_URL"

    # Create temp directory
    TMP_DIR=$(mktemp -d)
    trap 'rm -rf "$TMP_DIR"' EXIT

    # Download
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$DOWNLOAD_URL" -o "$TMP_DIR/$TARBALL" || error "Download failed. The release may not exist for your platform."
    else
        wget -q "$DOWNLOAD_URL" -O "$TMP_DIR/$TARBALL" || error "Download failed. The release may not exist for your platform."
    fi

    # Extract
    info "Extracting..."
    tar -xzf "$TMP_DIR/$TARBALL" -C "$TMP_DIR"

    # Install
    info "Installing to $INSTALL_DIR..."
    if [ -w "$INSTALL_DIR" ]; then
        mv "$TMP_DIR/$BINARY_NAME" "$INSTALL_DIR/"
        chmod +x "$INSTALL_DIR/$BINARY_NAME"
    else
        warn "Permission denied. Trying with sudo..."
        sudo mv "$TMP_DIR/$BINARY_NAME" "$INSTALL_DIR/"
        sudo chmod +x "$INSTALL_DIR/$BINARY_NAME"
    fi
}

# Verify installation
verify_install() {
    if command -v "$BINARY_NAME" >/dev/null 2>&1; then
        info "Successfully installed $BINARY_NAME to $INSTALL_DIR"
        info "Version: $($BINARY_NAME --version 2>/dev/null || echo 'unknown')"
        echo ""
        info "Run '$BINARY_NAME --help' to get started"
    else
        warn "Installation complete, but $BINARY_NAME not found in PATH"
        warn "You may need to add $INSTALL_DIR to your PATH"
        echo ""
        echo "Add this to your shell config (~/.bashrc, ~/.zshrc, etc.):"
        echo "  export PATH=\"$INSTALL_DIR:\$PATH\""
    fi
}

main() {
    echo ""
    echo "  C3.ai CLI Installer"
    echo "  ================="
    echo ""

    detect_platform
    get_latest_version
    download_and_install
    verify_install

    echo ""
}

main "$@"
