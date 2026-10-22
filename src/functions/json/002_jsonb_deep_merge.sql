-- =====================================================
-- Função: util.jsonb_deep_merge
--
-- Objetivo:
--   Mesclar dois JSONB recursivamente. Diferente do
--   operador ||, objetos aninhados são mesclados em vez
--   de substituídos.
--
-- Regras:
--   - Em conflito, prevalece o valor da direita
--   - Objetos presentes nos dois lados são mesclados
--   - Arrays e escalares são substituídos
--   - Um dos lados NULL -> retorna o outro
--
-- Exemplos:
--   util.jsonb_deep_merge('{"a":{"x":1,"y":2}}', '{"a":{"y":3}}')
--     -> {"a": {"x": 1, "y": 3}}
--   '{"a":{"x":1,"y":2}}'::jsonb || '{"a":{"y":3}}'
--     -> {"a": {"y": 3}}
-- =====================================================

CREATE OR REPLACE FUNCTION util.jsonb_deep_merge(
    p_left  JSONB,
    p_right JSONB
)
RETURNS JSONB
LANGUAGE plpgsql
IMMUTABLE
PARALLEL SAFE
AS $$
DECLARE
    v_result JSONB;
    v_key    TEXT;
    v_value  JSONB;
BEGIN
    IF p_left IS NULL OR p_right IS NULL THEN
        RETURN COALESCE(p_right, p_left);
    END IF;

    IF jsonb_typeof(p_left) <> 'object' OR jsonb_typeof(p_right) <> 'object' THEN
        RETURN p_right;
    END IF;

    v_result := p_left;

    FOR v_key, v_value IN SELECT * FROM jsonb_each(p_right) LOOP
        v_result := v_result || jsonb_build_object(
            v_key,
            util.jsonb_deep_merge(p_left -> v_key, v_value)
        );
    END LOOP;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION util.jsonb_deep_merge(JSONB, JSONB)
IS 'Mescla dois JSONB recursivamente; em conflito prevalece o da direita';
