-- =====================================================
-- Trigger function: util.trg_set_updated_at
-- Função:           util.add_updated_at_trigger
--
-- Objetivo:
--   Preencher automaticamente a coluna de "última
--   alteração" a cada UPDATE que realmente modifique o
--   registro.
--
-- Uso:
--   SELECT util.add_updated_at_trigger('public.clientes');
--   SELECT util.add_updated_at_trigger('public.pedidos', 'alterado_em');
--
--   Ou manualmente:
--   CREATE TRIGGER trg_set_updated_at
--       BEFORE UPDATE ON public.clientes
--       FOR EACH ROW EXECUTE FUNCTION util.trg_set_updated_at('updated_at');
-- =====================================================

CREATE OR REPLACE FUNCTION util.trg_set_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_column TEXT := COALESCE(TG_ARGV[0], 'updated_at');
BEGIN
    -- Compara via JSONB porque alguns tipos (json, point...)
    -- não possuem operador de igualdade
    IF to_jsonb(NEW) IS DISTINCT FROM to_jsonb(OLD) THEN
        NEW := jsonb_populate_record(NEW, jsonb_build_object(v_column, now()));
    END IF;

    RETURN NEW;
END;
$$;

COMMENT ON FUNCTION util.trg_set_updated_at()
IS 'Trigger BEFORE UPDATE que atualiza a coluna informada (padrão: updated_at) com now()';


CREATE OR REPLACE FUNCTION util.add_updated_at_trigger(
    p_table       REGCLASS,
    p_column_name TEXT DEFAULT 'updated_at'
)
RETURNS VOID
LANGUAGE plpgsql
VOLATILE
AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_catalog.pg_attribute
        WHERE attrelid = p_table
          AND attname  = p_column_name
          AND attnum   > 0
          AND NOT attisdropped
    ) THEN
        RAISE EXCEPTION 'Coluna "%" não existe em %', p_column_name, p_table;
    END IF;

    EXECUTE format('DROP TRIGGER IF EXISTS trg_set_updated_at ON %s', p_table);
    EXECUTE format(
        'CREATE TRIGGER trg_set_updated_at
             BEFORE UPDATE ON %s
             FOR EACH ROW EXECUTE FUNCTION util.trg_set_updated_at(%L)',
        p_table, p_column_name
    );
END;
$$;

COMMENT ON FUNCTION util.add_updated_at_trigger(REGCLASS, TEXT)
IS 'Cria (ou recria) na tabela o trigger que mantém a coluna de última alteração';
