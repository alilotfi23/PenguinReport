#!/bin/bash

disk_info() {
    echo "  \"disks\": " >> "$OUTPUT_FILE"
    
    if command -v lsblk >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
        # Capture the JSON directly, indent it, and append it
        lsblk -J -o NAME,SIZE,TYPE,MOUNTPOINT,FSTYPE | jq '.blockdevices' >> "$OUTPUT_FILE"
    else
        # Fallback if tools are missing
        echo "[ { \"error\": \"lsblk or jq not found\" } ]" >> "$OUTPUT_FILE"
    fi
    
    # Add the trailing comma for the next JSON section
    echo "," >> "$OUTPUT_FILE"
}
