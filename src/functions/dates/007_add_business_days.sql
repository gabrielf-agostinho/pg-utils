-- =====================================================
-- Função: util.add_business_days
--
-- Objetivo:
--   Somar (ou subtrair) dias úteis a uma data.
--
-- Comportamento:
--   - p_days > 0  -> avança p_days dias úteis
--   - p_days < 0  -> retrocede p_days dias úteis
--   - p_days = 0  -> a própria data, se for útil, ou o
--                    próximo dia útil
--
-- Exemplos:
--   util.add_business_days('2026-04-02', 1)   -> 2026-04-06
--   util.add_business_days('2026-04-06', -1)  -> 2026-04-02
--   util.add_business_days('2026-04-04', 0)   -> 2026-04-06
-- =====================================================

CREATE OR REPLACE FUNCTION util.add_business_days(
    p_date DATE,
    p_days INTEGER
)
RETURNS DATE
LANGUAGE plpgsql
STABLE
STRICT
PARALLEL SAFE
AS $$
DECLARE
    v_date      DATE    := p_date;
    v_step      INTEGER := CASE WHEN p_days < 0 THEN -1 ELSE 1 END;
    v_remaining INTEGER := abs(p_days);
BEGIN
    IF p_days = 0 THEN
        WHILE NOT util.is_business_day(v_date) LOOP
            v_date := v_date + 1;
        END LOOP;

        RETURN v_date;
    END IF;

    WHILE v_remaining > 0 LOOP
        v_date := v_date + v_step;

        IF util.is_business_day(v_date) THEN
            v_remaining := v_remaining - 1;
        END IF;
    END LOOP;

    RETURN v_date;
END;
$$;

COMMENT ON FUNCTION util.add_business_days(DATE, INTEGER)
IS 'Soma ou subtrai dias úteis a uma data (0 ajusta para o próximo dia útil)';
