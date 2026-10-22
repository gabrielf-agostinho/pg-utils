-- =====================================================
-- Função: util.age_in_years
--
-- Objetivo:
--   Calcular a idade em anos completos.
--
-- Exemplos:
--   util.age_in_years('1990-10-23', '2026-10-22')  -> 35
--   util.age_in_years('1990-10-22', '2026-10-22')  -> 36
--   util.age_in_years('1990-10-22')                -> idade hoje
-- =====================================================

CREATE OR REPLACE FUNCTION util.age_in_years(
    p_birth_date     DATE,
    p_reference_date DATE DEFAULT CURRENT_DATE
)
RETURNS INTEGER
LANGUAGE sql
IMMUTABLE
STRICT
PARALLEL SAFE
AS $$
    SELECT EXTRACT(YEAR FROM age(p_reference_date::TIMESTAMP, p_birth_date::TIMESTAMP))::INTEGER;
$$;

COMMENT ON FUNCTION util.age_in_years(DATE, DATE)
IS 'Calcula a idade em anos completos na data de referência (padrão: hoje)';
