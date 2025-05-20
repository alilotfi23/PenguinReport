#!/bin/bash

OUTPUT_FILE="server_info_$(date +%Y%m%d_%H%M%S).json"

# Escape JSON special characters
escape_json() {
    local string="$1"
    string=${string//\\/\\\\}
    string=${string//\"/\\\"}
    string=${string//\//\\\/}
    string=${string//$'\t'/\\t}
    string=${string//$'\n'/\\n}
    string=${string//$'\r'/\\r}
    echo "$string"
}

write_system_info() {
    echo "  \"system\": {" >> "$OUTPUT_FILE"
    echo "    \"hostname\": \"$(escape_json "$(hostname)")\"," >> "$OUTPUT_FILE"
    echo "    \"operating_system\": \"$(escape_json "$(uname -o)")\"," >> "$OUTPUT_FILE"
    echo "    \"kernel_name\": \"$(escape_json "$(uname -s)")\"," >> "$OUTPUT_FILE"
    echo "    \"kernel_release\": \"$(escape_json "$(uname -r)")\"," >> "$OUTPUT_FILE"
    echo "    \"kernel_version\": \"$(escape_json "$(uname -v)")\"," >> "$OUTPUT_FILE"
    echo "    \"architecture\": \"$(escape_json "$(uname -m)")\"," >> "$OUTPUT_FILE"
    echo "    \"uptime\": \"$(escape_json "$(uptime -p | sed 's/up //')")\"," >> "$OUTPUT_FILE"
    echo "    \"last_boot\": \"$(escape_json "$(who -b | awk '{print $3 \" \" $4}')")\"" >> "$OUTPUT_FILE"
    echo "  }," >> "$OUTPUT_FILE"
}

write_cpu_info() {
    echo "  \"cpu\": {" >> "$OUTPUT_FILE"
    if [ -f /proc/cpuinfo ]; then
        echo "    \"model\": \"$(escape_json "$(grep 'model name' /proc/cpuinfo | head -1 | cut -d':' -f2 | sed 's/^[ \t]*//')")\"," >> "$OUTPUT_FILE"
        echo "    \"cores\": \"$(grep -c '^processor' /proc/cpuinfo)\"," >> "$OUTPUT_FILE"
    fi

    if command -v lscpu >/dev/null 2>&1; then
        echo "    \"threads_per_core\": \"$(lscpu | grep 'Thread(s) per core' | awk '{print $4}')\"," >> "$OUTPUT_FILE"
        echo "    \"sockets\": \"$(lscpu | grep 'Socket(s)' | awk '{print $2}')\"," >> "$OUTPUT_FILE"
        echo "    \"cpu_frequency\": \"$(lscpu | grep 'CPU MHz' | awk '{print $3}')\"," >> "$OUTPUT_FILE"
        echo "    \"cpu_max_frequency\": \"$(lscpu | grep 'CPU max MHz' | awk '{print $4}')\"," >> "$OUTPUT_FILE"
        echo "    \"cpu_min_frequency\": \"$(lscpu | grep 'CPU min MHz' | awk '{print $4}')\"" >> "$OUTPUT_FILE"
    else
        echo "    \"threads_per_core\": \"unknown\"," >> "$OUTPUT_FILE"
        echo "    \"sockets\": \"unknown\"," >> "$OUTPUT_FILE"
        echo "    \"cpu_frequency\": \"unknown\"," >> "$OUTPUT_FILE"
        echo "    \"cpu_max_frequency\": \"unknown\"," >> "$OUTPUT_FILE"
        echo "    \"cpu_min_frequency\": \"unknown\"" >> "$OUTPUT_FILE"
    fi
    echo "  }," >> "$OUTPUT_FILE"
}

write_memory_info() {
    echo "  \"memory\": {" >> "$OUTPUT_FILE"
    if [ -f /proc/meminfo ]; then
        echo "    \"total_kb\": \"$(grep MemTotal /proc/meminfo | awk '{print $2}')\"," >> "$OUTPUT_FILE"
        echo "    \"free_kb\": \"$(grep MemFree /proc/meminfo | awk '{print $2}')\"," >> "$OUTPUT_FILE"
        echo "    \"available_kb\": \"$(grep MemAvailable /proc/meminfo | awk '{print $2}')\"," >> "$OUTPUT_FILE"
        echo "    \"buffers_kb\": \"$(grep Buffers /proc/meminfo | awk '{print $2}')\"," >> "$OUTPUT_FILE"
        echo "    \"cached_kb\": \"$(grep '^Cached' /proc/meminfo | awk '{print $2}')\"," >> "$OUTPUT_FILE"
        echo "    \"swap_total_kb\": \"$(grep SwapTotal /proc/meminfo | awk '{print $2}')\"," >> "$OUTPUT_FILE"
        echo "    \"swap_free_kb\": \"$(grep SwapFree /proc/meminfo | awk '{print $2}')\"" >> "$OUTPUT_FILE"
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

write_disk_info() {
    echo "  \"disks\": [" >> "$OUTPUT_FILE"
    lsblk -o NAME,SIZE,TYPE,MOUNTPOINT | grep disk | while read -r line; do
        name=$(echo $line | awk '{print $1}')
        size=$(echo $line | awk '{print $2}')
        echo "    { \"device\": \"$name\", \"size\": \"$size\" }," >> "$OUTPUT_FILE"
    done
    sed -i '$ s/,$//' "$OUTPUT_FILE"
    echo "  ]," >> "$OUTPUT_FILE"
}

write_filesystem_info() {
    echo "  \"filesystems\": [" >> "$OUTPUT_FILE"
    df -hT | grep -vE '^tmpfs|^udev' | tail -n +2 | while read -r line; do
        fs=$(echo "$line" | awk '{print $1}')
        type=$(echo "$line" | awk '{print $2}')
        size=$(echo "$line" | awk '{print $3}')
        used=$(echo "$line" | awk '{print $4}')
        avail=$(echo "$line" | awk '{print $5}')
        mount=$(echo "$line" | awk '{print $7}')
        echo "    { \"filesystem\": \"$fs\", \"type\": \"$type\", \"size\": \"$size\", \"used\": \"$used\", \"available\": \"$avail\", \"mounted_on\": \"$mount\" }," >> "$OUTPUT_FILE"
    done
    sed -i '$ s/,$//' "$OUTPUT_FILE"
    echo "  ]," >> "$OUTPUT_FILE"
}

write_network_info() {
    echo "  \"network_interfaces\": [" >> "$OUTPUT_FILE"
    ip -o addr show | awk '{print $2,$4}' | sort | uniq | while read -r iface ipaddr; do
        echo "    { \"interface\": \"$iface\", \"address\": \"$ipaddr\" }," >> "$OUTPUT_FILE"
    done
    sed -i '$ s/,$//' "$OUTPUT_FILE"
    echo "  ]," >> "$OUTPUT_FILE"
}

write_packages_info() {
    echo "  \"installed_packages\": [" >> "$OUTPUT_FILE"
    if command -v dpkg >/dev/null 2>&1; then
        dpkg -l | tail -n +6 | awk '{print $2 " " $3}' | while read -r pkg; do
            echo "    { \"package\": \"$(escape_json "$pkg")\" }," >> "$OUTPUT_FILE"
        done
    elif command -v rpm >/dev/null 2>&1; then
        rpm -qa | while read -r pkg; do
            echo "    { \"package\": \"$(escape_json "$pkg")\" }," >> "$OUTPUT_FILE"
        done
    fi
    sed -i '$ s/,$//' "$OUTPUT_FILE"
    echo "  ]," >> "$OUTPUT_FILE"
}

write_services_info() {
    echo "  \"services\": [" >> "$OUTPUT_FILE"
    if command -v systemctl >/dev/null 2>&1; then
        systemctl list-units --type=service --state=running | awk '{print $1}' | grep '.service' | while read -r service; do
            echo "    { \"service\": \"$(escape_json "$service")\" }," >> "$OUTPUT_FILE"
        done
    fi
    sed -i '$ s/,$//' "$OUTPUT_FILE"
    echo "  ]" >> "$OUTPUT_FILE"
}

### Run all collectors
echo "{" > "$OUTPUT_FILE"
write_system_info
write_cpu_info
write_memory_info
write_disk_info
write_filesystem_info
write_network_info
write_packages_info
write_services_info
echo "}" >> "$OUTPUT_FILE"

echo "System information collected in $OUTPUT_FILE"

