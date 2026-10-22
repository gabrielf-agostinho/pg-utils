-- =====================================================
-- Função: util.unaccent
--
-- Objetivo:
--   Remover acentos de forma IMMUTABLE.
--
-- Motivo:
--   A função unaccent(text) da extensão é STABLE porque
--   localiza o dicionário pelo search_path, o que impede
--   seu uso em índices e colunas geradas. Este wrapper
--   fixa o schema da extensão no momento da instalação.
--
-- Exemplos:
--   util.unaccent('Ação Café')  -> 'Acao Cafe'
--
--   CREATE INDEX ON clientes (util.unaccent(lower(nome)));
-- =====================================================

DO $do$
DECLARE
    v_schema TEXT;
BEGIN
    SELECT n.nspname
      INTO v_schema
      FROM pg_catalog.pg_extension e
      JOIN pg_catalog.pg_namespace n ON n.oid = e.extnamespace
     WHERE e.extname = 'unaccent';

    IF v_schema IS NULL THEN
        RAISE EXCEPTION 'Extensão unaccent não encontrada';
    END IF;

    EXECUTE format(
        $f$
        CREATE OR REPLACE FUNCTION util.unaccent(value TEXT)
        RETURNS TEXT
        LANGUAGE sql
        IMMUTABLE
        STRICT
        PARALLEL SAFE
        AS $body$
            SELECT %1$I.unaccent(%2$L::regdictionary, value);
        $body$
        $f$,
        v_schema,
        format('%I.unaccent', v_schema)
    );
END;
$do$;

COMMENT ON FUNCTION util.unaccent(TEXT)
IS 'Remove acentos (versão IMMUTABLE de unaccent, utilizável em índices)';
