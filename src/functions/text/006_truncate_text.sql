-- =====================================================
-- Função: util.truncate_text
--
-- Objetivo:
--   Limitar um texto a um tamanho máximo, adicionando
--   um sufixo quando houver corte. O resultado nunca
--   ultrapassa p_max_length.
--
-- Exemplos:
--   util.truncate_text('PostgreSQL é ótimo', 10)       -> 'Postgre...'
--   util.truncate_text('PostgreSQL é ótimo', 10, '…')  -> 'PostgreSQ…'
--   util.truncate_text('curto', 10)                    -> 'curto'
-- =====================================================

CREATE OR REPLACE FUNCTION util.truncate_text(
    p_value      TEXT,
    p_max_length INTEGER,
    p_suffix     TEXT DEFAULT '...'
)
RETURNS TEXT
LANGUAGE sql
IMMUTABLE
STRICT
PARALLEL SAFE
AS $$
    SELECT
        CASE
            WHEN length(p_value) <= p_max_length THEN p_value
            WHEN p_max_length <= length(p_suffix) THEN left(p_value, GREATEST(p_max_length, 0))
            ELSE rtrim(left(p_value, p_max_length - length(p_suffix))) || p_suffix
        END;
$$;

COMMENT ON FUNCTION util.truncate_text(TEXT, INTEGER, TEXT)
IS 'Trunca um texto ao tamanho máximo informado, adicionando um sufixo quando houver corte';
