#!/bin/bash

# Replace 'config.json' with the path to your JSON file
JSON_FILE="projectConfig.json"

if [ ! -f "$JSON_FILE" ]; then
    echo "File not found: $JSON_FILE"
    exit 1
fi

# Iterate over keys and set environment variables
jq -r 'to_entries | .[] | .key + "=" + .value' $JSON_FILE | while read -r line; do
    key=$(echo "$line" | cut -d '=' -f 1)
    value=$(echo "$line" | cut -d '=' -f 2-)

    # Check if the value is base64 encoded
    if [[ "$value" =~ ^[A-Za-z0-9+/=]+$ ]]; then
        # Replace \n with actual newlines
        value=$(echo -e "$value")
    fi

    export "$key=$value"
done