-- =====================================================
-- Função: util.slugify
--
-- Objetivo:
--   Gerar um slug amigável para URLs.
--
-- Exemplos:
--   util.slugify('Olá, Mundo!')            -> 'ola-mundo'
--   util.slugify('Preço  R$ 10,00', '_')   -> 'preco_r_10_00'
--   util.slugify('***')                    -> NULL
-- =====================================================

CREATE OR REPLACE FUNCTION util.slugify(
    p_value     TEXT,
    p_separator TEXT DEFAULT '-'
)
RETURNS TEXT
LANGUAGE sql
IMMUTABLE
STRICT
PARALLEL SAFE
AS $$
    SELECT NULLIF(
        BTRIM(
            REGEXP_REPLACE(lower(util.unaccent(p_value)), '[^a-z0-9]+', p_separator, 'g'),
            p_separator
        ),
        ''
    );
$$;

COMMENT ON FUNCTION util.slugify(TEXT, TEXT)
IS 'Gera um slug (minúsculo, sem acentos, separado por hífen) a partir de um texto';
