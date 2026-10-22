-- =====================================================
-- Helpers de teste (criados em pg_temp, somem ao fim
-- da sessão)
-- =====================================================

CREATE FUNCTION pg_temp.assert_equals(
    p_actual   ANYELEMENT,
    p_expected ANYELEMENT,
    p_message  TEXT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_actual IS DISTINCT FROM p_expected THEN
        RAISE EXCEPTION 'FALHOU: % (esperado: %, obtido: %)',
            p_message, COALESCE(p_expected::TEXT, 'NULL'), COALESCE(p_actual::TEXT, 'NULL');
    END IF;
END;
$$;
