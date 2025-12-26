# Hansip Build & Deployment Guide

This guide covers building the binaries and setting up the desktop launcher for easy startup.

## Building from Source

### Prerequisites
- Go 1.21 or higher
- Node.js and yarn (for web interface)

### Build Backend Server
```bash
go build -o hansip-server server.go
```

### Build Web Server
```bash
cd web
yarn install
yarn build
go build -o hansip-web-server
```

## Deployment Setup

### 1. Configuration

Copy and configure the config file:
```bash
cp config.example.yaml config.yaml
```

Edit `config.yaml` to set:
- `host: 0.0.0.0` for network access (or `localhost` for local-only)
- Ports (default: 7078 for API, 7079 for Web)
- Database settings
- Storage settings

### 2. Startup Script

The `start-hansip.sh` script provides easy management:

```bash
# Make executable
chmod +x start-hansip.sh

# Start both servers
./start-hansip.sh start

# Stop both servers
./start-hansip.sh stop

# Restart both servers
./start-hansip.sh restart

# Check status
./start-hansip.sh status
```

### 3. Desktop Launcher Setup

For Linux desktop environments with `.desktop` file support:

1. **Install desktop files:**
   ```bash
   # Update paths in desktop files to match your installation directory
   sed -i "s|/home/yunat/Apps/Hansip|$(pwd)|g" desktop/hansip.desktop
   sed -i "s|/home/yunat/Apps/Hansip|$(pwd)|g" desktop/hansip-stop.desktop
   
   # Copy to user applications directory
   mkdir -p ~/.local/share/applications
   cp desktop/hansip.desktop ~/.local/share/applications/
   cp desktop/hansip-stop.desktop ~/.local/share/applications/
   
   # Update desktop database
   update-desktop-database ~/.local/share/applications
   ```

2. **Usage:**
   - Search for "hansip", "file", or "share" in your application launcher
   - Click **Hansip** to start the servers
   - Click **Hansip Stop** to stop the servers

## Network Access

When configured with `host: 0.0.0.0`:
- **Local access:** `http://localhost:7079`
- **Network access:** `http://<your-ip>:7079`

The startup script will display your local IP address when starting the servers.

## Logs

Server logs are written to:
- Backend: `/tmp/hansip-server.log`
- Web: `/tmp/hansip-web-server.log`

## Directory Structure

```
hansip/
├── hansip-server          # Backend binary (build artifact)
├── hansip-web-server      # Web server binary (build artifact)
├── start-hansip.sh        # Startup management script
├── config.yaml            # Configuration file
├── hansip.db              # SQLite database (auto-created)
├── hansip-files/          # File storage directory
│   ├── uploaded/          # Temporary upload directory
│   └── bundled/           # Processed files storage
└── desktop/               # Desktop launcher files
    ├── hansip.desktop     # Start launcher
    └── hansip-stop.desktop # Stop launcher
```

## Firewall Configuration

If accessing from other devices, ensure ports are open:
```bash
# Ubuntu/Debian with ufw
sudo ufw allow 7078/tcp
sudo ufw allow 7079/tcp

# Or use firewalld
sudo firewall-cmd --permanent --add-port=7078/tcp
sudo firewall-cmd --permanent --add-port=7079/tcp
sudo firewall-cmd --reload
```
