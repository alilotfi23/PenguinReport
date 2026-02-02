#!/bin/bash

security_info() {
    echo "  \"security\": {" >> "$OUTPUT_FILE"
    echo "    \"selinux\": \"$(getenforce 2>/dev/null || echo "Disabled")\"," >> "$OUTPUT_FILE"
    echo "    \"iptables_rules\": \"$(iptables -L 2>/dev/null | wc -l)\"," >> "$OUTPUT_FILE"
    echo "    \"sudoers\": [" >> "$OUTPUT_FILE"
    if [ -f /etc/sudoers ]; then
        grep -v '^#' /etc/sudoers | grep -v '^$' | while read -r line; do
            echo "      \"$(escape_json "$line")\"," >> "$OUTPUT_FILE"
        done
        # Remove trailing comma from last sudoers entry if any
        sed -i '$ s/,$//' "$OUTPUT_FILE" 2>/dev/null
    fi
    echo "    ]," >> "$OUTPUT_FILE"
    echo "    \"ssh_config\": {" >> "$OUTPUT_FILE"
    if [ -f /etc/ssh/sshd_config ]; then
        grep -v '^#' /etc/ssh/sshd_config | grep -v '^$' | while read -r line; do
            key=$(echo "$line" | awk '{print $1}')
            value=$(echo "$line" | awk '{$1=""; print $0}' | sed 's/^ //')
            echo "      \"$(escape_json "$key")\": \"$(escape_json "$value")\"," >> "$OUTPUT_FILE"
        done
        # Remove trailing comma from last SSH config entry if any
        sed -i '$ s/,$//' "$OUTPUT_FILE" 2>/dev/null
    fi
    echo "    }" >> "$OUTPUT_FILE"
    echo "  }," >> "$OUTPUT_FILE"
}

