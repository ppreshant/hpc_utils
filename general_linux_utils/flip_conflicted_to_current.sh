#!/usr/bin/env bash
set -euo pipefail

# Usage: ./resolve_conflict.sh "appearance.json"
#        ./resolve_conflict.sh "path/to/appearance.json"

real="${1:?Usage: $0 <real_file>}"

if [[ ! -f "$real" ]]; then
    echo "Error: real file not found: $real" >&2
    exit 1
fi

ext="${real##*.}"
base="${real%.*}"
conflict=$(find "$(dirname -- "$real")" -maxdepth 1 -type f \
    -name "$base (conflict *).$ext" | head -n 1)

if [[ -z "$conflict" ]]; then
    echo "Error: no conflict file found for: $real" >&2
    exit 1
fi

archive="archive_${real}"
mv -n -- "$real" "$archive"
mv -n -- "$conflict" "$real"

echo "Resolved: $(basename -- "$conflict") -> $(basename -- "$real")"
echo "Archived: $(basename -- "$real") -> $(basename -- "$archive")"
