-- =====================================================
-- Testes: numeric
-- =====================================================

SELECT pg_temp.assert_equals(util.safe_divide(10, 4), 2.5, 'safe_divide');
SELECT pg_temp.assert_equals(util.safe_divide(10, 0), NULL::NUMERIC, 'safe_divide por zero');
SELECT pg_temp.assert_equals(util.safe_divide(NULL, 2), NULL::NUMERIC, 'safe_divide NULL');

SELECT pg_temp.assert_equals(util.percentage(1, 3), 33.33, 'percentage');
SELECT pg_temp.assert_equals(util.percentage(1, 3, 4), 33.3333, 'percentage escala');
SELECT pg_temp.assert_equals(util.percentage(5, 0), NULL::NUMERIC, 'percentage total zero');

SELECT pg_temp.assert_equals(util.clamp(15, 0, 10), 10::NUMERIC, 'clamp máximo');
SELECT pg_temp.assert_equals(util.clamp(-5, 0, 10), 0::NUMERIC, 'clamp mínimo');
SELECT pg_temp.assert_equals(util.clamp(5, 0, 10), 5::NUMERIC, 'clamp dentro');
SELECT pg_temp.assert_equals(util.clamp(-5, 0, NULL), 0::NUMERIC, 'clamp sem máximo');
SELECT pg_temp.assert_equals(util.clamp(NULL, 0, 10), NULL::NUMERIC, 'clamp NULL');
