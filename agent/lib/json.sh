#!/bin/bash

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

json_open() {
    echo "{" >> "$OUTPUT_FILE"
}

json_close() {
    echo "}" >> "$OUTPUT_FILE"
}

json_comma_fix() {
    sed -i '$ s/,$//' "$OUTPUT_FILE" 2>/dev/null
}

