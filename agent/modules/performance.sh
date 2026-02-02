#!/bin/bash

performance_info() {
    echo "  \"performance\": {" >> "$OUTPUT_FILE"
    echo "    \"load_average\": \"$(escape_json "$(uptime | awk -F'average: ' '{print $2}')")\"," >> "$OUTPUT_FILE"

    # CPU usage (simplified method)
    if [ -f /proc/stat ]; then
        cpu_usage=$(awk '/cpu /{total=$2+$3+$4+$5+$6+$7+$8; idle=$5; printf "%.1f", 100 - (idle*100)/total}' /proc/stat)
        echo "    \"cpu_usage_percent\": \"$cpu_usage\"," >> "$OUTPUT_FILE"
    else
        echo "    \"cpu_usage_percent\": \"unknown\"," >> "$OUTPUT_FILE"
    fi

    # Memory usage (from /proc/meminfo)
    if [ -f /proc/meminfo ]; then
        mem_total=$(grep MemTotal /proc/meminfo | awk '{print $2}')
        mem_available=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
        if [ -n "$mem_total" ] && [ -n "$mem_available" ]; then
            mem_usage=$((100 - (mem_available * 100) / mem_total))
            echo "    \"memory_usage_percent\": \"$mem_usage\"," >> "$OUTPUT_FILE"
        else
            echo "    \"memory_usage_percent\": \"unknown\"," >> "$OUTPUT_FILE"
        fi
    else
        echo "    \"memory_usage_percent\": \"unknown\"," >> "$OUTPUT_FILE"
    fi

    echo "    \"process_count\": \"$(ps -e 2>/dev/null | wc -l)\"" >> "$OUTPUT_FILE"
    echo "  }," >> "$OUTPUT_FILE"
}


