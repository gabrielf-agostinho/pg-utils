#!/usr/bin/env bash
# =====================================================
# Gera build/install.sql concatenando os fontes em
# ordem de dependência.
#
# Uso:
#   ./scripts/build.sh
# =====================================================
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SRC_DIR="$ROOT_DIR/src"
OUTPUT="$ROOT_DIR/build/install.sql"

VERSION="$(tr -d '[:space:]' < "$ROOT_DIR/VERSION" 2>/dev/null || echo "dev")"
BUILD_DATE="$(date -u +"%Y-%m-%d %H:%M:%S UTC")"

# Ordem de instalação. Funções LANGUAGE sql são validadas
# na criação, então um domínio só pode depender dos que
# vêm antes dele nesta lista.
SECTIONS=(
  schemas
  extensions
  tables
  functions/text
  functions/numeric
  functions/br
  functions/dates
  functions/json
  functions/metadata
  functions/triggers
  seeds
)

mkdir -p "$ROOT_DIR/build"

write_section() {
  local file="$1"
  local rel="${file#"$SRC_DIR"/}"

  printf '\n-- =====================================================\n'
  printf -- '-- %s\n' "$rel"
  printf -- '-- =====================================================\n\n'
  # Remove CR caso o arquivo tenha sido salvo com CRLF
  tr -d '\r' < "$file"
  printf '\n'
}

count=0

{
  printf -- '-- =====================================================\n'
  printf -- '-- pg-utils\n'
  printf -- '-- Version: %s\n' "$VERSION"
  printf -- '-- Build date: %s\n' "$BUILD_DATE"
  printf -- '-- GENERATED FILE - DO NOT EDIT\n'
  printf -- '-- =====================================================\n\n'
  printf '\\set ON_ERROR_STOP on\n'
  printf 'SET client_min_messages = warning;\n\n'
  printf 'BEGIN;\n'

  for section in "${SECTIONS[@]}"; do
    dir="$SRC_DIR/$section"
    [ -d "$dir" ] || continue

    while IFS= read -r file; do
      write_section "$file"
      count=$((count + 1))
    done < <(find "$dir" -maxdepth 1 -type f -name '*.sql' | LC_ALL=C sort)
  done

  printf '\nCOMMENT ON SCHEMA util IS %s;\n' "'pg-utils $VERSION'"
  printf '\nCOMMIT;\n'
} > "$OUTPUT"

# Avisa sobre arquivos fora das seções conhecidas
while IFS= read -r file; do
  rel="${file#"$SRC_DIR"/}"
  known=false
  for section in "${SECTIONS[@]}"; do
    [ "$(dirname "$rel")" = "$section" ] && known=true && break
  done
  $known || echo "WARNING: $rel não pertence a nenhuma seção e foi ignorado" >&2
done < <(find "$SRC_DIR" -type f -name '*.sql')

echo "Build completed: $OUTPUT (v$VERSION, $count arquivos)"
