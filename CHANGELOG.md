# Changelog

## 0.2.0

### Estrutura
- Funções organizadas por domínio em `src/functions/<domínio>/`
- `build.sh` movido para `scripts/`, com ordem de instalação explícita, `ON_ERROR_STOP` e instalação em uma única transação
- Arquivo `VERSION` adicionado; a versão instalada fica no comentário do schema `util`
- Testes automatizados em `tests/` (`scripts/test.sh`) e CI para PostgreSQL 14 a 18
- `.gitattributes` força LF (o `build.sh` com CRLF não rodava em Linux)

### Correções
- `normalize_text` era `IMMUTABLE` mas chamava `unaccent` (`STABLE`, depende do `search_path`); agora usa `util.unaccent`, que é de fato `IMMUTABLE` e pode ser usado em índices
- `table_exists` usava `information_schema`, que oculta tabelas sem privilégio para o usuário atual; agora consulta `pg_catalog`
- `business_days_between` reescrita sem loop (uma consulta só)
- `jsonb_diff` não falha mais com valores que não são objetos
- Seed de feriados não tem mais o ano fixo no código: gera 2000–2100 e inclui o Dia da Consciência Negra (nacional desde 2024)
- `009_jsonb_diff.sql.sql` renomeado (extensão duplicada)

### Novas funções
- **text**: `unaccent`, `slugify`, `only_digits`, `truncate_text`, `is_valid_email`, `random_string`
- **numeric**: `percentage`, `clamp`
- **br**: `is_valid_cpf`, `is_valid_cnpj` (inclui CNPJ alfanumérico), `format_cpf`, `format_cnpj`
- **dates**: `holidays_br`, `generate_holidays_br`, `is_business_day`, `add_business_days`, `first_day_of_month`, `last_day_of_month`, `age_in_years`
- **json**: `jsonb_deep_merge`
- **metadata**: `column_exists`, `table_sizes`, `reset_sequence`, `reset_all_sequences`
- **triggers**: `trg_set_updated_at` / `add_updated_at_trigger`, `trg_audit` / `enable_audit` / `disable_audit` e a tabela `util.audit_log`

### Compatibilidade
- Nomes e assinaturas das funções existentes foram mantidos: `install.sql` pode ser executado sobre uma instalação 0.1 sem perda de dados.
