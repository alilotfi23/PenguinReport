#!/bin/

disk_info() {
    echo "  \"disks\": [" >> "$OUTPUT_FILE"
    if command -v lsblk >/dev/null 2>&1; then
        lsblk -J | jq -c '.blockdevices[]' 2>/dev/null | while read -r disk; do
            echo "    $disk," >> "$OUTPUT_FILE"
        done
    fi
    # Remove trailing comma from last disk entry
    sed -i '$ s/,$//' "$OUTPUT_FILE" 2>/dev/null
    echo "  ]," >> "$OUTPUT_FILE"
}

