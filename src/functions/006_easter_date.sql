-- =====================================================
-- Função: util.easter_date
--
-- Objetivo:
--   Calcular a data da Páscoa para um determinado ano.
-- =====================================================

CREATE OR REPLACE FUNCTION util.easter_date(year INTEGER)
RETURNS DATE
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
    a INTEGER;
    b INTEGER;
    c INTEGER;
    d INTEGER;
    e INTEGER;
    f INTEGER;
    g INTEGER;
    h INTEGER;
    i INTEGER;
    k INTEGER;
    l INTEGER;
    m INTEGER;
    month INTEGER;
    day INTEGER;
BEGIN
    a := year % 19;
    b := year / 100;
    c := year % 100;
    d := b / 4;
    e := b % 4;
    f := (b + 8) / 25;
    g := (b - f + 1) / 3;
    h := (19 * a + b - d - g + 15) % 30;
    i := c / 4;
    k := c % 4;
    l := (32 + 2 * e + 2 * i - h - k) % 7;
    m := (a + 11 * h + 22 * l) / 451;
    month := (h + l - 7 * m + 114) / 31;
    day := ((h + l - 7 * m + 114) % 31) + 1;

    RETURN make_date(year, month, day);
END;
$$;

COMMENT ON FUNCTION util.easter_date(INTEGER)
IS 'Calcula a data da Páscoa para um determinado ano';
