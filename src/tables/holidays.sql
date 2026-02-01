-- =====================================================
-- Tabela: util.holidays
--
-- Objetivo:
--   Armazenar feriados para cálculo de dias úteis.
-- =====================================================

CREATE TABLE IF NOT EXISTS util.holidays (
    date        DATE PRIMARY KEY,
    description TEXT NOT NULL,
    type        TEXT NOT NULL DEFAULT 'national'
        CHECK (type IN ('national', 'state', 'city', 'custom'))
);

COMMENT ON TABLE util.holidays IS 'Tabela de feriados para cálculos de dias úteis';
COMMENT ON COLUMN util.holidays.date IS 'Data do feriado';
COMMENT ON COLUMN util.holidays.description IS 'Descrição do feriado';
COMMENT ON COLUMN util.holidays.type IS 'Tipo do feriado (national, state, city, custom)';