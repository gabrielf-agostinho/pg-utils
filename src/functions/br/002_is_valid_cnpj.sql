-- =====================================================
-- Função: util.is_valid_cnpj
--
-- Objetivo:
--   Validar um CNPJ pelos dígitos verificadores.
--
-- Regras:
--   - Aceita com ou sem máscara (. - / e espaços)
--   - Suporta o CNPJ alfanumérico (IN RFB 2.229/2024):
--     12 caracteres [0-9A-Z] + 2 dígitos verificadores.
--     Cada caractere vale (código ASCII - 48).
--   - Rejeita sequências repetidas
--
-- Exemplos:
--   util.is_valid_cnpj('11.222.333/0001-81')  -> true
--   util.is_valid_cnpj('12.ABC.345/01DE-35')  -> true
--   util.is_valid_cnpj('11.222.333/0001-82')  -> false
-- =====================================================

CREATE OR REPLACE FUNCTION util.is_valid_cnpj(p_cnpj TEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql
IMMUTABLE
STRICT
PARALLEL SAFE
AS $$
DECLARE
    v_cnpj   TEXT := upper(REGEXP_REPLACE(p_cnpj, '[./\-\s]', '', 'g'));
    v_sum    INTEGER;
    v_weight INTEGER;
    v_check  INTEGER;
BEGIN
    IF v_cnpj !~ '^[0-9A-Z]{12}[0-9]{2}$' OR v_cnpj ~ '^(.)\1{13}$' THEN
        RETURN FALSE;
    END IF;

    -- Pesos de 2 a 9, da direita para a esquerda, reiniciando em 2
    FOR n IN 12..13 LOOP
        v_sum    := 0;
        v_weight := 2;

        FOR i IN REVERSE n..1 LOOP
            v_sum    := v_sum + (ascii(substr(v_cnpj, i, 1)) - 48) * v_weight;
            v_weight := CASE WHEN v_weight = 9 THEN 2 ELSE v_weight + 1 END;
        END LOOP;

        v_check := CASE WHEN v_sum % 11 < 2 THEN 0 ELSE 11 - v_sum % 11 END;

        IF v_check <> substr(v_cnpj, n + 1, 1)::INTEGER THEN
            RETURN FALSE;
        END IF;
    END LOOP;

    RETURN TRUE;
END;
$$;

COMMENT ON FUNCTION util.is_valid_cnpj(TEXT)
IS 'Valida um CNPJ numérico ou alfanumérico (com ou sem máscara) pelos dígitos verificadores';
