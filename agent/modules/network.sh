#!/bin/bash

network_info() {
    echo "  \"network\": {" >> "$OUTPUT_FILE"

    # Get the hostname and domain
    local hostname=$(hostname)
    local domain=$(hostname -d 2>/dev/null || echo "")

    echo "    \"hostname\": \"$hostname\"," >> "$OUTPUT_FILE"
    echo "    \"domain\": \"$domain\"," >> "$OUTPUT_FILE"

    # Use 'ip' command's built-in JSON output for interfaces
    echo -n "    \"interfaces\": " >> "$OUTPUT_FILE"
    if command -v ip >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
        ip -j addr show | jq -c '.' >> "$OUTPUT_FILE"
    else
        echo "[]," >> "$OUTPUT_FILE"
    fi
    echo "," >> "$OUTPUT_FILE"

    # Build the routing section
    echo "    \"routing\": {" >> "$OUTPUT_FILE"
    
    # Extract default gateway
    local gateway=$(ip route show default | awk '/default/ {print $3}')
    echo "      \"default_gateway\": \"$gateway\"," >> "$OUTPUT_FILE"

    # Get all routes in JSON format
    echo -n "      \"routes\": " >> "$OUTPUT_FILE"
    if command -v ip >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
        ip -j route show | jq -c '.' >> "$OUTPUT_FILE"
    else
        echo "[]" >> "$OUTPUT_FILE"
    fi

    echo "    }" >> "$OUTPUT_FILE"
    echo "  }," >> "$OUTPUT_FILE"
}
