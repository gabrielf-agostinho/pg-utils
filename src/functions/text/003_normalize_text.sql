-- =====================================================
-- Função: util.normalize_text
--
-- Objetivo:
--   Normalizar texto para comparações e buscas.
--
-- Etapas:
--   1. Remove acentos
--   2. Lowercase
--   3. Substitui caracteres especiais por espaço
--   4. Normaliza espaços
--   5. Converte vazio em NULL
--
-- Exemplos:
--   util.normalize_text('  São  Paulo/SP ')  -> 'sao paulo sp'
--   util.normalize_text('!!!')              -> NULL
-- =====================================================

CREATE OR REPLACE FUNCTION util.normalize_text(value TEXT)
RETURNS TEXT
LANGUAGE sql
IMMUTABLE
PARALLEL SAFE
AS $$
    SELECT
        util.coalesce_empty(
            REGEXP_REPLACE(
                lower(util.unaccent(value)),
                '[^a-z0-9]+',
                ' ',
                'g'
            )
        );
$$;

COMMENT ON FUNCTION util.normalize_text(TEXT)
IS 'Normaliza texto removendo acentos, símbolos e espaços extras';
