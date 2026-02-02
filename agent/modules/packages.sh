#!/bin/bash

packages_info() {
    echo "  \"packages\": {" >> "$OUTPUT_FILE"
    if [ -x "$(command -v dpkg)" ]; then
        echo "    \"package_manager\": \"dpkg\"," >> "$OUTPUT_FILE"
        echo "    \"list\": [" >> "$OUTPUT_FILE"
        dpkg -l | awk 'NR>5 {print $2" "$3}' | while read -r pkg version; do
            echo "      {\"name\": \"$(escape_json "$pkg")\", \"version\": \"$(escape_json "$version")\"}," >> "$OUTPUT_FILE"
        done
    elif [ -x "$(command -v rpm)" ]; then
        echo "    \"package_manager\": \"rpm\"," >> "$OUTPUT_FILE"
        echo "    \"list\": [" >> "$OUTPUT_FILE"
        rpm -qa --queryformat '%{NAME} %{VERSION}\n' | while read -r pkg version; do
            echo "      {\"name\": \"$(escape_json "$pkg")\", \"version\": \"$(escape_json "$version")\"}," >> "$OUTPUT_FILE"
        done
    else
        echo "    \"package_manager\": \"unknown\"," >> "$OUTPUT_FILE"
        echo "    \"list\": []" >> "$OUTPUT_FILE"
    fi
    # Remove trailing comma from last package entry if needed
    if [ -x "$(command -v dpkg)" ] || [ -x "$(command -v rpm)" ]; then
        sed -i '$ s/,$//' "$OUTPUT_FILE" 2>/dev/null
        echo "    ]" >> "$OUTPUT_FILE"
    fi
    echo "  }," >> "$OUTPUT_FILE"
}

