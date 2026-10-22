-- =====================================================
-- Função: util.is_valid_cpf
--
-- Objetivo:
--   Validar um CPF pelos dígitos verificadores.
--
-- Regras:
--   - Aceita com ou sem máscara (. - e espaços)
--   - Exige 11 dígitos
--   - Rejeita sequências repetidas (ex.: 111.111.111-11)
--
-- Exemplos:
--   util.is_valid_cpf('529.982.247-25')  -> true
--   util.is_valid_cpf('52998224725')     -> true
--   util.is_valid_cpf('529.982.247-26')  -> false
-- =====================================================

CREATE OR REPLACE FUNCTION util.is_valid_cpf(p_cpf TEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql
IMMUTABLE
STRICT
PARALLEL SAFE
AS $$
DECLARE
    v_cpf   TEXT := REGEXP_REPLACE(p_cpf, '[.\-\s]', '', 'g');
    v_sum   INTEGER;
    v_check INTEGER;
BEGIN
    IF v_cpf !~ '^[0-9]{11}$' OR v_cpf ~ '^(.)\1{10}$' THEN
        RETURN FALSE;
    END IF;

    -- Dígito na posição n + 1 é calculado sobre os n anteriores
    FOR n IN 9..10 LOOP
        v_sum := 0;

        FOR i IN 1..n LOOP
            v_sum := v_sum + substr(v_cpf, i, 1)::INTEGER * (n + 2 - i);
        END LOOP;

        v_check := (v_sum * 10) % 11 % 10;

        IF v_check <> substr(v_cpf, n + 1, 1)::INTEGER THEN
            RETURN FALSE;
        END IF;
    END LOOP;

    RETURN TRUE;
END;
$$;

COMMENT ON FUNCTION util.is_valid_cpf(TEXT)
IS 'Valida um CPF (com ou sem máscara) pelos dígitos verificadores';
