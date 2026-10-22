-- =====================================================
-- Função: util.format_cpf
--
-- Objetivo:
--   Aplicar a máscara 000.000.000-00 a um CPF.
--   Não valida os dígitos verificadores (use
--   util.is_valid_cpf para isso).
--
-- Exemplos:
--   util.format_cpf('52998224725')     -> '529.982.247-25'
--   util.format_cpf('529.982.247-25')  -> '529.982.247-25'
--   util.format_cpf('123')             -> NULL
-- =====================================================

CREATE OR REPLACE FUNCTION util.format_cpf(p_cpf TEXT)
RETURNS TEXT
LANGUAGE sql
IMMUTABLE
STRICT
PARALLEL SAFE
AS $$
    SELECT REGEXP_REPLACE(d, '^(\d{3})(\d{3})(\d{3})(\d{2})$', '\1.\2.\3-\4')
    FROM util.only_digits(p_cpf) AS d
    WHERE length(d) = 11;
$$;

COMMENT ON FUNCTION util.format_cpf(TEXT)
IS 'Formata um CPF com a máscara 000.000.000-00 (NULL se não tiver 11 dígitos)';
