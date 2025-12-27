#!/bin/bash

# Hansip Auto Installer
# This script installs Hansip to a specified directory

set -e

# Default installation directory
DEFAULT_INSTALL_DIR="$HOME/Apps/Hansip"
INSTALL_DIR="${1:-$DEFAULT_INSTALL_DIR}"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "======================================"
echo "    Hansip Installation Script"
echo "======================================"
echo ""

# Check if hansip-server exists
if [ ! -f "hansip-server" ]; then
    echo -e "${RED}Error: hansip-server binary not found!${NC}"
    echo "Please build the project first with: go build -o hansip-server ."
    exit 1
fi

# Check if hansip-web-server exists (may need to download from release)
if [ ! -f "hansip-web-server" ]; then
    echo -e "${YELLOW}Warning: hansip-web-server not found in current directory${NC}"
    echo "Please download it from: https://github.com/slaveofcode/hansip/releases/latest"
    echo "Or copy it from an existing installation"
    exit 1
fi

echo -e "${GREEN}Installing to: $INSTALL_DIR${NC}"
echo ""

# Create installation directory
mkdir -p "$INSTALL_DIR"

# Copy binaries
echo "📦 Copying binaries..."
cp hansip-server "$INSTALL_DIR/"
cp hansip-web-server "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR/hansip-server"
chmod +x "$INSTALL_DIR/hansip-web-server"

# Copy startup script
echo "📦 Copying startup script..."
cp start-hansip.sh "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR/start-hansip.sh"

# Create config if it doesn't exist
if [ ! -f "$INSTALL_DIR/config.yaml" ]; then
    echo "📝 Creating config file..."
    if [ -f "config.example.yaml" ]; then
        cp config.example.yaml "$INSTALL_DIR/config.yaml"
        # Update host to 0.0.0.0 for network access
        sed -i 's/host: localhost/host: 0.0.0.0/g' "$INSTALL_DIR/config.yaml"
    else
        echo -e "${YELLOW}Warning: config.example.yaml not found, please create config.yaml manually${NC}"
    fi
else
    echo "✓ Config file already exists, skipping..."
fi

# Create data directories
echo "📁 Creating data directories..."
mkdir -p "$INSTALL_DIR/hansip-files/uploaded"
mkdir -p "$INSTALL_DIR/hansip-files/bundled"

# Install desktop launchers
echo "🖥️  Installing desktop launchers..."
mkdir -p ~/.local/share/applications

# Create hansip.desktop with actual path
cat > ~/.local/share/applications/hansip.desktop << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Hansip
Comment=Start Hansip File Sharing Server
Exec=bash -c '$INSTALL_DIR/start-hansip.sh start; echo ""; echo "Press Enter to close..."; read'
Icon=folder-publicshare
Terminal=true
Categories=Network;FileTransfer;
Keywords=hansip;file;share;sharing;server;
StartupNotify=false
EOF

# Create hansip-stop.desktop with actual path
cat > ~/.local/share/applications/hansip-stop.desktop << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Hansip Stop
Comment=Stop Hansip File Sharing Server
Exec=bash -c '$INSTALL_DIR/start-hansip.sh stop; echo ""; echo "Press Enter to close..."; read'
Icon=process-stop
Terminal=true
Categories=Network;FileTransfer;
Keywords=hansip;file;share;sharing;server;stop;close;
StartupNotify=false
EOF

# Update desktop database
if command -v update-desktop-database &> /dev/null; then
    update-desktop-database ~/.local/share/applications
    echo "✓ Desktop launchers installed"
else
    echo -e "${YELLOW}Warning: update-desktop-database not found, desktop launchers may not appear immediately${NC}"
fi

echo ""
echo -e "${GREEN}======================================"
echo "   Installation Complete! ✓"
echo "======================================${NC}"
echo ""
echo "Installation directory: $INSTALL_DIR"
echo ""
echo "To start Hansip:"
echo "  1. Search for 'hansip' in your application menu"
echo "  2. Or run: $INSTALL_DIR/start-hansip.sh start"
echo ""
echo "To stop Hansip:"
echo "  1. Search for 'hansip stop' in your application menu"
echo "  2. Or run: $INSTALL_DIR/start-hansip.sh stop"
echo ""
echo "Configuration: $INSTALL_DIR/config.yaml"
echo "Logs: /tmp/hansip-server.log and /tmp/hansip-web-server.log"
echo ""
