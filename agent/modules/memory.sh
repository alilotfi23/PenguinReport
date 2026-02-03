#!/bin/bash

memory_info() {
    echo "  \"memory\": {" >> "$OUTPUT_FILE"
    if [ -f /proc/meminfo ]; then
        # Function to convert KB to GB using awk
        convert_to_gb() {
            echo "$1" | awk '{printf "%.2f", $1 / 1024 / 1024}'
        }

        total_kb=$(grep MemTotal /proc/meminfo | awk '{print $2}')
        free_kb=$(grep MemFree /proc/meminfo | awk '{print $2}')
        available_kb=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
        buffers_kb=$(grep Buffers /proc/meminfo | awk '{print $2}')
        cached_kb=$(grep '^Cached' /proc/meminfo | awk '{print $2}')
        swap_total_kb=$(grep SwapTotal /proc/meminfo | awk '{print $2}')
        swap_free_kb=$(grep SwapFree /proc/meminfo | awk '{print $2}')

        echo "    \"total_gb\": \"$(convert_to_gb $total_kb)\"," >> "$OUTPUT_FILE"
        echo "    \"free_gb\": \"$(convert_to_gb $free_kb)\"," >> "$OUTPUT_FILE"
        echo "    \"available_gb\": \"$(convert_to_gb $available_kb)\"," >> "$OUTPUT_FILE"
        echo "    \"buffers_gb\": \"$(convert_to_gb $buffers_kb)\"," >> "$OUTPUT_FILE"
        echo "    \"cached_gb\": \"$(convert_to_gb $cached_kb)\"," >> "$OUTPUT_FILE"
        echo "    \"swap_total_gb\": \"$(convert_to_gb $swap_total_kb)\"," >> "$OUTPUT_FILE"
        echo "    \"swap_free_gb\": \"$(convert_to_gb $swap_free_kb)\"" >> "$OUTPUT_FILE"
    else
        echo "    \"total_gb\": \"unknown\"," >> "$OUTPUT_FILE"
        echo "    \"free_gb\": \"unknown\"," >> "$OUTPUT_FILE"
        echo "    \"available_gb\": \"unknown\"," >> "$OUTPUT_FILE"
        echo "    \"buffers_gb\": \"unknown\"," >> "$OUTPUT_FILE"
        echo "    \"cached_gb\": \"unknown\"," >> "$OUTPUT_FILE"
        echo "    \"swap_total_gb\": \"unknown\"," >> "$OUTPUT_FILE"
        echo "    \"swap_free_gb\": \"unknown\"" >> "$OUTPUT_FILE"
    fi
    echo "  }," >> "$OUTPUT_FILE"
}
