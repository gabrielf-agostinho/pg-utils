-- =====================================================
-- Tabela: util.audit_log
--
-- Objetivo:
--   Armazenar o histórico de alterações das tabelas
--   auditadas via util.enable_audit.
--
-- Observação:
--   changed_by usa a configuração util.audit_user,
--   permitindo que a aplicação informe o usuário real:
--     SET LOCAL util.audit_user = 'joao@empresa.com';
--   Sem ela, usa o usuário do banco (current_user).
-- =====================================================

CREATE TABLE IF NOT EXISTS util.audit_log (
    id             BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    table_schema   TEXT        NOT NULL,
    table_name     TEXT        NOT NULL,
    operation      TEXT        NOT NULL
        CHECK (operation IN ('INSERT', 'UPDATE', 'DELETE')),
    old_data       JSONB,
    new_data       JSONB,
    changed_fields JSONB,
    changed_by     TEXT        NOT NULL
        DEFAULT COALESCE(NULLIF(current_setting('util.audit_user', true), ''), current_user),
    changed_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
    transaction_id BIGINT      NOT NULL DEFAULT txid_current()
);

CREATE INDEX IF NOT EXISTS audit_log_table_idx
    ON util.audit_log (table_schema, table_name, changed_at);

COMMENT ON TABLE util.audit_log IS 'Histórico de alterações das tabelas auditadas';
COMMENT ON COLUMN util.audit_log.old_data IS 'Registro antes da alteração (UPDATE/DELETE)';
COMMENT ON COLUMN util.audit_log.new_data IS 'Registro após a alteração (INSERT/UPDATE)';
COMMENT ON COLUMN util.audit_log.changed_fields IS 'Somente os campos alterados (UPDATE), via util.jsonb_diff';
COMMENT ON COLUMN util.audit_log.changed_by IS 'util.audit_user, se definido, ou o usuário do banco';
