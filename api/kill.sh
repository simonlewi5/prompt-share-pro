#!/bin/bash

echo "Killing existing gunicorn processes..."
pkill gunicorn
echo "All existing processes killed."
