-- =====================================================
-- Função: util.column_exists
--
-- Objetivo:
--   Verificar se a coluna informada existe na tabela.
--
-- Exemplos:
--   util.column_exists('util', 'holidays', 'date')  -> true
--   util.column_exists('util', 'holidays', 'foo')   -> false
-- =====================================================

CREATE OR REPLACE FUNCTION util.column_exists(
    p_schema_name TEXT,
    p_table_name  TEXT,
    p_column_name TEXT
)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
PARALLEL SAFE
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM pg_catalog.pg_attribute a
        JOIN pg_catalog.pg_class c     ON c.oid = a.attrelid
        JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
        WHERE n.nspname = p_schema_name
          AND c.relname = p_table_name
          AND a.attname = p_column_name
          AND a.attnum > 0
          AND NOT a.attisdropped
    );
$$;

COMMENT ON FUNCTION util.column_exists(TEXT, TEXT, TEXT)
IS 'Verifica se uma coluna existe na tabela informada';
