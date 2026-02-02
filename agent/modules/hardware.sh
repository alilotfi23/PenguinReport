#!/bin/bash

hardware_info() {
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
}

