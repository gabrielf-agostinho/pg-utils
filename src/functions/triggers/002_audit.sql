-- =====================================================
-- Trigger function: util.trg_audit
-- Funções:          util.enable_audit / util.disable_audit
--
-- Objetivo:
--   Registrar em util.audit_log todo INSERT, UPDATE e
--   DELETE de uma tabela.
--
-- Regras:
--   - UPDATE grava em changed_fields apenas o que mudou
--     (util.jsonb_diff)
--   - UPDATE sem mudança efetiva não é registrado
--   - Colunas ignoradas não são gravadas nem disparam
--     registro (ex.: updated_at, colunas sensíveis)
--   - O usuário do banco precisa de INSERT em
--     util.audit_log
--
-- Uso:
--   SELECT util.enable_audit('public.clientes');
--   SELECT util.enable_audit('public.usuarios', ARRAY['senha_hash', 'updated_at']);
--   SELECT util.disable_audit('public.clientes');
--
--   SELECT * FROM util.audit_log
--   WHERE table_name = 'clientes'
--   ORDER BY changed_at DESC;
-- =====================================================

CREATE OR REPLACE FUNCTION util.trg_audit()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_ignored TEXT[] := COALESCE(TG_ARGV, '{}');
    v_old     JSONB;
    v_new     JSONB;
    v_diff    JSONB;
BEGIN
    IF TG_OP IN ('UPDATE', 'DELETE') THEN
        v_old := to_jsonb(OLD) - v_ignored;
    END IF;

    IF TG_OP IN ('INSERT', 'UPDATE') THEN
        v_new := to_jsonb(NEW) - v_ignored;
    END IF;

    IF TG_OP = 'UPDATE' THEN
        v_diff := util.jsonb_diff(v_old, v_new);

        IF v_diff IS NULL THEN
            RETURN NULL;
        END IF;
    END IF;

    INSERT INTO util.audit_log (table_schema, table_name, operation, old_data, new_data, changed_fields)
    VALUES (TG_TABLE_SCHEMA, TG_TABLE_NAME, TG_OP, v_old, v_new, v_diff);

    RETURN NULL;
END;
$$;

COMMENT ON FUNCTION util.trg_audit()
IS 'Trigger AFTER que registra INSERT/UPDATE/DELETE em util.audit_log; argumentos = colunas ignoradas';


CREATE OR REPLACE FUNCTION util.enable_audit(
    p_table           REGCLASS,
    p_ignored_columns TEXT[] DEFAULT '{}'
)
RETURNS VOID
LANGUAGE plpgsql
VOLATILE
AS $$
BEGIN
    IF p_table = 'util.audit_log'::REGCLASS THEN
        RAISE EXCEPTION 'util.audit_log não pode ser auditada';
    END IF;

    EXECUTE format('DROP TRIGGER IF EXISTS trg_audit ON %s', p_table);
    EXECUTE format(
        'CREATE TRIGGER trg_audit
             AFTER INSERT OR UPDATE OR DELETE ON %s
             FOR EACH ROW EXECUTE FUNCTION util.trg_audit(%s)',
        p_table,
        (SELECT string_agg(quote_literal(c), ', ') FROM unnest(p_ignored_columns) AS c)
    );
END;
$$;

COMMENT ON FUNCTION util.enable_audit(REGCLASS, TEXT[])
IS 'Ativa a auditoria da tabela em util.audit_log, opcionalmente ignorando colunas';


CREATE OR REPLACE FUNCTION util.disable_audit(p_table REGCLASS)
RETURNS VOID
LANGUAGE plpgsql
VOLATILE
AS $$
BEGIN
    EXECUTE format('DROP TRIGGER IF EXISTS trg_audit ON %s', p_table);
END;
$$;

COMMENT ON FUNCTION util.disable_audit(REGCLASS)
IS 'Desativa a auditoria da tabela (o histórico em util.audit_log é mantido)';
