#!/bin/bash

users_info() {
    echo "  \"users\": [" >> "$OUTPUT_FILE"
    getent passwd | awk -F: '{print $1","$3","$6","$7}' | while IFS=, read -r user id home shell; do
        echo "    {" >> "$OUTPUT_FILE"
        echo "      \"username\": \"$(escape_json "$user")\"," >> "$OUTPUT_FILE"
        echo "      \"uid\": \"$id\"," >> "$OUTPUT_FILE"
        echo "      \"home_directory\": \"$(escape_json "$home")\"," >> "$OUTPUT_FILE"
        echo "      \"shell\": \"$(escape_json "$shell")\"" >> "$OUTPUT_FILE"
        echo "    }," >> "$OUTPUT_FILE"
    done
    # Remove trailing comma from last user entry
    sed -i '$ s/,$//' "$OUTPUT_FILE" 2>/dev/null
    echo "  ]," >> "$OUTPUT_FILE"
}

