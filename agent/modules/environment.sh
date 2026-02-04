#!/bin/bash

environment_info() {
    echo "  \"environment_variables\": {" >> "$OUTPUT_FILE"
    local first_entry=true
    while IFS='=' read -r var value; do
        if [ -z "$var" ]; then continue; fi
        
        if [ "$first_entry" = true ]; then
            first_entry=false
        else
            echo "," >> "$OUTPUT_FILE"
        fi

        # Write the key-value pair directly
        echo -n "    \"$(escape_json "$var")\": \"$(escape_json "$value")\"" >> "$OUTPUT_FILE"

    done < <(env)

    echo "" >> "$OUTPUT_FILE"
    echo "  }," >> "$OUTPUT_FILE"
}
