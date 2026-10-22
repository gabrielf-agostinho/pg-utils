-- =====================================================
-- Testes: triggers
-- =====================================================

CREATE TABLE public.t_audit (
    id         INTEGER PRIMARY KEY,
    nome       TEXT,
    segredo    TEXT,
    updated_at TIMESTAMPTZ
);

SELECT util.add_updated_at_trigger('public.t_audit');
SELECT util.enable_audit('public.t_audit', ARRAY['segredo', 'updated_at']);

INSERT INTO public.t_audit (id, nome, segredo) VALUES (1, 'Ana', 'x');

-- updated_at
UPDATE public.t_audit SET nome = 'Ana' WHERE id = 1;
SELECT pg_temp.assert_equals((SELECT updated_at FROM public.t_audit), NULL::TIMESTAMPTZ, 'updated_at sem mudança');

UPDATE public.t_audit SET nome = 'Ana Maria' WHERE id = 1;
SELECT pg_temp.assert_equals((SELECT updated_at FROM public.t_audit), now(), 'updated_at atualizado');

-- auditoria
UPDATE public.t_audit SET segredo = 'y' WHERE id = 1;   -- só coluna ignorada: não audita
DELETE FROM public.t_audit WHERE id = 1;

SELECT pg_temp.assert_equals(
    (SELECT string_agg(operation, ',' ORDER BY id) FROM util.audit_log WHERE table_name = 't_audit'),
    'INSERT,UPDATE,DELETE',
    'audit operações'
);
SELECT pg_temp.assert_equals(
    (SELECT changed_fields FROM util.audit_log WHERE table_name = 't_audit' AND operation = 'UPDATE'),
    '{"nome":"Ana Maria"}'::JSONB,
    'audit changed_fields'
);
SELECT pg_temp.assert_equals(
    (SELECT bool_and(NOT (COALESCE(old_data, new_data) ? 'segredo')) FROM util.audit_log WHERE table_name = 't_audit'),
    true,
    'audit ignora colunas'
);

SET LOCAL util.audit_user = 'joao@empresa.com';
INSERT INTO public.t_audit (id, nome) VALUES (2, 'Bia');
SELECT pg_temp.assert_equals(
    (SELECT changed_by FROM util.audit_log WHERE table_name = 't_audit' ORDER BY id DESC LIMIT 1),
    'joao@empresa.com',
    'audit_user'
);

SELECT util.disable_audit('public.t_audit');
INSERT INTO public.t_audit (id, nome) VALUES (3, 'Caio');
SELECT pg_temp.assert_equals(
    (SELECT count(*) FROM util.audit_log WHERE table_name = 't_audit'),
    4::BIGINT,
    'disable_audit'
);
