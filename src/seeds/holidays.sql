-- =====================================================
-- Feriados nacionais fixos - Brasil
-- =====================================================

INSERT INTO util.holidays (date, description, type)
VALUES
    ('2026-01-01', 'Confraternização Universal', 'national'),
    ('2026-04-21', 'Tiradentes', 'national'),
    ('2026-05-01', 'Dia do Trabalhador', 'national'),
    ('2026-09-07', 'Independência do Brasil', 'national'),
    ('2026-10-12', 'Nossa Senhora Aparecida', 'national'),
    ('2026-11-02', 'Finados', 'national'),
    ('2026-11-15', 'Proclamação da República', 'national'),
    ('2026-12-25', 'Natal', 'national')
ON CONFLICT DO NOTHING;

-- =====================================================
-- Feriados nacionais móveis do ano - Brasil
-- =====================================================

select util.generate_movable_holidays_br(2026);