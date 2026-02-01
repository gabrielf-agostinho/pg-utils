-- =====================================================
-- Função: util.table_exists
--
-- Objetivo:
--   Verificar se a tabela informada existe no schema.
--
-- =====================================================

CREATE OR REPLACE FUNCTION util.table_exists(
    p_schema_name text,
    p_table_name  text
)
RETURNS boolean
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = p_schema_name
          AND table_name   = p_table_name
    );
END;
$$;