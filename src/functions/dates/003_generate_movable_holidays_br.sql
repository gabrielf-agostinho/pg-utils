-- =====================================================
-- Função: util.generate_movable_holidays_br
--
-- Objetivo:
--   Inserir feriados móveis brasileiros para um ano.
--   Datas já cadastradas são mantidas.
--
-- Veja também:
--   util.generate_holidays_br, que insere fixos e móveis.
-- =====================================================

CREATE OR REPLACE FUNCTION util.generate_movable_holidays_br(year INTEGER)
RETURNS VOID
LANGUAGE sql
VOLATILE
AS $$
    INSERT INTO util.holidays (date, description, type)
    SELECT h.holiday_date, h.description, 'national'
    FROM util.holidays_br(year) AS h
    WHERE h.is_movable
    ON CONFLICT DO NOTHING;
$$;

COMMENT ON FUNCTION util.generate_movable_holidays_br(INTEGER)
IS 'Gera feriados móveis brasileiros com base na Páscoa';
