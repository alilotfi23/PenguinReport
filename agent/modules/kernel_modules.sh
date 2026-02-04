#!/bin/bash

kernel_modules_info() {
    echo "  \"kernel_modules\": [" >> "$OUTPUT_FILE"

    if [ -f /proc/modules ]; then
        awk '{
            printf "    {\"name\": \"%s\", \"size\": %d, \"used_by\": %d},\n", $1, $2, $3
        }' /proc/modules | sed '$ s/,$//' >> "$OUTPUT_FILE"
    fi

    echo "  ]," >> "$OUTPUT_FILE"
}
