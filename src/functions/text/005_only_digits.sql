-- =====================================================
-- Função: util.only_digits
--
-- Objetivo:
--   Manter apenas os dígitos de um texto.
--
-- Exemplos:
--   util.only_digits('(11) 98765-4321')  -> '11987654321'
--   util.only_digits('abc')              -> NULL
-- =====================================================

CREATE OR REPLACE FUNCTION util.only_digits(p_value TEXT)
RETURNS TEXT
LANGUAGE sql
IMMUTABLE
STRICT
PARALLEL SAFE
AS $$
    SELECT NULLIF(REGEXP_REPLACE(p_value, '[^0-9]', '', 'g'), '');
$$;

COMMENT ON FUNCTION util.only_digits(TEXT)
IS 'Remove todos os caracteres que não são dígitos (retorna NULL se não sobrar nenhum)';
