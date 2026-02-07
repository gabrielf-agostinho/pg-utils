-- =====================================================
-- Função: util.generate_movable_holidays_br
--
-- Objetivo:
--   Inserir feriados móveis brasileiros para um ano.
-- =====================================================

CREATE OR REPLACE FUNCTION util.generate_movable_holidays_br(year INTEGER)
RETURNS VOID
LANGUAGE plpgsql
VOLATILE
AS $$
DECLARE
    easter DATE;
BEGIN
    easter := util.easter_date(year);

    INSERT INTO util.holidays (date, description, type)
    VALUES
        (easter - INTERVAL '47 days', 'Carnaval', 'national'),
        (easter - INTERVAL '2 days',  'Sexta-feira Santa', 'national'),
        (easter + INTERVAL '60 days', 'Corpus Christi', 'national')
    ON CONFLICT DO NOTHING;
END;
$$;

COMMENT ON FUNCTION util.generate_movable_holidays_br(INTEGER)
IS 'Gera feriados móveis brasileiros com base na Páscoa';
