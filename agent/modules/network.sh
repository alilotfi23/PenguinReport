#!/bin/bash

network_info() {
    echo "  \"network\": {" >> "$OUTPUT_FILE"
    echo "    \"hostname\": \"$(escape_json "$(hostname)")\"," >> "$OUTPUT_FILE"
    echo "    \"domain\": \"$(escape_json "$(dnsdomainname 2>/dev/null || echo "N/A")")\"," >> "$OUTPUT_FILE"
    echo "    \"interfaces\": [" >> "$OUTPUT_FILE"
    if command -v ip >/dev/null 2>&1; then
        ip -j addr 2>/dev/null | jq -c '.[]' | while read -r interface; do
            echo "      $interface," >> "$OUTPUT_FILE"
        done
    fi
    # Remove trailing comma from last interface entry
    sed -i '$ s/,$//' "$OUTPUT_FILE" 2>/dev/null
    echo "    ]," >> "$OUTPUT_FILE"
    echo "    \"routing\": {" >> "$OUTPUT_FILE"
    if command -v ip >/dev/null 2>&1; then
        echo "      \"default_gateway\": \"$(escape_json "$(ip route | grep default | awk '{print $3}')")\"," >> "$OUTPUT_FILE"
        echo "      \"routes\": [" >> "$OUTPUT_FILE"
        ip -j route 2>/dev/null | jq -c '.[]' | while read -r route; do
            echo "        $route," >> "$OUTPUT_FILE"
        done
        # Remove trailing comma from last route entry
        sed -i '$ s/,$//' "$OUTPUT_FILE" 2>/dev/null
        echo "      ]" >> "$OUTPUT_FILE"
    else
        echo "      \"default_gateway\": \"unknown\"," >> "$OUTPUT_FILE"
        echo "      \"routes\": []" >> "$OUTPUT_FILE"
    fi
    echo "    }" >> "$OUTPUT_FILE"
    echo "  }," >> "$OUTPUT_FILE"
}

