#!/bin/bash

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  echo "Linux detected..."
  source ./bootstrap.linux.sh
elif [[ "$OSTYPE" == "darwin"* ]]; then
  echo "MacOS detected..."
  source ./bootstrap.macos.sh
else
  echo "Unsupported OS!"
  exit 1
fi
