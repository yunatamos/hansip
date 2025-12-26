#!/bin/bash

# Hansip Startup Script
HANSIP_DIR="/home/yunat/Apps/Hansip"
PID_FILE_SERVER="$HANSIP_DIR/.hansip-server.pid"
PID_FILE_WEB="$HANSIP_DIR/.hansip-web-server.pid"

cd "$HANSIP_DIR" || exit 1

start_servers() {
    echo "Starting Hansip servers..."
    
    # Start hansip-server
    if [ -f "$PID_FILE_SERVER" ] && kill -0 $(cat "$PID_FILE_SERVER") 2>/dev/null; then
        echo "Hansip server is already running (PID: $(cat $PID_FILE_SERVER))"
    else
        ./hansip-server > /tmp/hansip-server.log 2>&1 &
        echo $! > "$PID_FILE_SERVER"
        echo "Hansip server started (PID: $(cat $PID_FILE_SERVER))"
    fi
    
    # Start hansip-web-server
    if [ -f "$PID_FILE_WEB" ] && kill -0 $(cat "$PID_FILE_WEB") 2>/dev/null; then
        echo "Hansip web server is already running (PID: $(cat $PID_FILE_WEB))"
    else
        ./hansip-web-server > /tmp/hansip-web-server.log 2>&1 &
        echo $! > "$PID_FILE_WEB"
        echo "Hansip web server started (PID: $(cat $PID_FILE_WEB))"
    fi
    
    echo ""
    echo "Hansip is now running!"
    echo ""
    echo "Local access:"
    echo "  API Server: http://localhost:7078"
    echo "  Web Server: http://localhost:7079"
    echo ""
    echo "Network access:"
    LOCAL_IP=$(hostname -I | awk '{print $1}')
    if [ -n "$LOCAL_IP" ]; then
        echo "  API Server: http://$LOCAL_IP:7078"
        echo "  Web Server: http://$LOCAL_IP:7079"
    else
        echo "  Could not detect local IP address"
    fi
    echo ""
    echo "Logs:"
    echo "  Server: /tmp/hansip-server.log"
    echo "  Web: /tmp/hansip-web-server.log"
}

stop_servers() {
    echo "Stopping Hansip servers..."
    
    # Stop hansip-server
    if [ -f "$PID_FILE_SERVER" ]; then
        PID=$(cat "$PID_FILE_SERVER")
        if kill -0 $PID 2>/dev/null; then
            kill $PID
            echo "Stopped hansip-server (PID: $PID)"
        fi
        rm -f "$PID_FILE_SERVER"
    fi
    
    # Stop hansip-web-server
    if [ -f "$PID_FILE_WEB" ]; then
        PID=$(cat "$PID_FILE_WEB")
        if kill -0 $PID 2>/dev/null; then
            kill $PID
            echo "Stopped hansip-web-server (PID: $PID)"
        fi
        rm -f "$PID_FILE_WEB"
    fi
    
    echo "Hansip servers stopped."
}

status_servers() {
    echo "Hansip Status:"
    
    if [ -f "$PID_FILE_SERVER" ] && kill -0 $(cat "$PID_FILE_SERVER") 2>/dev/null; then
        echo "  Server: Running (PID: $(cat $PID_FILE_SERVER))"
    else
        echo "  Server: Stopped"
    fi
    
    if [ -f "$PID_FILE_WEB" ] && kill -0 $(cat "$PID_FILE_WEB") 2>/dev/null; then
        echo "  Web: Running (PID: $(cat $PID_FILE_WEB))"
    else
        echo "  Web: Stopped"
    fi
}

case "$1" in
    start)
        start_servers
        ;;
    stop)
        stop_servers
        ;;
    restart)
        stop_servers
        sleep 2
        start_servers
        ;;
    status)
        status_servers
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status}"
        exit 1
        ;;
esac
