-- =====================================================
-- Função: util.table_sizes
--
-- Objetivo:
--   Listar o tamanho em disco das tabelas, da maior
--   para a menor.
--
-- Colunas:
--   row_estimate  -> estimativa do planner (NULL se a
--                    tabela nunca foi analisada)
--   total_bytes   -> tabela + índices + TOAST
--   table_bytes   -> somente os dados
--   index_bytes   -> somente os índices
--   total_size    -> total_bytes legível (ex.: '12 MB')
--
-- Exemplos:
--   SELECT * FROM util.table_sizes();          -- todos os schemas
--   SELECT * FROM util.table_sizes('public');
-- =====================================================

CREATE OR REPLACE FUNCTION util.table_sizes(p_schema_name TEXT DEFAULT NULL)
RETURNS TABLE (
    schema_name  TEXT,
    table_name   TEXT,
    row_estimate BIGINT,
    total_bytes  BIGINT,
    table_bytes  BIGINT,
    index_bytes  BIGINT,
    total_size   TEXT
)
LANGUAGE sql
STABLE
AS $$
    SELECT
        n.nspname::TEXT,
        c.relname::TEXT,
        NULLIF(c.reltuples, -1)::BIGINT,
        pg_total_relation_size(c.oid),
        pg_relation_size(c.oid),
        pg_indexes_size(c.oid),
        pg_size_pretty(pg_total_relation_size(c.oid))
    FROM pg_catalog.pg_class c
    JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
    WHERE c.relkind IN ('r', 'm')
      AND n.nspname NOT IN ('pg_catalog', 'information_schema')
      AND n.nspname NOT LIKE 'pg\_toast%'
      AND (p_schema_name IS NULL OR n.nspname = p_schema_name)
    ORDER BY pg_total_relation_size(c.oid) DESC, 1, 2;
$$;

COMMENT ON FUNCTION util.table_sizes(TEXT)
IS 'Lista tabelas com estimativa de linhas e tamanho em disco, da maior para a menor';
