-- =====================================================
-- Função: util.percentage
--
-- Objetivo:
--   Calcular quanto p_part representa de p_total, em
--   porcentagem, sem risco de divisão por zero.
--
-- Exemplos:
--   util.percentage(1, 3)     -> 33.33
--   util.percentage(1, 3, 4)  -> 33.3333
--   util.percentage(5, 0)     -> NULL
-- =====================================================

CREATE OR REPLACE FUNCTION util.percentage(
    p_part  NUMERIC,
    p_total NUMERIC,
    p_scale INTEGER DEFAULT 2
)
RETURNS NUMERIC
LANGUAGE sql
IMMUTABLE
PARALLEL SAFE
AS $$
    SELECT ROUND(util.safe_divide(p_part * 100, p_total), p_scale);
$$;

COMMENT ON FUNCTION util.percentage(NUMERIC, NUMERIC, INTEGER)
IS 'Calcula a porcentagem de uma parte sobre o total (NULL se o total for zero)';
