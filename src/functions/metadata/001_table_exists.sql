-- =====================================================
-- Função: util.table_exists
--
-- Objetivo:
--   Verificar se a tabela informada existe no schema.
--
-- Observação:
--   Consulta pg_catalog em vez de information_schema,
--   que só lista tabelas sobre as quais o usuário atual
--   tem algum privilégio. Considera tabelas comuns,
--   particionadas, views e foreign tables.
--
-- Exemplos:
--   util.table_exists('util', 'holidays')  -> true
-- =====================================================

CREATE OR REPLACE FUNCTION util.table_exists(
    p_schema_name text,
    p_table_name  text
)
RETURNS boolean
LANGUAGE sql
STABLE
PARALLEL SAFE
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM pg_catalog.pg_class c
        JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
        WHERE n.nspname = p_schema_name
          AND c.relname = p_table_name
          AND c.relkind IN ('r', 'p', 'v', 'f')
    );
$$;

COMMENT ON FUNCTION util.table_exists(TEXT, TEXT)
IS 'Verifica se uma tabela (ou view) existe no schema informado';
