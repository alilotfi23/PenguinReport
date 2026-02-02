#!/bin/bash

filesystem_info() {
    echo "  \"filesystems\": [" >> "$OUTPUT_FILE"
    if command -v df >/dev/null 2>&1; then
        df -hT | awk 'NR>1 {print $1","$2","$3","$4","$5","$6","$7}' | while IFS=, read -r fs type size used avail use mounted; do
            echo "    {" >> "$OUTPUT_FILE"
            echo "      \"filesystem\": \"$(escape_json "$fs")\"," >> "$OUTPUT_FILE"
            echo "      \"type\": \"$(escape_json "$type")\"," >> "$OUTPUT_FILE"
            echo "      \"size\": \"$(escape_json "$size")\"," >> "$OUTPUT_FILE"
            echo "      \"used\": \"$(escape_json "$used")\"," >> "$OUTPUT_FILE"
            echo "      \"available\": \"$(escape_json "$avail")\"," >> "$OUTPUT_FILE"
            echo "      \"use_percentage\": \"$(escape_json "$use")\"," >> "$OUTPUT_FILE"
            echo "      \"mounted_on\": \"$(escape_json "$mounted")\"" >> "$OUTPUT_FILE"
            echo "    }," >> "$OUTPUT_FILE"
        done
    fi
    # Remove trailing comma from last filesystem entry
    sed -i '$ s/,$//' "$OUTPUT_FILE" 2>/dev/null
    echo "  ]," >> "$OUTPUT_FILE"
}

