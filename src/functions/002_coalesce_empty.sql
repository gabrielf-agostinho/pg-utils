-- =====================================================
-- Função: util.coalesce_empty
--
-- Objetivo:
--   Converte strings vazias ou compostas apenas por
--   espaços em NULL.
--
-- Exemplos:
--   util.coalesce_empty(NULL)        -> NULL
--   util.coalesce_empty('')          -> NULL
--   util.coalesce_empty('   ')       -> NULL
--   util.coalesce_empty('  abc  ')   -> 'abc'
-- =====================================================

CREATE OR REPLACE FUNCTION util.coalesce_empty(value TEXT)
RETURNS TEXT
LANGUAGE sql
IMMUTABLE
AS $$
    SELECT NULLIF(BTRIM(value), '');
$$;

COMMENT ON FUNCTION util.coalesce_empty(TEXT)
IS 'Converte strings vazias ou apenas com espaços em NULL';
