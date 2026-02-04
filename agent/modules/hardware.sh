#!/bin/bash

hardware_info() {
    echo "  \"hardware\": {" >> "$OUTPUT_FILE"
    echo "    \"dmi\": {" >> "$OUTPUT_FILE"
    local dmi_dir="/sys/class/dmi/id"
    read_dmi() {
        if [ -r "$dmi_dir/$1" ]; then
            escape_json "$(cat "$dmi_dir/$1")"
        else
            echo "Permission Denied/NA"
        fi
    }

    cat <<EOF >> "$OUTPUT_FILE"
      "product_name": "$(read_dmi product_name)",
      "product_version": "$(read_dmi product_version)",
      "product_serial": "$(read_dmi product_serial)",
      "product_uuid": "$(read_dmi product_uuid)",
      "bios_vendor": "$(read_dmi bios_vendor)",
      "bios_version": "$(read_dmi bios_version)",
      "bios_date": "$(read_dmi bios_date)"
EOF
    echo "    }," >> "$OUTPUT_FILE"

    # 2. USB Devices (using awk to avoid the trailing comma loop)
    echo "    \"usb_devices\": [" >> "$OUTPUT_FILE"
    if command -v lsusb >/dev/null 2>&1; then
        lsusb | awk '{printf "      \"%s\",\n", $0}' | sed '$ s/,$//' >> "$OUTPUT_FILE"
    fi
    echo "    ]," >> "$OUTPUT_FILE"

    # 3. PCI Devices
    echo "    \"pci_devices\": [" >> "$OUTPUT_FILE"
    if command -v lspci >/dev/null 2>&1; then
        lspci | awk '{printf "      \"%s\",\n", $0}' | sed '$ s/,$//' >> "$OUTPUT_FILE"
    fi
    echo "    ]" >> "$OUTPUT_FILE"

    echo "  }," >> "$OUTPUT_FILE"
}
