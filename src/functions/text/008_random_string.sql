-- =====================================================
-- Função: util.random_string
--
-- Objetivo:
--   Gerar uma string aleatória com o tamanho e o
--   conjunto de caracteres informados.
--
-- Atenção:
--   Usa random(), que NÃO é criptograficamente seguro.
--   Para tokens de segurança, use gen_random_uuid() ou
--   a extensão pgcrypto.
--
-- Exemplos:
--   util.random_string(8)                -> 'aZ3kP9qL'
--   util.random_string(6, '0123456789')  -> '402917'
-- =====================================================

CREATE OR REPLACE FUNCTION util.random_string(
    p_length  INTEGER,
    p_charset TEXT DEFAULT 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
)
RETURNS TEXT
LANGUAGE sql
VOLATILE
STRICT
PARALLEL RESTRICTED
AS $$
    SELECT COALESCE(
        string_agg(substr(p_charset, 1 + floor(random() * length(p_charset))::INTEGER, 1), ''),
        ''
    )
    FROM generate_series(1, p_length);
$$;

COMMENT ON FUNCTION util.random_string(INTEGER, TEXT)
IS 'Gera uma string aleatória (não criptográfica) com o tamanho e caracteres informados';
