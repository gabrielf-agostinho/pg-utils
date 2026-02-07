-- =====================================================
-- Função: util.jsonb_diff
--
-- Objetivo:
--   Retornar as diferenças entre dois objetos JSONB.
--
-- Regras:
--   - Comparação recursiva
--   - Campos iguais são ignorados
--   - Campos removidos aparecem com valor NULL
-- =====================================================

CREATE OR REPLACE FUNCTION util.jsonb_diff(
    old_json JSONB,
    new_json JSONB
)
RETURNS JSONB
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
    result JSONB := '{}';
    key TEXT;
    old_val JSONB;
    new_val JSONB;
BEGIN
    IF old_json IS NULL AND new_json IS NULL THEN
        RETURN NULL;
    END IF;

    FOR key IN
        SELECT DISTINCT k
        FROM (
            SELECT jsonb_object_keys(old_json) AS k
            UNION
            SELECT jsonb_object_keys(new_json) AS k
        ) s
    LOOP
        old_val := old_json -> key;
        new_val := new_json -> key;

        IF old_val IS NULL AND new_val IS NOT NULL THEN
            result := result || jsonb_build_object(key, new_val);

        ELSIF old_val IS NOT NULL AND new_val IS NULL THEN
            result := result || jsonb_build_object(key, NULL);

        ELSIF old_val <> new_val THEN
            IF jsonb_typeof(old_val) = 'object'
               AND jsonb_typeof(new_val) = 'object'
            THEN
                result := result || jsonb_build_object(
                    key,
                    util.jsonb_diff(old_val, new_val)
                );
            ELSE
                result := result || jsonb_build_object(key, new_val);
            END IF;
        END IF;
    END LOOP;

    IF result = '{}'::jsonb THEN
        RETURN NULL;
    END IF;

    RETURN result;
END;
$$;

COMMENT ON FUNCTION util.jsonb_diff(JSONB, JSONB)
IS 'Retorna as diferenças entre dois objetos JSONB de forma recursiva';
