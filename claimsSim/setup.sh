#!/bin/bash

### Setup script
# Makes sure you're on a mac and copies the apple script to the right location 
# for it to be used by Excel.


# Check if running on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    echo "This project currently only works on macOS."
    exit 1
fi


# We need this because apple scripts need to be in a specific place to be 
# callable from VBA:
# https://learn.microsoft.com/en-us/office/vba/office-mac/applescripttask


SCRIPT_NAME="runRscript.scpt"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_PATH="$SCRIPT_DIR/$SCRIPT_NAME"
BUNDLE_ID="com.microsoft.Excel"
DEST_DIR="$HOME/Library/Application Scripts/$BUNDLE_ID/"

# make dir if it doesn't exist
if [ ! -d "$DEST_DIR" ]; then
    echo "Creating directory: $DEST_DIR"
    mkdir -p "$DEST_DIR"
fi

# copy the script over
echo "Copying $SCRIPT_NAME to $DEST_DIR"
cp "$SOURCE_PATH" "$DEST_DIR"

# show status
if [ -f "$DEST_DIR/$SCRIPT_NAME" ]; then
    echo "Setup complete. The AppleScript has been placed in the correct location."
else
    echo "Error: Failed to copy $SCRIPT_NAME to $DEST_DIR"
fi
