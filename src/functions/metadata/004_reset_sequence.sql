-- =====================================================
-- Função: util.reset_sequence
--
-- Objetivo:
--   Ajustar a sequence de uma coluna serial/identity
--   para MAX(coluna) + 1. Útil após cargas de dados com
--   ids explícitos, que deixam a sequence defasada e
--   causam erros de chave duplicada.
--
-- Retorno:
--   O próximo valor que a sequence vai gerar.
--
-- Exemplos:
--   SELECT util.reset_sequence('public.clientes', 'id');
-- =====================================================

CREATE OR REPLACE FUNCTION util.reset_sequence(
    p_table       REGCLASS,
    p_column_name TEXT DEFAULT 'id'
)
RETURNS BIGINT
LANGUAGE plpgsql
VOLATILE
AS $$
DECLARE
    v_sequence TEXT := pg_get_serial_sequence(p_table::TEXT, p_column_name);
    v_next     BIGINT;
BEGIN
    IF v_sequence IS NULL THEN
        RAISE EXCEPTION 'Coluna %.% não possui sequence associada', p_table, p_column_name;
    END IF;

    EXECUTE format(
        'SELECT setval(
             %1$L,
             COALESCE(
                 (SELECT MAX(%2$I) + 1 FROM %3$s),
                 (SELECT seqmin FROM pg_catalog.pg_sequence WHERE seqrelid = %1$L::REGCLASS)
             ),
             false
         )',
        v_sequence, p_column_name, p_table
    )
    INTO v_next;

    RETURN v_next;
END;
$$;

COMMENT ON FUNCTION util.reset_sequence(REGCLASS, TEXT)
IS 'Ajusta a sequence de uma coluna serial/identity para MAX(coluna) + 1';
