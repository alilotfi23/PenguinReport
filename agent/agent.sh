#!/bin/bash
set -e

#################################
# 1. Defaults & Metadata
#################################
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
VERSION="1.0.0"
MODE="light"  # Default mode
HOST=$(hostname)

#################################
# 2. Parse arguments
#################################
# We parse these BEFORE defining the filename
for arg in "$@"; do
  case "$arg" in
    --full)  MODE="full" ;;
    --light) MODE="light" ;;
    *)
      echo "❌ Unknown option: $arg"
      echo "Usage: $0 [--light|--full]"
      exit 1
      ;;
  esac
done

#################################
# 3. Filename Construction
#################################
# Timestamp placed first for perfect folder sorting
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
OUTPUT_FILE="${TIMESTAMP}_${HOST}_${MODE}_v${VERSION}.json"

#################################
# 4. Load libs & modules
#################################
# Ensure these paths exist relative to the script
[ -f "$BASE_DIR/lib/json.sh" ] && source "$BASE_DIR/lib/json.sh"

for module in "$BASE_DIR"/modules/*.sh; do
  [ -f "$module" ] && source "$module"
done

#################################
# 5. Module groups
#################################
run_light() {
  system_info
  cpu_info
  memory_info
  disk_info
  network_info
}

run_full() {
  system_info
  cpu_info
  memory_info
  disk_info
  network_info
  filesystem_info
  packages_info
  services_info
  users_info
  environment_info
  hardware_info
  performance_info
  security_info
  datetime_info
  kernel_modules_info
}

#################################
# 6. Start JSON Generation
#################################
echo "{" > "$OUTPUT_FILE"

# Agent metadata
echo '  "agent": {' >> "$OUTPUT_FILE"
echo "    \"version\": \"$VERSION\"," >> "$OUTPUT_FILE"
echo "    \"mode\": \"$MODE\"" >> "$OUTPUT_FILE"
echo "  }," >> "$OUTPUT_FILE"

#################################
# 7. Execute selected mode
#################################
case "$MODE" in
  light) run_light ;;
  full)  run_full  ;;
esac

#################################
# 8. Finalize JSON
#################################
# Remove trailing comma safely (Linux & macOS compatible)
# We use a temp file to ensure we don't corrupt the output
if [[ "$OSTYPE" == "darwin"* ]]; then
  sed -i '' '$ s/,$//' "$OUTPUT_FILE"
else
  sed -i '$ s/,$//' "$OUTPUT_FILE"
fi

echo "}" >> "$OUTPUT_FILE"

#################################
# 9. Validate & Beautify
#################################
if command -v jq >/dev/null 2>&1; then
  # Re-read and overwrite with pretty-printed JSON
  jq . "$OUTPUT_FILE" > "${OUTPUT_FILE}.tmp" && mv "${OUTPUT_FILE}.tmp" "$OUTPUT_FILE"
else
  echo "⚠️  Warning: 'jq' not found. JSON might not be pretty-printed."
fi

#################################
# Done
#################################
echo "✅ Discovery complete!"
echo "📄 Output saved: $OUTPUT_FILE"
