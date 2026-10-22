-- =====================================================
-- Função: util.is_valid_email
--
-- Objetivo:
--   Validar o formato de um endereço de e-mail.
--
-- Regras:
--   - Até 254 caracteres
--   - Parte local com letras, dígitos e . _ % + -
--   - Sem pontos consecutivos, no início ou no fim da
--     parte local
--   - Domínio com pelo menos um ponto
--
--   Valida apenas o formato, não a existência.
--
-- Exemplos:
--   util.is_valid_email('fulano@empresa.com.br')  -> true
--   util.is_valid_email('fulano@empresa')         -> false
-- =====================================================

CREATE OR REPLACE FUNCTION util.is_valid_email(p_value TEXT)
RETURNS BOOLEAN
LANGUAGE sql
IMMUTABLE
STRICT
PARALLEL SAFE
AS $$
    SELECT length(p_value) <= 254
       AND p_value ~ '^[A-Za-z0-9_%+-]+(\.[A-Za-z0-9_%+-]+)*@([A-Za-z0-9]([A-Za-z0-9-]*[A-Za-z0-9])?\.)+[A-Za-z]{2,}$';
$$;

COMMENT ON FUNCTION util.is_valid_email(TEXT)
IS 'Valida o formato de um endereço de e-mail';
