-- =====================================================
-- Função: util.remove_extra_spaces
--
-- Objetivo:
--   Normalizar espaços em um texto.
--
-- Comportamento:
--   - Remove espaços duplicados
--   - Remove espaços no início e fim
--   - Retorna NULL se o resultado for vazio
-- =====================================================

CREATE OR REPLACE FUNCTION util.remove_extra_spaces(value TEXT)
RETURNS TEXT
LANGUAGE sql
IMMUTABLE
AS $$
    SELECT
        util.coalesce_empty(
            REGEXP_REPLACE(value, '\s+', ' ', 'g')
        );
$$;

COMMENT ON FUNCTION util.remove_extra_spaces(TEXT)
IS 'Remove espaços duplicados e normaliza espaçamento';
