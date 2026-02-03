#!/bin/bash

packages_info() {
    echo "  \"packages\": {" >> "$OUTPUT_FILE"

    # Detect the package manager
    if command -v dpkg >/dev/null 2>&1; then
        manager="dpkg"
        cmd="dpkg-query -W -f='    {\"name\": \"\${Package}\", \"version\": \"\${Version}\"},\n'"
    elif command -v rpm >/dev/null 2>&1; then
        manager="rpm"
        cmd="rpm -qa --queryformat '    {\"name\": \"%{NAME}\", \"version\": \"%{VERSION}\"},\n'"
    elif command -v pacman >/dev/null 2>&1; then
        manager="pacman"
        # Arch Linux: -Q lists packages, awk formats it
        cmd="pacman -Q | awk '{print \"    {\\\"name\\\": \\\"\"\$1\"\\\", \\\"version\\\": \\\"\"\$2\"\\\"},\"}'"
    elif command -v apk >/dev/null 2>&1; then
        manager="apk"
        # Alpine: info -v lists name and version
        cmd="apk info -v | awk -F'-' '{v=\$NF; sub(\"-\"v, \"\"); print \"    {\\\"name\\\": \\\"\"\$0\"\\\", \\\"version\\\": \\\"\"v\"\\\"},\"}'"
    else
        manager="unknown"
    fi

    echo "    \"package_manager\": \"$manager\"," >> "$OUTPUT_FILE"
    echo "    \"list\": [" >> "$OUTPUT_FILE"

    if [ "$manager" != "unknown" ]; then
        # Execute the command and trim the trailing comma from the last line
        eval "$cmd" | sed '$ s/,$//' >> "$OUTPUT_FILE"
    fi

    echo "    ]" >> "$OUTPUT_FILE"
    echo "  }," >> "$OUTPUT_FILE"
}
