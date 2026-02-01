-- =====================================================
-- Função: util.business_days_between
--
-- Objetivo:
--   Calcular a quantidade de dias úteis entre duas datas.
--
-- Regras:
--   - Exclui sábado e domingo
--   - Exclui feriados da tabela util.holidays
--   - Ordem das datas não importa
-- =====================================================

CREATE OR REPLACE FUNCTION util.business_days_between(
    start_date DATE,
    end_date   DATE
)
RETURNS INTEGER
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    d DATE;
    total INTEGER := 0;
    from_date DATE;
    to_date   DATE;
BEGIN
    IF start_date IS NULL OR end_date IS NULL THEN
        RETURN NULL;
    END IF;

    from_date := LEAST(start_date, end_date);
    to_date   := GREATEST(start_date, end_date);

    FOR d IN
        SELECT generate_series(from_date, to_date, interval '1 day')::date
    LOOP
        IF EXTRACT(ISODOW FROM d) < 6
           AND NOT EXISTS (
               SELECT 1
               FROM util.holidays h
               WHERE h.date = d
           )
        THEN
            total := total + 1;
        END IF;
    END LOOP;

    RETURN total;
END;
$$;

COMMENT ON FUNCTION util.business_days_between(DATE, DATE)
IS 'Calcula a quantidade de dias úteis entre duas datas, excluindo fins de semana e feriados';