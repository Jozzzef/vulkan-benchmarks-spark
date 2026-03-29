#!/bin/bash

# Set the directory containing the binaries
BINARIES_DIR="./binaries"

# Check if the specified directory exists
if [ ! -d "$BINARIES_DIR" ]; then
  echo "Error: Directory '$BINARIES_DIR' does not exist."
  exit 1
fi

# Loop through all items in the binaries directory
for file in "$BINARIES_DIR"/*; do
  # Check if it's a regular file and executable
  if [ -f "$file" ] && [ -x "$file" ]; then
    echo "Running: $file"
    "$file"
  fi
done

echo "All binaries executed."
