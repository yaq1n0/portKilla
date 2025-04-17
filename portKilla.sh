#!/bin/bash

# Function to validate if a value is a valid integer
is_integer() {
    [[ "$1" =~ ^[0-9]+$ ]]
}

# Function to kill processes on a given port
kill_processes_on_port() {
    local PORT=$1
    local PIDS=$(lsof -t -i:$PORT)

    if [ -z "$PIDS" ]; then
        echo "✅ No processes found on port $PORT."
    else
        echo "⚠️  Killing processes on port $PORT: $PIDS"
        kill -9 $PIDS
    fi
}

# Function to kill all localhost processes
kill_all_processes() {
    echo "⚠️  WARNING: You are about to kill all processes bound to localhost ports."
    echo "This may disrupt running applications such as:"
    echo "  - Web servers (e.g., Nginx, Apache)"
    echo "  - Databases (e.g., MySQL, PostgreSQL, Redis)"
    echo "  - Development servers (e.g., Node.js, Python Flask/Django, Java Spring Boot)"
    echo "  - Docker containers"
    echo "  - Background services"
    read -p "Are you sure you want to proceed? (yes/no): " CONFIRMATION

    if [[ "$CONFIRMATION" == "yes" ]]; then
        echo "🔴 Killing all localhost processes..."
        PIDS=$(lsof -t -i)
        if [ -z "$PIDS" ]; then
            echo "✅ No processes found on localhost ports."
        else
            echo "⚠️  Killing processes: $PIDS"
            kill -9 $PIDS
            echo "✅ All processes have been terminated."
        fi
    else
        echo "❌ Operation canceled."
    fi
}

# Main script execution
if [ "$1" == "--all" ] || [ "$1" == "-a" ]; then
    kill_all_processes
    exit 0
elif is_integer "$1" && is_integer "$2"; then
    # Handle range of ports
    START_PORT=$1
    END_PORT=$2

    if [ "$START_PORT" -gt "$END_PORT" ]; then
        echo "❌ Error: Start port cannot be greater than end port."
        exit 1
    fi

    echo "🔍 Scanning and killing processes on ports $START_PORT to $END_PORT..."
    for ((PORT=START_PORT; PORT<=END_PORT; PORT++)); do
        kill_processes_on_port $PORT
    done
    echo "✅ Done."
    exit 0
elif is_integer "$1" ]; then
    # Handle single port
    kill_processes_on_port "$1"
    exit 0
else
    echo "❌ Invalid input."
    echo "Usage:"
    echo "  $0 <port_number>        # Kill process on a single port"
    echo "  $0 <start_port> <end_port>  # Kill processes in a range of ports"
    echo "  $0 --all or -a          # Kill all processes on localhost ports (with confirmation)"
    exit 1
fi
