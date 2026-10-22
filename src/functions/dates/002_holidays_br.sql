-- =====================================================
-- Função: util.holidays_br
--
-- Objetivo:
--   Listar os feriados nacionais brasileiros de um ano,
--   sem gravar nada no banco.
--
-- Regras:
--   - Feriados fixos da Lei 662/1949 e posteriores
--   - Consciência Negra (20/11) a partir de 2024
--     (Lei 14.759/2023)
--   - Móveis calculados a partir da Páscoa: Carnaval
--     (terça), Sexta-feira Santa e Corpus Christi
--
-- Exemplos:
--   SELECT * FROM util.holidays_br(2026);
-- =====================================================

CREATE OR REPLACE FUNCTION util.holidays_br(p_year INTEGER)
RETURNS TABLE (
    holiday_date DATE,
    description  TEXT,
    is_movable   BOOLEAN
)
LANGUAGE sql
IMMUTABLE
STRICT
PARALLEL SAFE
AS $$
    SELECT v.holiday_date, v.description, v.is_movable
    FROM util.easter_date(p_year) AS easter,
    LATERAL (
        VALUES
            (make_date(p_year,  1,  1), 'Confraternização Universal', false),
            (make_date(p_year,  4, 21), 'Tiradentes',                 false),
            (make_date(p_year,  5,  1), 'Dia do Trabalhador',         false),
            (make_date(p_year,  9,  7), 'Independência do Brasil',    false),
            (make_date(p_year, 10, 12), 'Nossa Senhora Aparecida',    false),
            (make_date(p_year, 11,  2), 'Finados',                    false),
            (make_date(p_year, 11, 15), 'Proclamação da República',   false),
            (CASE WHEN p_year >= 2024 THEN make_date(p_year, 11, 20) END,
                                        'Dia Nacional de Zumbi e da Consciência Negra', false),
            (make_date(p_year, 12, 25), 'Natal',                      false),
            (easter - 47,               'Carnaval',                   true),
            (easter - 2,                'Sexta-feira Santa',          true),
            (easter + 60,               'Corpus Christi',             true)
    ) AS v(holiday_date, description, is_movable)
    WHERE v.holiday_date IS NOT NULL
    ORDER BY v.holiday_date;
$$;

COMMENT ON FUNCTION util.holidays_br(INTEGER)
IS 'Lista os feriados nacionais brasileiros (fixos e móveis) de um ano';
