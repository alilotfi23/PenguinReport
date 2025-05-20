#!/bin/bash

# Define output file
OUTPUT_FILE="server_info_$(date +%Y%m%d_%H%M%S).json"

# Function to escape JSON special characters
escape_json() {
    local string="$1"
    string=${string//\\/\\\\} # Backslash
    string=${string//\"/\\\"} # Double quote
    string=${string//\//\\\/} # Forward slash
    string=${string//$'\t'/\\t} # Tab
    string=${string//$'\n'/\\n} # New line
    string=${string//$'\r'/\\r} # Carriage return
    echo "$string"
}

# Start JSON output
echo "{" > "$OUTPUT_FILE"

# System information
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

# CPU information
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

# Memory information
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

# Disk information
echo "  \"disks\": [" >> "$OUTPUT_FILE"
if command -v lsblk >/dev/null 2>&1; then
    lsblk -J | jq -c '.blockdevices[]' 2>/dev/null | while read -r disk; do
        echo "    $disk," >> "$OUTPUT_FILE"
    done
fi
# Remove trailing comma from last disk entry
sed -i '$ s/,$//' "$OUTPUT_FILE" 2>/dev/null
echo "  ]," >> "$OUTPUT_FILE"

# Filesystem information
echo "  \"filesystems\": [" >> "$OUTPUT_FILE"
if command -v df >/dev/null 2>&1; then
    df -hT | awk 'NR>1 {print $1","$2","$3","$4","$5","$6","$7}' | while IFS=, read -r fs type size used avail use mounted; do
        echo "    {" >> "$OUTPUT_FILE"
        echo "      \"filesystem\": \"$(escape_json "$fs")\"," >> "$OUTPUT_FILE"
        echo "      \"type\": \"$(escape_json "$type")\"," >> "$OUTPUT_FILE"
        echo "      \"size\": \"$(escape_json "$size")\"," >> "$OUTPUT_FILE"
        echo "      \"used\": \"$(escape_json "$used")\"," >> "$OUTPUT_FILE"
        echo "      \"available\": \"$(escape_json "$avail")\"," >> "$OUTPUT_FILE"
        echo "      \"use_percentage\": \"$(escape_json "$use")\"," >> "$OUTPUT_FILE"
        echo "      \"mounted_on\": \"$(escape_json "$mounted")\"" >> "$OUTPUT_FILE"
        echo "    }," >> "$OUTPUT_FILE"
    done
fi
# Remove trailing comma from last filesystem entry
sed -i '$ s/,$//' "$OUTPUT_FILE" 2>/dev/null
echo "  ]," >> "$OUTPUT_FILE"

# Network information
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

# Installed packages
echo "  \"packages\": {" >> "$OUTPUT_FILE"
if [ -x "$(command -v dpkg)" ]; then
    echo "    \"package_manager\": \"dpkg\"," >> "$OUTPUT_FILE"
    echo "    \"list\": [" >> "$OUTPUT_FILE"
    dpkg -l | awk 'NR>5 {print $2" "$3}' | while read -r pkg version; do
        echo "      {\"name\": \"$(escape_json "$pkg")\", \"version\": \"$(escape_json "$version")\"}," >> "$OUTPUT_FILE"
    done
elif [ -x "$(command -v rpm)" ]; then
    echo "    \"package_manager\": \"rpm\"," >> "$OUTPUT_FILE"
    echo "    \"list\": [" >> "$OUTPUT_FILE"
    rpm -qa --queryformat '%{NAME} %{VERSION}\n' | while read -r pkg version; do
        echo "      {\"name\": \"$(escape_json "$pkg")\", \"version\": \"$(escape_json "$version")\"}," >> "$OUTPUT_FILE"
    done
else
    echo "    \"package_manager\": \"unknown\"," >> "$OUTPUT_FILE"
    echo "    \"list\": []" >> "$OUTPUT_FILE"
fi
# Remove trailing comma from last package entry if needed
if [ -x "$(command -v dpkg)" ] || [ -x "$(command -v rpm)" ]; then
    sed -i '$ s/,$//' "$OUTPUT_FILE" 2>/dev/null
    echo "    ]" >> "$OUTPUT_FILE"
fi
echo "  }," >> "$OUTPUT_FILE"

# Services information
echo "  \"services\": {" >> "$OUTPUT_FILE"
if [ -x "$(command -v systemctl)" ]; then
    echo "    \"init_system\": \"systemd\"," >> "$OUTPUT_FILE"
    echo "    \"active_services\": [" >> "$OUTPUT_FILE"
    systemctl list-units --type=service --state=running --no-pager --no-legend 2>/dev/null | awk '{print $1}' | while read -r service; do
        echo "      \"$(escape_json "$service")\"," >> "$OUTPUT_FILE"
    done
    # Remove trailing comma from last service entry
    sed -i '$ s/,$//' "$OUTPUT_FILE" 2>/dev/null
    echo "    ]" >> "$OUTPUT_FILE"
elif [ -x "$(command -v initctl)" ]; then
    echo "    \"init_system\": \"upstart\"," >> "$OUTPUT_FILE"
    echo "    \"active_services\": [" >> "$OUTPUT_FILE"
    initctl list 2>/dev/null | grep running | awk '{print $1}' | while read -r service; do
        echo "      \"$(escape_json "$service")\"," >> "$OUTPUT_FILE"
    done
    # Remove trailing comma from last service entry
    sed -i '$ s/,$//' "$OUTPUT_FILE" 2>/dev/null
    echo "    ]" >> "$OUTPUT_FILE"
else
    echo "    \"init_system\": \"unknown\"," >> "$OUTPUT_FILE"
    echo "    \"active_services\": []" >> "$OUTPUT_FILE"
fi
echo "  }," >> "$OUTPUT_FILE"

# Users and groups
echo "  \"users\": [" >> "$OUTPUT_FILE"
getent passwd | awk -F: '{print $1","$3","$6","$7}' | while IFS=, read -r user id home shell; do
    echo "    {" >> "$OUTPUT_FILE"
    echo "      \"username\": \"$(escape_json "$user")\"," >> "$OUTPUT_FILE"
    echo "      \"uid\": \"$id\"," >> "$OUTPUT_FILE"
    echo "      \"home_directory\": \"$(escape_json "$home")\"," >> "$OUTPUT_FILE"
    echo "      \"shell\": \"$(escape_json "$shell")\"" >> "$OUTPUT_FILE"
    echo "    }," >> "$OUTPUT_FILE"
done
# Remove trailing comma from last user entry
sed -i '$ s/,$//' "$OUTPUT_FILE" 2>/dev/null
echo "  ]," >> "$OUTPUT_FILE"

# Environment variables
echo "  \"environment_variables\": {" >> "$OUTPUT_FILE"
env | awk -F= '{print $1}' | while read -r var; do
    value=$(eval echo "\$$var")
    echo "    \"$(escape_json "$var")\": \"$(escape_json "$value")\"," >> "$OUTPUT_FILE"
done
# Remove trailing comma from last variable entry
sed -i '$ s/,$//' "$OUTPUT_FILE" 2>/dev/null
echo "  }," >> "$OUTPUT_FILE"

# Hardware information (from /sys)
echo "  \"hardware\": {" >> "$OUTPUT_FILE"
echo "    \"dmi\": {" >> "$OUTPUT_FILE"
if [ -f /sys/class/dmi/id/product_name ]; then
    echo "      \"product_name\": \"$(escape_json "$(cat /sys/class/dmi/id/product_name)")\"," >> "$OUTPUT_FILE"
    echo "      \"product_version\": \"$(escape_json "$(cat /sys/class/dmi/id/product_version)")\"," >> "$OUTPUT_FILE"
    echo "      \"product_serial\": \"$(escape_json "$(cat /sys/class/dmi/id/product_serial)")\"," >> "$OUTPUT_FILE"
    echo "      \"product_uuid\": \"$(escape_json "$(cat /sys/class/dmi/id/product_uuid)")\"," >> "$OUTPUT_FILE"
    echo "      \"bios_vendor\": \"$(escape_json "$(cat /sys/class/dmi/id/bios_vendor)")\"," >> "$OUTPUT_FILE"
    echo "      \"bios_version\": \"$(escape_json "$(cat /sys/class/dmi/id/bios_version)")\"," >> "$OUTPUT_FILE"
    echo "      \"bios_date\": \"$(escape_json "$(cat /sys/class/dmi/id/bios_date)")\"" >> "$OUTPUT_FILE"
else
    echo "      \"product_name\": \"N/A\"," >> "$OUTPUT_FILE"
    echo "      \"product_version\": \"N/A\"," >> "$OUTPUT_FILE"
    echo "      \"product_serial\": \"N/A\"," >> "$OUTPUT_FILE"
    echo "      \"product_uuid\": \"N/A\"," >> "$OUTPUT_FILE"
    echo "      \"bios_vendor\": \"N/A\"," >> "$OUTPUT_FILE"
    echo "      \"bios_version\": \"N/A\"," >> "$OUTPUT_FILE"
    echo "      \"bios_date\": \"N/A\"" >> "$OUTPUT_FILE"
fi
echo "    }," >> "$OUTPUT_FILE"
echo "    \"usb_devices\": [" >> "$OUTPUT_FILE"
if command -v lsusb >/dev/null 2>&1; then
    lsusb 2>/dev/null | while read -r line; do
        echo "      \"$(escape_json "$line")\"," >> "$OUTPUT_FILE"
    done
    # Remove trailing comma from last USB device entry if any
    sed -i '$ s/,$//' "$OUTPUT_FILE" 2>/dev/null
fi
echo "    ]," >> "$OUTPUT_FILE"
echo "    \"pci_devices\": [" >> "$OUTPUT_FILE"
if command -v lspci >/dev/null 2>&1; then
    lspci 2>/dev/null | while read -r line; do
        echo "      \"$(escape_json "$line")\"," >> "$OUTPUT_FILE"
    done
    # Remove trailing comma from last PCI device entry if any
    sed -i '$ s/,$//' "$OUTPUT_FILE" 2>/dev/null
fi
echo "    ]" >> "$OUTPUT_FILE"
echo "  }," >> "$OUTPUT_FILE"

# System load and performance
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

# Security information
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

# Date and time information
echo "  \"datetime\": {" >> "$OUTPUT_FILE"
echo "    \"current\": \"$(escape_json "$(date)")\"," >> "$OUTPUT_FILE"
echo "    \"uptime\": \"$(escape_json "$(uptime -s) 2>/dev/null")\"," >> "$OUTPUT_FILE"
echo "    \"timezone\": \"$(escape_json "$(timedatectl 2>/dev/null | grep 'Time zone' | awk '{print $3}' || cat /etc/timezone 2>/dev/null || echo "unknown")")\"," >> "$OUTPUT_FILE"
echo "    \"ntp_sync\": \"$(escape_json "$(timedatectl 2>/dev/null | grep 'NTP synchronized' | awk '{print $3}' || echo "unknown")")\"," >> "$OUTPUT_FILE"
echo "    \"rtc_time\": \"$(escape_json "$(hwclock -r 2>/dev/null || echo "unknown")")\"" >> "$OUTPUT_FILE"
echo "  }," >> "$OUTPUT_FILE"

# Kernel modules
echo "  \"kernel_modules\": [" >> "$OUTPUT_FILE"
if [ -f /proc/modules ]; then
    awk '{print $1}' /proc/modules | while read -r module; do
        echo "    \"$(escape_json "$module")\"," >> "$OUTPUT_FILE"
    done
    # Remove trailing comma from last module entry
    sed -i '$ s/,$//' "$OUTPUT_FILE" 2>/dev/null
fi
echo "  ]," >> "$OUTPUT_FILE"

# Docker containers (if docker is installed)
echo "  \"docker\": {" >> "$OUTPUT_FILE"
if command -v docker >/dev/null 2>&1; then
    echo "    \"version\": \"$(escape_json "$(docker --version | awk '{print $3}' | sed 's/,//')")\"," >> "$OUTPUT_FILE"
    echo "    \"containers\": [" >> "$OUTPUT_FILE"
    docker ps -a --format '{"name":"{{.Names}}","image":"{{.Image}}","status":"{{.Status}}","ports":"{{.Ports}}"}' 2>/dev/null | while read -r container; do
        echo "      $container," >> "$OUTPUT_FILE"
    done
    # Remove trailing comma from last container entry if any
    sed -i '$ s/,$//' "$OUTPUT_FILE" 2>/dev/null
    echo "    ]" >> "$OUTPUT_FILE"
else
    echo "    \"version\": \"not_installed\"," >> "$OUTPUT_FILE"
    echo "    \"containers\": []" >> "$OUTPUT_FILE"
fi
echo "  }" >> "$OUTPUT_FILE"

# End JSON output
echo "}" >> "$OUTPUT_FILE"

# Validate JSON (if jq is available)
if command -v jq >/dev/null 2>&1; then
    jq . "$OUTPUT_FILE" > "${OUTPUT_FILE}.tmp" && mv "${OUTPUT_FILE}.tmp" "$OUTPUT_FILE"
else
    # Basic JSON validation - remove trailing commas that might break JSON
    sed -i ':begin;$!N;s/,\n *}/\n *}/g;tbegin;P;D' "$OUTPUT_FILE"
    sed -i ':begin;$!N;s/,\n *]/ \n *]/g;tbegin;P;D' "$OUTPUT_FILE"
fi

echo "Server information has been saved to $OUTPUT_FILE"
