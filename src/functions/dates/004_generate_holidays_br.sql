-- =====================================================
-- Função: util.generate_holidays_br
--
-- Objetivo:
--   Inserir na util.holidays todos os feriados
--   nacionais brasileiros (fixos e móveis) de um ano ou
--   de um intervalo de anos. Datas já cadastradas são
--   mantidas.
--
-- Retorno:
--   Quantidade de feriados inseridos.
--
-- Exemplos:
--   SELECT util.generate_holidays_br(2027);
--   SELECT util.generate_holidays_br(2000, 2100);
-- =====================================================

CREATE OR REPLACE FUNCTION util.generate_holidays_br(
    p_start_year INTEGER,
    p_end_year   INTEGER DEFAULT NULL
)
RETURNS INTEGER
LANGUAGE sql
VOLATILE
AS $$
    WITH inserted AS (
        INSERT INTO util.holidays (date, description, type)
        SELECT h.holiday_date, h.description, 'national'
        FROM generate_series(p_start_year, COALESCE(p_end_year, p_start_year)) AS y,
             util.holidays_br(y) AS h
        ON CONFLICT DO NOTHING
        RETURNING 1
    )
    SELECT count(*)::INTEGER FROM inserted;
$$;

COMMENT ON FUNCTION util.generate_holidays_br(INTEGER, INTEGER)
IS 'Insere os feriados nacionais brasileiros de um ano ou intervalo de anos; retorna quantos foram inseridos';
