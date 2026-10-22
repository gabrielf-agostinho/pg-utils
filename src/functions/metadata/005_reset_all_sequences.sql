-- =====================================================
-- Função: util.reset_all_sequences
--
-- Objetivo:
--   Executar util.reset_sequence em todas as colunas
--   serial/identity das tabelas de um schema.
--
-- Exemplos:
--   SELECT * FROM util.reset_all_sequences('public');
-- =====================================================

CREATE OR REPLACE FUNCTION util.reset_all_sequences(p_schema_name TEXT DEFAULT 'public')
RETURNS TABLE (
    table_name  TEXT,
    column_name TEXT,
    next_value  BIGINT
)
LANGUAGE plpgsql
VOLATILE
AS $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN
        SELECT c.oid::REGCLASS AS tbl, a.attname::TEXT AS col
        FROM pg_catalog.pg_class c
        JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
        JOIN pg_catalog.pg_attribute a ON a.attrelid = c.oid
        WHERE n.nspname = p_schema_name
          AND c.relkind = 'r'
          AND a.attnum > 0
          AND NOT a.attisdropped
          AND pg_get_serial_sequence(c.oid::REGCLASS::TEXT, a.attname) IS NOT NULL
        ORDER BY c.relname, a.attnum
    LOOP
        table_name  := r.tbl::TEXT;
        column_name := r.col;
        next_value  := util.reset_sequence(r.tbl, r.col);
        RETURN NEXT;
    END LOOP;
END;
$$;

COMMENT ON FUNCTION util.reset_all_sequences(TEXT)
IS 'Ajusta todas as sequences serial/identity das tabelas de um schema';
