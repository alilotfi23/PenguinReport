#!/bin/bash

system_info() {
    echo "  \"system\": {" >> "$OUTPUT_FILE"
    echo "    \"hostname\": \"$(escape_json "$(hostname)")\"," >> "$OUTPUT_FILE"
    echo "    \"hostid\": \"$(escape_json "$(hostid)")\"," >> "$OUTPUT_FILE"
    echo "    \"operating_system\": \"$(escape_json "$(uname -o)")\"," >> "$OUTPUT_FILE"
    echo "    \"kernel_name\": \"$(escape_json "$(uname -s)")\"," >> "$OUTPUT_FILE"
    echo "    \"kernel_release\": \"$(escape_json "$(uname -r)")\"," >> "$OUTPUT_FILE"
    echo "    \"kernel_version\": \"$(escape_json "$(uname -v)")\"," >> "$OUTPUT_FILE"
    echo "    \"architecture\": \"$(escape_json "$(uname -m)")\"," >> "$OUTPUT_FILE"
    echo "    \"uptime\": \"$(escape_json "$(uptime -p | sed 's/up //')")\"," >> "$OUTPUT_FILE"
    echo "    \"last_boot\": \"$(escape_json "$(uptime -s)")\"" >> "$OUTPUT_FILE"
    echo "  }," >> "$OUTPUT_FILE"
}
