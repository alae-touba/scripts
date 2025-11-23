#!/bin/bash
if [ -z "$1" ]; then
  echo "Usage: portkill <port>"
  exit 1
fi

pid=$(lsof -t -i:"$1") || {
  echo "No process found on port $1"
  exit 1
}

echo "Killing PID $pid on port $1"
kill "$pid"