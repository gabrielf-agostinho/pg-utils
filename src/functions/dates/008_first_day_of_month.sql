-- =====================================================
-- Função: util.first_day_of_month
--
-- Objetivo:
--   Retornar o primeiro dia do mês da data informada.
--
-- Exemplos:
--   util.first_day_of_month('2026-02-17')  -> 2026-02-01
-- =====================================================

CREATE OR REPLACE FUNCTION util.first_day_of_month(p_date DATE)
RETURNS DATE
LANGUAGE sql
IMMUTABLE
STRICT
PARALLEL SAFE
AS $$
    -- Cast explícito para TIMESTAMP: com TIMESTAMPTZ o
    -- resultado dependeria do TimeZone da sessão
    SELECT date_trunc('month', p_date::TIMESTAMP)::DATE;
$$;

COMMENT ON FUNCTION util.first_day_of_month(DATE)
IS 'Retorna o primeiro dia do mês da data informada';
