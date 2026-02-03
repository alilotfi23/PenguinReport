#!/bin/bash

cpu_info() {
    echo '  "cpu": {' >> "$OUTPUT_FILE"

    if [ -f /proc/cpuinfo ]; then
        model_name=$(grep 'model name' /proc/cpuinfo | head -1 | cut -d':' -f2 | xargs)
        echo "    \"model\": \"$(escape_json "$model_name")\"," >> "$OUTPUT_FILE"
        echo "    \"cores\": \"$(grep -c '^processor' /proc/cpuinfo)\"," >> "$OUTPUT_FILE"
    fi

    if command -v lscpu >/dev/null 2>&1; then
        # 1. Try to get real MHz
        # 2. If empty, try to extract from Model Name (e.g., 2.90GHz -> 2900)
        # 3. If still empty, use BogoMIPS
        cpu_mhz=$(lscpu | awk -F: '/CPU MHz/ {print $2}' | xargs)
        
        if [ -z "$cpu_mhz" ]; then
            cpu_mhz=$(echo "$model_name" | grep -oP '\d+(\.\d+)?(?=GHz)' | awk '{print $1 * 1000}')
        fi
        
        if [ -z "$cpu_mhz" ]; then
            cpu_mhz=$(lscpu | awk -F: '/BogoMIPS/ {print $2}' | xargs)
        fi

        echo "    \"threads_per_core\": \"$(lscpu | awk -F: '/Thread\(s\) per core/ {print $2}' | xargs)\"," >> "$OUTPUT_FILE"
        echo "    \"sockets\": \"$(lscpu | awk -F: '/Socket\(s\)/ {print $2}' | xargs)\"," >> "$OUTPUT_FILE"
        echo "    \"cpu_mhz\": \"${cpu_mhz:-unknown}\"" >> "$OUTPUT_FILE"
    else
        echo "    \"threads_per_core\": \"unknown\"," >> "$OUTPUT_FILE"
        echo "    \"sockets\": \"unknown\"," >> "$OUTPUT_FILE"
        echo "    \"cpu_mhz\": \"unknown\"" >> "$OUTPUT_FILE"
    fi

    echo "  }," >> "$OUTPUT_FILE"
}
