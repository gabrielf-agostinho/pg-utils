-- =====================================================
-- Testes: text
-- =====================================================

SELECT pg_temp.assert_equals(util.coalesce_empty(NULL), NULL::TEXT, 'coalesce_empty NULL');
SELECT pg_temp.assert_equals(util.coalesce_empty('   '), NULL::TEXT, 'coalesce_empty espaços');
SELECT pg_temp.assert_equals(util.coalesce_empty('  abc  '), 'abc', 'coalesce_empty trim');

SELECT pg_temp.assert_equals(util.unaccent('Ação Café Ç'), 'Acao Cafe C', 'unaccent');
SELECT pg_temp.assert_equals(
    (SELECT provolatile FROM pg_proc WHERE oid = 'util.unaccent(text)'::regprocedure),
    'i'::"char",
    'unaccent é IMMUTABLE'
);

SELECT pg_temp.assert_equals(util.normalize_text('  São  Paulo/SP '), 'sao paulo sp', 'normalize_text');
SELECT pg_temp.assert_equals(util.normalize_text('!!!'), NULL::TEXT, 'normalize_text só símbolos');

SELECT pg_temp.assert_equals(util.slugify('Olá, Mundo!'), 'ola-mundo', 'slugify');
SELECT pg_temp.assert_equals(util.slugify('Preço  R$ 10,00', '_'), 'preco_r_10_00', 'slugify separador');
SELECT pg_temp.assert_equals(util.slugify('***'), NULL::TEXT, 'slugify vazio');

SELECT pg_temp.assert_equals(util.only_digits('(11) 98765-4321'), '11987654321', 'only_digits');
SELECT pg_temp.assert_equals(util.only_digits('abc'), NULL::TEXT, 'only_digits sem dígitos');

SELECT pg_temp.assert_equals(util.truncate_text('PostgreSQL é ótimo', 10), 'Postgre...', 'truncate_text');
SELECT pg_temp.assert_equals(util.truncate_text('PostgreSQL é ótimo', 10, '…'), 'PostgreSQ…', 'truncate_text sufixo');
SELECT pg_temp.assert_equals(util.truncate_text('curto', 10), 'curto', 'truncate_text sem corte');
SELECT pg_temp.assert_equals(util.truncate_text('abcdef', 2), 'ab', 'truncate_text menor que sufixo');

SELECT pg_temp.assert_equals(util.is_valid_email('fulano@empresa.com.br'), true, 'email válido');
SELECT pg_temp.assert_equals(util.is_valid_email('fulano.de+tal@sub.empresa.io'), true, 'email com + e subdomínio');
SELECT pg_temp.assert_equals(util.is_valid_email('fulano@empresa'), false, 'email sem TLD');
SELECT pg_temp.assert_equals(util.is_valid_email('ful..ano@empresa.com'), false, 'email pontos consecutivos');
SELECT pg_temp.assert_equals(util.is_valid_email('.fulano@empresa.com'), false, 'email começa com ponto');
SELECT pg_temp.assert_equals(util.is_valid_email('fulano@-empresa.com'), false, 'email domínio com hífen inicial');

SELECT pg_temp.assert_equals(length(util.random_string(16)), 16, 'random_string tamanho');
SELECT pg_temp.assert_equals(util.random_string(20, 'x'), repeat('x', 20), 'random_string charset');
SELECT pg_temp.assert_equals(util.random_string(0), '', 'random_string zero');
SELECT pg_temp.assert_equals(util.random_string(500, '0123456789') ~ '^[0-9]+$', true, 'random_string só dígitos');
