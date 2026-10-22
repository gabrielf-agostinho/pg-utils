-- =====================================================
-- Função: util.last_day_of_month
--
-- Objetivo:
--   Retornar o último dia do mês da data informada.
--
-- Exemplos:
--   util.last_day_of_month('2028-02-10')  -> 2028-02-29
-- =====================================================

CREATE OR REPLACE FUNCTION util.last_day_of_month(p_date DATE)
RETURNS DATE
LANGUAGE sql
IMMUTABLE
STRICT
PARALLEL SAFE
AS $$
    SELECT (util.first_day_of_month(p_date) + INTERVAL '1 month')::DATE - 1;
$$;

COMMENT ON FUNCTION util.last_day_of_month(DATE)
IS 'Retorna o último dia do mês da data informada';
