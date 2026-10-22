-- =====================================================
-- Função: util.jsonb_diff
--
-- Objetivo:
--   Retornar as diferenças entre dois objetos JSONB.
--
-- Regras:
--   - Comparação recursiva em objetos aninhados
--   - Campos iguais são ignorados
--   - Campos removidos aparecem com valor null
--   - Sem diferenças -> NULL
--   - Se algum dos valores não for objeto, retorna
--     new_json quando forem diferentes
--
-- Exemplos:
--   util.jsonb_diff('{"a":1,"b":2}', '{"a":1,"b":3,"c":4}')  -> {"b": 3, "c": 4}
--   util.jsonb_diff('{"a":1,"b":2}', '{"a":1}')              -> {"b": null}
-- =====================================================

CREATE OR REPLACE FUNCTION util.jsonb_diff(
    old_json JSONB,
    new_json JSONB
)
RETURNS JSONB
LANGUAGE plpgsql
IMMUTABLE
PARALLEL SAFE
AS $$
DECLARE
    result  JSONB := '{}';
    key     TEXT;
    old_val JSONB;
    new_val JSONB;
BEGIN
    IF old_json IS NOT DISTINCT FROM new_json THEN
        RETURN NULL;
    END IF;

    IF jsonb_typeof(COALESCE(old_json, '{}')) <> 'object'
       OR jsonb_typeof(COALESCE(new_json, '{}')) <> 'object'
    THEN
        RETURN COALESCE(new_json, 'null'::JSONB);
    END IF;

    FOR key IN
        SELECT jsonb_object_keys(COALESCE(old_json, '{}'))
        UNION
        SELECT jsonb_object_keys(COALESCE(new_json, '{}'))
    LOOP
        old_val := old_json -> key;
        new_val := new_json -> key;

        IF old_val IS NULL THEN
            result := result || jsonb_build_object(key, new_val);

        ELSIF new_val IS NULL THEN
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

    RETURN NULLIF(result, '{}'::JSONB);
END;
$$;

COMMENT ON FUNCTION util.jsonb_diff(JSONB, JSONB)
IS 'Retorna as diferenças entre dois objetos JSONB de forma recursiva';
