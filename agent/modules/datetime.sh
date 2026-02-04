#!/bin/bash

datetime_info() {
    echo "  \"datetime\": {" >> "$OUTPUT_FILE"
    local t_data
    t_data=$(timedatectl 2>/dev/null)

    local rtc=$(echo "$t_data" | awk -F': ' '/RTC time/ {print $2}' | xargs)
    [ -z "$rtc" ] && rtc="unknown"

    local ntp=$(echo "$t_data" | awk -F': ' '/System clock synchronized/ {print $2}' | xargs)
    [ -z "$ntp" ] && ntp="unknown"

    local tz=$(echo "$t_data" | awk -F': ' '/Time zone/ {print $2}' | awk '{print $1}')
    [ -z "$tz" ] && tz="unknown"

    echo "    \"current\": \"$(date +"%Y-%m-%d %H:%M:%S %Z")\"," >> "$OUTPUT_FILE"
    echo "    \"boot_time\": \"$(uptime -s 2>/dev/null || echo "unknown")\"," >> "$OUTPUT_FILE"
    echo "    \"timezone\": \"$tz\"," >> "$OUTPUT_FILE"
    echo "    \"ntp_sync\": \"$ntp\"," >> "$OUTPUT_FILE"
    echo "    \"rtc_time\": \"$rtc\"" >> "$OUTPUT_FILE"
    
    echo "  }," >> "$OUTPUT_FILE"
}
