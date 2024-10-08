#!/bin/bash

# Check if the port number is passed as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 <port_number>"
  exit 1
fi

# Assign the first argument to PORT variable
PORT=$1

# Find the process ID (PID) of the process that is using the provided port
PIDS=$(lsof -t -i:$PORT)

# Check if any process is found
if [ -z "$PIDS" ]; then
  echo "No processes found on port $PORT."
else
  # Kill the processes bound to the provided port
  echo "Killing processes on port $PORT: $PIDS"
  kill -9 $PIDS
fi
