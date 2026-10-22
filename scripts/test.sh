#!/usr/bin/env bash
# =====================================================
# Gera o build, instala no banco e executa os testes.
#
# Os testes rodam dentro de uma transação desfeita ao
# final (ROLLBACK), mas a instalação é efetivada: use
# um banco descartável.
#
# Conexão via variáveis padrão do libpq (PGHOST,
# PGPORT, PGUSER, PGPASSWORD, PGDATABASE) ou via a
# variável PSQL, que substitui o comando psql:
#
#   ./scripts/test.sh
#   PSQL="docker exec -i pg-utils-test psql -U postgres" ./scripts/test.sh
# =====================================================
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PSQL="${PSQL:-psql}"

"$ROOT_DIR/scripts/build.sh"

echo "Instalando..."
$PSQL -X -q -v ON_ERROR_STOP=1 < "$ROOT_DIR/build/install.sql" > /dev/null

echo "Reinstalando (idempotência)..."
$PSQL -X -q -v ON_ERROR_STOP=1 < "$ROOT_DIR/build/install.sql" > /dev/null

echo "Executando testes..."
{
  printf '\\set ON_ERROR_STOP on\n'
  printf 'SET client_min_messages = warning;\n'
  printf 'BEGIN;\n'
  for file in $(find "$ROOT_DIR/tests" -maxdepth 1 -type f -name '*.sql' | LC_ALL=C sort); do
    printf '\\echo %s\n' "$(basename "$file")"
    tr -d '\r' < "$file"
    printf '\n'
  done
  printf 'ROLLBACK;\n'
} | $PSQL -X -q -t -v ON_ERROR_STOP=1 | grep -v '^\s*$'

echo "Todos os testes passaram."
