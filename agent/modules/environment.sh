#!/bin/bash

environment_info() {
    echo "  \"environment_variables\": {" >> "$OUTPUT_FILE"
    env | awk -F= '{print $1}' | while read -r var; do
        value=$(eval echo "\$$var")
        echo "    \"$(escape_json "$var")\": \"$(escape_json "$value")\"," >> "$OUTPUT_FILE"
    done
    # Remove trailing comma from last variable entry
    sed -i '$ s/,$//' "$OUTPUT_FILE" 2>/dev/null
    echo "  }," >> "$OUTPUT_FILE"
}

