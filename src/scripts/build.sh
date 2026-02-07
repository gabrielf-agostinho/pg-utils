#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

VERSION="$(cat "$ROOT_DIR/VERSION" 2>/dev/null || echo "dev")"
BUILD_DATE="$(date -u +"%Y-%m-%d %H:%M:%S UTC")"

OUTPUT="$ROOT_DIR/build/install.sql"

mkdir -p "$ROOT_DIR/build"

write_section() {
  local file="$1"

  echo "" >> "$OUTPUT"
  echo "-- =====================================================" >> "$OUTPUT"
  echo "-- $(basename "$file")" >> "$OUTPUT"
  echo "-- =====================================================" >> "$OUTPUT"
  echo "" >> "$OUTPUT"
  cat "$file" >> "$OUTPUT"
}

echo "-- =====================================================" > "$OUTPUT"
echo "-- postgres-utils" >> "$OUTPUT"
echo "-- Version: $VERSION" >> "$OUTPUT"
echo "-- Build date: $BUILD_DATE" >> "$OUTPUT"
echo "-- GENERATED FILE - DO NOT EDIT" >> "$OUTPUT"
echo "-- =====================================================" >> "$OUTPUT"

# -----------------------------------------------------
# DDL (schemas + extensions + tables + functions)
# -----------------------------------------------------
echo "" >> "$OUTPUT"
echo "BEGIN;" >> "$OUTPUT"

for file in $(ls "$ROOT_DIR"/src/schemas/*.sql 2>/dev/null | sort); do
  write_section "$file"
done

for file in $(ls "$ROOT_DIR"/src/extensions/*.sql 2>/dev/null | sort); do
  write_section "$file"
done

for file in $(ls "$ROOT_DIR"/src/tables/*.sql 2>/dev/null | sort); do
  write_section "$file"
done

for file in $(ls "$ROOT_DIR"/src/functions/*.sql 2>/dev/null | sort); do
  write_section "$file"
done

echo "" >> "$OUTPUT"
echo "COMMIT;" >> "$OUTPUT"

# -----------------------------------------------------
# Seeds
# -----------------------------------------------------
SEEDS=$(ls "$ROOT_DIR"/src/seeds/*.sql 2>/dev/null || true)

if [ -n "$SEEDS" ]; then
  echo "" >> "$OUTPUT"
  echo "BEGIN;" >> "$OUTPUT"

  for file in $(echo "$SEEDS" | sort); do
    write_section "$file"
  done

  echo "" >> "$OUTPUT"
  echo "COMMIT;" >> "$OUTPUT"
fi

echo ""
echo "Build completed: $OUTPUT"
