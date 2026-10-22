-- =====================================================
-- Testes: dates
-- =====================================================

SELECT pg_temp.assert_equals(util.easter_date(2024), DATE '2024-03-31', 'páscoa 2024');
SELECT pg_temp.assert_equals(util.easter_date(2026), DATE '2026-04-05', 'páscoa 2026');
SELECT pg_temp.assert_equals(util.easter_date(2038), DATE '2038-04-25', 'páscoa 2038');

SELECT pg_temp.assert_equals((SELECT count(*) FROM util.holidays_br(2023)), 11::BIGINT, 'feriados 2023');
SELECT pg_temp.assert_equals((SELECT count(*) FROM util.holidays_br(2026)), 12::BIGINT, 'feriados 2026 (com Consciência Negra)');
SELECT pg_temp.assert_equals(
    (SELECT holiday_date FROM util.holidays_br(2026) WHERE description = 'Carnaval'),
    DATE '2026-02-17',
    'carnaval 2026'
);
SELECT pg_temp.assert_equals(
    (SELECT holiday_date FROM util.holidays_br(2026) WHERE description = 'Corpus Christi'),
    DATE '2026-06-04',
    'corpus christi 2026'
);

-- Seed instalou 2000..2100
SELECT pg_temp.assert_equals(
    (SELECT count(*) FROM util.holidays WHERE date BETWEEN '2026-01-01' AND '2026-12-31'),
    12::BIGINT,
    'seed 2026'
);
SELECT pg_temp.assert_equals(util.generate_holidays_br(2026), 0, 'generate_holidays_br idempotente');

SELECT pg_temp.assert_equals(util.is_business_day('2026-04-03'), false, 'sexta-feira santa');
SELECT pg_temp.assert_equals(util.is_business_day('2026-04-04'), false, 'sábado');
SELECT pg_temp.assert_equals(util.is_business_day('2026-04-06'), true, 'segunda útil');

SELECT pg_temp.assert_equals(util.business_days_between('2026-04-01', '2026-04-07'), 4, 'business_days_between');
SELECT pg_temp.assert_equals(util.business_days_between('2026-04-07', '2026-04-01'), 4, 'business_days_between invertido');
SELECT pg_temp.assert_equals(util.business_days_between('2026-04-04', '2026-04-04'), 0, 'business_days_between sábado');
SELECT pg_temp.assert_equals(util.business_days_between(NULL, '2026-04-04'), NULL::INTEGER, 'business_days_between NULL');

SELECT pg_temp.assert_equals(util.add_business_days('2026-04-02', 1), DATE '2026-04-06', 'add_business_days +1 sobre feriado');
SELECT pg_temp.assert_equals(util.add_business_days('2026-04-06', -1), DATE '2026-04-02', 'add_business_days -1');
SELECT pg_temp.assert_equals(util.add_business_days('2026-04-04', 0), DATE '2026-04-06', 'add_business_days 0 ajusta');
SELECT pg_temp.assert_equals(util.add_business_days('2026-04-06', 0), DATE '2026-04-06', 'add_business_days 0 útil');
SELECT pg_temp.assert_equals(util.add_business_days('2026-04-06', 5), DATE '2026-04-13', 'add_business_days +5');

SELECT pg_temp.assert_equals(util.first_day_of_month('2026-02-17'), DATE '2026-02-01', 'first_day_of_month');
SELECT pg_temp.assert_equals(util.last_day_of_month('2028-02-10'), DATE '2028-02-29', 'last_day_of_month bissexto');
SELECT pg_temp.assert_equals(util.last_day_of_month('2026-12-31'), DATE '2026-12-31', 'last_day_of_month dezembro');

SELECT pg_temp.assert_equals(util.age_in_years('1990-10-23', '2026-10-22'), 35, 'age_in_years véspera');
SELECT pg_temp.assert_equals(util.age_in_years('1990-10-22', '2026-10-22'), 36, 'age_in_years aniversário');
SELECT pg_temp.assert_equals(util.age_in_years('2000-02-29', '2026-02-28'), 25, 'age_in_years 29/02');
