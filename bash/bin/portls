#!/bin/bash
if [ -z "$1" ]; then
  echo "Usage: portls <port>"
  exit 1
fi
sudo ss -tulpn | grep ":$1" || echo "Nothing listening on port $1"