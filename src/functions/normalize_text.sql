-- =====================================================
-- Função: util.normalize_text
--
-- Objetivo:
--   Normalizar texto para comparações e buscas.
--
-- Etapas:
--   1. Converte vazio em NULL
--   2. Lowercase
--   3. Remove acentos
--   4. Remove caracteres especiais
--   5. Normaliza espaços
-- =====================================================

CREATE OR REPLACE FUNCTION util.normalize_text(value TEXT)
RETURNS TEXT
LANGUAGE sql
IMMUTABLE
AS $$
    SELECT
        util.coalesce_empty(
            REGEXP_REPLACE(
                unaccent(lower(value)),
                '[^a-z0-9]+',
                ' ',
                'g'
            )
        );
$$;

COMMENT ON FUNCTION util.normalize_text(TEXT)
IS 'Normaliza texto removendo acentos, símbolos e espaços extras';