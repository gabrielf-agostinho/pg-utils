-- =====================================================
-- Função: util.format_cnpj
--
-- Objetivo:
--   Aplicar a máscara 00.000.000/0000-00 a um CNPJ,
--   numérico ou alfanumérico. Não valida os dígitos
--   verificadores (use util.is_valid_cnpj para isso).
--
-- Exemplos:
--   util.format_cnpj('11222333000181')  -> '11.222.333/0001-81'
--   util.format_cnpj('12abc34501de35')  -> '12.ABC.345/01DE-35'
--   util.format_cnpj('123')             -> NULL
-- =====================================================

CREATE OR REPLACE FUNCTION util.format_cnpj(p_cnpj TEXT)
RETURNS TEXT
LANGUAGE sql
IMMUTABLE
STRICT
PARALLEL SAFE
AS $$
    SELECT REGEXP_REPLACE(c, '^(.{2})(.{3})(.{3})(.{4})(.{2})$', '\1.\2.\3/\4-\5')
    FROM upper(REGEXP_REPLACE(p_cnpj, '[^0-9A-Za-z]', '', 'g')) AS c
    WHERE c ~ '^[0-9A-Z]{12}[0-9]{2}$';
$$;

COMMENT ON FUNCTION util.format_cnpj(TEXT)
IS 'Formata um CNPJ (numérico ou alfanumérico) com a máscara 00.000.000/0000-00';
