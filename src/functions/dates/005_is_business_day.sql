-- =====================================================
-- Função: util.is_business_day
--
-- Objetivo:
--   Indicar se uma data é dia útil.
--
-- Regras:
--   - Exclui sábado e domingo
--   - Exclui feriados da tabela util.holidays
--
-- Exemplos:
--   util.is_business_day('2026-04-03')  -> false (Sexta-feira Santa)
--   util.is_business_day('2026-04-06')  -> true
-- =====================================================

CREATE OR REPLACE FUNCTION util.is_business_day(p_date DATE)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
STRICT
PARALLEL SAFE
AS $$
    SELECT EXTRACT(ISODOW FROM p_date) < 6
       AND NOT EXISTS (
           SELECT 1
           FROM util.holidays h
           WHERE h.date = p_date
       );
$$;

COMMENT ON FUNCTION util.is_business_day(DATE)
IS 'Indica se a data é dia útil (não é fim de semana nem feriado em util.holidays)';
