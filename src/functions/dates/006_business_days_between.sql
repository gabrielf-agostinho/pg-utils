-- =====================================================
-- Função: util.business_days_between
--
-- Objetivo:
--   Calcular a quantidade de dias úteis entre duas datas.
--
-- Regras:
--   - Intervalo inclusivo nas duas pontas
--   - Exclui sábado e domingo
--   - Exclui feriados da tabela util.holidays
--   - Ordem das datas não importa
--   - Alguma data NULL -> NULL
--
-- Exemplos:
--   util.business_days_between('2026-04-01', '2026-04-07')  -> 4
-- =====================================================

CREATE OR REPLACE FUNCTION util.business_days_between(
    start_date DATE,
    end_date   DATE
)
RETURNS INTEGER
LANGUAGE sql
STABLE
STRICT
PARALLEL SAFE
AS $$
    SELECT count(*)::INTEGER
    FROM generate_series(
             LEAST(start_date, end_date)::TIMESTAMP,
             GREATEST(start_date, end_date)::TIMESTAMP,
             INTERVAL '1 day'
         ) AS g(day)
    WHERE EXTRACT(ISODOW FROM g.day) < 6
      AND NOT EXISTS (
          SELECT 1
          FROM util.holidays h
          WHERE h.date = g.day::DATE
      );
$$;

COMMENT ON FUNCTION util.business_days_between(DATE, DATE)
IS 'Calcula a quantidade de dias úteis entre duas datas, excluindo fins de semana e feriados';
