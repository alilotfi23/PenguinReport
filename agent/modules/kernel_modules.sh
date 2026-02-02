#!/bin/bash

kernel_modules_info() {
    echo "  \"kernel_modules\": [" >> "$OUTPUT_FILE"
    if [ -f /proc/modules ]; then
        awk '{print $1}' /proc/modules | while read -r module; do
            echo "    \"$(escape_json "$module")\"," >> "$OUTPUT_FILE"
        done
        # Remove trailing comma from last module entry
        sed -i '$ s/,$//' "$OUTPUT_FILE" 2>/dev/null
    fi
    echo "  ]," >> "$OUTPUT_FILE"
}

