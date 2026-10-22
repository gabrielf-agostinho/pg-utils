-- =====================================================
-- Testes: br
-- =====================================================

SELECT pg_temp.assert_equals(util.is_valid_cpf('529.982.247-25'), true, 'cpf válido com máscara');
SELECT pg_temp.assert_equals(util.is_valid_cpf('52998224725'), true, 'cpf válido sem máscara');
SELECT pg_temp.assert_equals(util.is_valid_cpf('529.982.247-26'), false, 'cpf DV inválido');
SELECT pg_temp.assert_equals(util.is_valid_cpf('111.111.111-11'), false, 'cpf repetido');
SELECT pg_temp.assert_equals(util.is_valid_cpf('5299822472'), false, 'cpf curto');
SELECT pg_temp.assert_equals(util.is_valid_cpf('a52998224725'), false, 'cpf com letra');

SELECT pg_temp.assert_equals(util.is_valid_cnpj('11.222.333/0001-81'), true, 'cnpj válido com máscara');
SELECT pg_temp.assert_equals(util.is_valid_cnpj('11222333000181'), true, 'cnpj válido sem máscara');
SELECT pg_temp.assert_equals(util.is_valid_cnpj('11.222.333/0001-82'), false, 'cnpj DV inválido');
SELECT pg_temp.assert_equals(util.is_valid_cnpj('00.000.000/0000-00'), false, 'cnpj repetido');
SELECT pg_temp.assert_equals(util.is_valid_cnpj('12.ABC.345/01DE-35'), true, 'cnpj alfanumérico');
SELECT pg_temp.assert_equals(util.is_valid_cnpj('12abc34501de35'), true, 'cnpj alfanumérico minúsculo');
SELECT pg_temp.assert_equals(util.is_valid_cnpj('12.ABC.345/01DE-36'), false, 'cnpj alfanumérico DV inválido');
SELECT pg_temp.assert_equals(util.is_valid_cnpj('12.ABC.345/01DE-3A'), false, 'cnpj DV com letra');

SELECT pg_temp.assert_equals(util.format_cpf('52998224725'), '529.982.247-25', 'format_cpf');
SELECT pg_temp.assert_equals(util.format_cpf('529.982.247-25'), '529.982.247-25', 'format_cpf já formatado');
SELECT pg_temp.assert_equals(util.format_cpf('123'), NULL::TEXT, 'format_cpf inválido');

SELECT pg_temp.assert_equals(util.format_cnpj('11222333000181'), '11.222.333/0001-81', 'format_cnpj');
SELECT pg_temp.assert_equals(util.format_cnpj('12abc34501de35'), '12.ABC.345/01DE-35', 'format_cnpj alfanumérico');
SELECT pg_temp.assert_equals(util.format_cnpj('123'), NULL::TEXT, 'format_cnpj inválido');
