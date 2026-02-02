#!/bin/bash

services_info() {
    echo "  \"services\": {" >> "$OUTPUT_FILE"
    if [ -x "$(command -v systemctl)" ]; then
        echo "    \"init_system\": \"systemd\"," >> "$OUTPUT_FILE"
        echo "    \"active_services\": [" >> "$OUTPUT_FILE"
        systemctl list-units --type=service --state=running --no-pager --no-legend 2>/dev/null | awk '{print $1}' | while read -r service; do
            echo "      \"$(escape_json "$service")\"," >> "$OUTPUT_FILE"
        done
        # Remove trailing comma from last service entry
        sed -i '$ s/,$//' "$OUTPUT_FILE" 2>/dev/null
        echo "    ]" >> "$OUTPUT_FILE"
    elif [ -x "$(command -v initctl)" ]; then
        echo "    \"init_system\": \"upstart\"," >> "$OUTPUT_FILE"
        echo "    \"active_services\": [" >> "$OUTPUT_FILE"
        initctl list 2>/dev/null | grep running | awk '{print $1}' | while read -r service; do
            echo "      \"$(escape_json "$service")\"," >> "$OUTPUT_FILE"
        done
        # Remove trailing comma from last service entry
        sed -i '$ s/,$//' "$OUTPUT_FILE" 2>/dev/null
        echo "    ]" >> "$OUTPUT_FILE"
    else
        echo "    \"init_system\": \"unknown\"," >> "$OUTPUT_FILE"
        echo "    \"active_services\": []" >> "$OUTPUT_FILE"
    fi
    echo "  }," >> "$OUTPUT_FILE"
}

