-- =====================================================
-- Função: util.safe_divide
--
-- Objetivo:
--   Realizar divisão numérica sem risco de divisão
--   por zero.
--
-- Comportamento:
--   - b = 0        -> NULL
--   - a ou b NULL -> NULL
-- =====================================================

CREATE OR REPLACE FUNCTION util.safe_divide(
    a NUMERIC,
    b NUMERIC
)
RETURNS NUMERIC
LANGUAGE sql
IMMUTABLE
PARALLEL SAFE
AS $$
    SELECT a / NULLIF(b, 0);
$$;

COMMENT ON FUNCTION util.safe_divide(NUMERIC, NUMERIC)
IS 'Divisão segura que retorna NULL quando o divisor é zero';
