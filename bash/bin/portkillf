#!/bin/bash
if [ -z "$1" ]; then
  echo "Usage: portkillf <port>"
  exit 1
fi

pid=$(lsof -t -i:"$1") || {
  echo "No process found on port $1"
  exit 1
}

echo "Force killing PID $pid on port $1"
kill -9 "$pid"
