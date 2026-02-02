#!/bin/bash

datetime_info() {
    echo "  \"datetime\": {" >> "$OUTPUT_FILE"
    echo "    \"current\": \"$(escape_json "$(date)")\"," >> "$OUTPUT_FILE"
    echo "    \"uptime\": \"$(escape_json "$(uptime -s) 2>/dev/null")\"," >> "$OUTPUT_FILE"
    echo "    \"timezone\": \"$(escape_json "$(timedatectl 2>/dev/null | grep 'Time zone' | awk '{print $3}' || cat /etc/timezone 2>/dev/null || echo "unknown")")\"," >> "$OUTPUT_FILE"
    echo "    \"ntp_sync\": \"$(escape_json "$(timedatectl 2>/dev/null | grep 'NTP synchronized' | awk '{print $3}' || echo "unknown")")\"," >> "$OUTPUT_FILE"
    echo "    \"rtc_time\": \"$(escape_json "$(hwclock -r 2>/dev/null || echo "unknown")")\"" >> "$OUTPUT_FILE"
    echo "  }," >> "$OUTPUT_FILE"
}

