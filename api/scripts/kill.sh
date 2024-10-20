#!/bin/bash

echo "Killing existing gunicorn processes..."

# Check for existing gunicorn processes before killing
ps aux | grep gunicorn

# Kill gunicorn processes
pkill gunicorn

# Check if the processes are successfully killed
echo "Checking for remaining gunicorn processes..."
remaining_processes=$(ps aux | grep gunicorn | grep -v grep)

if [ -z "$remaining_processes" ]; then
    echo "All existing gunicorn processes killed."
else
    echo "Some gunicorn processes are still running:"
    echo "$remaining_processes"
fi
