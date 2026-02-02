#!/bin/bash

cpu_info() {
    echo '  "cpu": {' >> "$OUTPUT_FILE"

    if [ -f /proc/cpuinfo ]; then
        echo "    \"model\": \"$(escape_json "$(grep 'model name' /proc/cpuinfo | head -1 | cut -d':' -f2 | xargs)")\"," >> "$OUTPUT_FILE"
        echo "    \"cores\": \"$(grep -c '^processor' /proc/cpuinfo)\"," >> "$OUTPUT_FILE"
    fi

    if command -v lscpu >/dev/null 2>&1; then
        echo "    \"threads_per_core\": \"$(lscpu | awk -F: '/Thread/ {print $2}' | xargs)\"," >> "$OUTPUT_FILE"
        echo "    \"sockets\": \"$(lscpu | awk -F: '/Socket/ {print $2}' | xargs)\"," >> "$OUTPUT_FILE"
        echo "    \"cpu_mhz\": \"$(lscpu | awk -F: '/CPU MHz/ {print $2}' | xargs)\"" >> "$OUTPUT_FILE"
    else
        echo "    \"threads_per_core\": \"unknown\"," >> "$OUTPUT_FILE"
        echo "    \"sockets\": \"unknown\"," >> "$OUTPUT_FILE"
        echo "    \"cpu_mhz\": \"unknown\"" >> "$OUTPUT_FILE"
    fi

    echo "  }," >> "$OUTPUT_FILE"
}

