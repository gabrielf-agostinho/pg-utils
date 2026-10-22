-- =====================================================
-- Testes: json
-- =====================================================

SELECT pg_temp.assert_equals(
    util.jsonb_diff('{"a":1,"b":2}', '{"a":1,"b":3,"c":4}'),
    '{"b":3,"c":4}'::JSONB,
    'jsonb_diff alterado e adicionado'
);
SELECT pg_temp.assert_equals(util.jsonb_diff('{"a":1,"b":2}', '{"a":1}'), '{"b":null}'::JSONB, 'jsonb_diff removido');
SELECT pg_temp.assert_equals(util.jsonb_diff('{"a":1}', '{"a":1}'), NULL::JSONB, 'jsonb_diff igual');
SELECT pg_temp.assert_equals(
    util.jsonb_diff('{"a":{"x":1,"y":2}}', '{"a":{"x":1,"y":5}}'),
    '{"a":{"y":5}}'::JSONB,
    'jsonb_diff aninhado'
);
SELECT pg_temp.assert_equals(util.jsonb_diff(NULL, '{"a":1}'), '{"a":1}'::JSONB, 'jsonb_diff old NULL');
SELECT pg_temp.assert_equals(util.jsonb_diff('[1]', '[2]'), '[2]'::JSONB, 'jsonb_diff não-objeto');

SELECT pg_temp.assert_equals(
    util.jsonb_deep_merge('{"a":{"x":1,"y":2},"b":1}', '{"a":{"y":3,"z":4},"c":2}'),
    '{"a":{"x":1,"y":3,"z":4},"b":1,"c":2}'::JSONB,
    'jsonb_deep_merge'
);
SELECT pg_temp.assert_equals(util.jsonb_deep_merge('{"a":[1,2]}', '{"a":[3]}'), '{"a":[3]}'::JSONB, 'jsonb_deep_merge array substitui');
SELECT pg_temp.assert_equals(util.jsonb_deep_merge(NULL, '{"a":1}'), '{"a":1}'::JSONB, 'jsonb_deep_merge NULL');
SELECT pg_temp.assert_equals(util.jsonb_deep_merge('{}', '{}'), '{}'::JSONB, 'jsonb_deep_merge vazios');
