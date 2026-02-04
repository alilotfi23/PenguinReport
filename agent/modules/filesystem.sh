#!/bin/bash

filesystem_info() {
    echo "  \"filesystems\": [" >> "$OUTPUT_FILE"
    
    if command -v df >/dev/null 2>&1; then

        first_entry=true
        while read -r fs type size used avail use mounted; do
        
            [[ "$fs" == "Filesystem" ]] && continue

            if [ "$first_entry" = true ]; then
                first_entry=false
            else
                echo "    ," >> "$OUTPUT_FILE"
            fi

            cat <<EOF >> "$OUTPUT_FILE"
    {
      "filesystem": "$(escape_json "$fs")",
      "type": "$(escape_json "$type")",
      "size": "$(escape_json "$size")",
      "used": "$(escape_json "$used")",
      "available": "$(escape_json "$avail")",
      "use_percentage": "$(escape_json "$use")",
      "mounted_on": "$(escape_json "$mounted")"
    }
EOF
        done < <(df -hPT)
    fi

    echo "  ]," >> "$OUTPUT_FILE"
}
