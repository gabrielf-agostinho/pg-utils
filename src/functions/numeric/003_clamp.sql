-- =====================================================
-- Função: util.clamp
--
-- Objetivo:
--   Restringir um valor a um intervalo [min, max].
--
-- Comportamento:
--   - p_value NULL       -> NULL
--   - p_min / p_max NULL -> limite ignorado
--
-- Exemplos:
--   util.clamp(15, 0, 10)    -> 10
--   util.clamp(-5, 0, 10)    -> 0
--   util.clamp(-5, 0, NULL)  -> 0
-- =====================================================

CREATE OR REPLACE FUNCTION util.clamp(
    p_value NUMERIC,
    p_min   NUMERIC,
    p_max   NUMERIC
)
RETURNS NUMERIC
LANGUAGE sql
IMMUTABLE
PARALLEL SAFE
AS $$
    SELECT
        CASE
            WHEN p_value IS NULL THEN NULL
            ELSE LEAST(GREATEST(p_value, p_min), p_max)
        END;
$$;

COMMENT ON FUNCTION util.clamp(NUMERIC, NUMERIC, NUMERIC)
IS 'Restringe um valor ao intervalo [min, max]; limites NULL são ignorados';
