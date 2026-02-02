#!/bin/bash

memory_info() {
    echo "  \"memory\": {" >> "$OUTPUT_FILE"
    if [ -f /proc/meminfo ]; then
        total_mem=$(grep MemTotal /proc/meminfo | awk '{print $2}')
        free_mem=$(grep MemFree /proc/meminfo | awk '{print $2}')
        available_mem=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
        buffers=$(grep Buffers /proc/meminfo | awk '{print $2}')
        cached=$(grep '^Cached' /proc/meminfo | awk '{print $2}')
        swap_total=$(grep SwapTotal /proc/meminfo | awk '{print $2}')
        swap_free=$(grep SwapFree /proc/meminfo | awk '{print $2}')

        echo "    \"total_kb\": \"$total_mem\"," >> "$OUTPUT_FILE"
        echo "    \"free_kb\": \"$free_mem\"," >> "$OUTPUT_FILE"
        echo "    \"available_kb\": \"$available_mem\"," >> "$OUTPUT_FILE"
        echo "    \"buffers_kb\": \"$buffers\"," >> "$OUTPUT_FILE"
        echo "    \"cached_kb\": \"$cached\"," >> "$OUTPUT_FILE"
        echo "    \"swap_total_kb\": \"$swap_total\"," >> "$OUTPUT_FILE"
        echo "    \"swap_free_kb\": \"$swap_free\"" >> "$OUTPUT_FILE"
    else
        echo "    \"total_kb\": \"unknown\"," >> "$OUTPUT_FILE"
        echo "    \"free_kb\": \"unknown\"," >> "$OUTPUT_FILE"
        echo "    \"available_kb\": \"unknown\"," >> "$OUTPUT_FILE"
        echo "    \"buffers_kb\": \"unknown\"," >> "$OUTPUT_FILE"
        echo "    \"cached_kb\": \"unknown\"," >> "$OUTPUT_FILE"
        echo "    \"swap_total_kb\": \"unknown\"," >> "$OUTPUT_FILE"
        echo "    \"swap_free_kb\": \"unknown\"" >> "$OUTPUT_FILE"
    fi
    echo "  }," >> "$OUTPUT_FILE"
}

