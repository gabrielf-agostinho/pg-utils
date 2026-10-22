# pg-utils

Biblioteca de utilitários para PostgreSQL, composta por **funções, triggers e helpers SQL/PLpgSQL** voltados a facilitar operações comuns de banco de dados que o PostgreSQL não cobre nativamente ou cobre de forma verbosa.

O foco do projeto é **produtividade**, **clareza** e **reutilização**, sem dependência de linguagens externas, ORMs ou pacotes de terceiros.

## Objetivo

O `pg-utils` existe para centralizar funções utilitárias que normalmente acabam sendo reescritas em múltiplos projetos, como:

- Tratamento e normalização de texto
- Validação e formatação de documentos brasileiros (CPF/CNPJ)
- Cálculos com datas, feriados e dias úteis
- Manipulação de JSONB
- Inspeção de metadados e manutenção (tamanho de tabelas, sequences)
- Triggers prontas de `updated_at` e auditoria

Tudo isso **diretamente no PostgreSQL**, no schema `util`.

## Requisitos

- PostgreSQL **14 ou superior** (testado do 14 ao 18)
- Extensão `unaccent` (faz parte do contrib padrão do PostgreSQL)
- `psql` para instalar

## Instalação

```bash
git clone https://github.com/gabrielf-agostinho/pg-utils.git
cd pg-utils

# Gera build/install.sql
./scripts/build.sh

# Instala no banco
psql -d meu_banco -f build/install.sql
```

A instalação roda em uma única transação e é **idempotente**: pode ser executada novamente para atualizar a biblioteca sem perder dados das tabelas `util.holidays` e `util.audit_log`.

Para conferir a versão instalada:

```sql
SELECT obj_description('util'::regnamespace);  -- 'pg-utils 0.2.0'
```

Para remover tudo:

```sql
DROP SCHEMA util CASCADE;
```

## Funções

### Texto

| Função | Descrição | Exemplo |
|---|---|---|
| `coalesce_empty(text)` | Vazio ou só espaços → `NULL`; senão, aplica trim | `'  abc '` → `'abc'` |
| `unaccent(text)` | Remove acentos (`IMMUTABLE`, serve para índices) | `'Ação'` → `'Acao'` |
| `normalize_text(text)` | Minúsculo, sem acentos, sem símbolos, espaços normalizados | `' São Paulo/SP'` → `'sao paulo sp'` |
| `slugify(text, sep = '-')` | Slug para URLs | `'Olá, Mundo!'` → `'ola-mundo'` |
| `only_digits(text)` | Mantém apenas dígitos | `'(11) 98765-4321'` → `'11987654321'` |
| `truncate_text(text, max, suffix = '...')` | Trunca sem passar de `max` caracteres | `('PostgreSQL é ótimo', 10)` → `'Postgre...'` |
| `is_valid_email(text)` | Valida o formato de e-mail | `'a@b.com'` → `true` |
| `random_string(len, charset)` | String aleatória (não criptográfica) | `(6, '0123456789')` → `'402917'` |

### Numérico

| Função | Descrição | Exemplo |
|---|---|---|
| `safe_divide(a, b)` | Divisão que retorna `NULL` quando `b = 0` | `(10, 0)` → `NULL` |
| `percentage(part, total, scale = 2)` | Porcentagem segura | `(1, 3)` → `33.33` |
| `clamp(value, min, max)` | Restringe ao intervalo (limite `NULL` = sem limite) | `(15, 0, 10)` → `10` |

### Brasil

| Função | Descrição | Exemplo |
|---|---|---|
| `is_valid_cpf(text)` | Valida CPF com ou sem máscara | `'529.982.247-25'` → `true` |
| `is_valid_cnpj(text)` | Valida CNPJ numérico **ou alfanumérico** (IN RFB 2.229/2024) | `'12.ABC.345/01DE-35'` → `true` |
| `format_cpf(text)` | Aplica a máscara `000.000.000-00` | `'52998224725'` → `'529.982.247-25'` |
| `format_cnpj(text)` | Aplica a máscara `00.000.000/0000-00` | `'11222333000181'` → `'11.222.333/0001-81'` |

### Datas, feriados e dias úteis

| Função | Descrição |
|---|---|
| `easter_date(year)` | Data da Páscoa |
| `holidays_br(year)` | Lista os feriados nacionais do ano (sem gravar) |
| `generate_holidays_br(start_year, end_year = NULL)` | Insere os feriados nacionais em `util.holidays`; retorna quantos inseriu |
| `generate_movable_holidays_br(year)` | Insere só os feriados móveis |
| `is_business_day(date)` | Indica se a data é dia útil |
| `business_days_between(start, end)` | Quantidade de dias úteis no intervalo (inclusivo) |
| `add_business_days(date, n)` | Soma/subtrai dias úteis (`0` ajusta para o próximo dia útil) |
| `first_day_of_month(date)` / `last_day_of_month(date)` | Primeiro / último dia do mês |
| `age_in_years(birth, reference = CURRENT_DATE)` | Idade em anos completos |

As funções de dias úteis consideram fins de semana e **todos** os registros de `util.holidays`. A instalação já carrega os feriados nacionais de 2000 a 2100; feriados estaduais, municipais ou específicos da empresa podem ser adicionados na tabela:

```sql
INSERT INTO util.holidays (date, description, type)
VALUES ('2026-01-25', 'Aniversário de São Paulo', 'city');

SELECT util.add_business_days(CURRENT_DATE, 5);  -- prazo de 5 dias úteis
```

### JSON

| Função | Descrição | Exemplo |
|---|---|---|
| `jsonb_diff(old, new)` | Diferenças recursivas entre objetos | `('{"a":1,"b":2}', '{"a":1,"b":3}')` → `{"b": 3}` |
| `jsonb_deep_merge(left, right)` | Merge recursivo (o `\|\|` nativo substitui objetos aninhados) | `('{"a":{"x":1}}', '{"a":{"y":2}}')` → `{"a": {"x": 1, "y": 2}}` |

### Metadados e manutenção

| Função | Descrição |
|---|---|
| `table_exists(schema, table)` | Verifica se a tabela/view existe |
| `column_exists(schema, table, column)` | Verifica se a coluna existe |
| `table_sizes(schema = NULL)` | Tabelas com estimativa de linhas e tamanho em disco |
| `reset_sequence(table, column = 'id')` | Ajusta a sequence para `MAX(coluna) + 1` |
| `reset_all_sequences(schema = 'public')` | Ajusta todas as sequences do schema |

```sql
SELECT * FROM util.table_sizes('public') LIMIT 10;

-- Depois de importar dados com ids explícitos
SELECT * FROM util.reset_all_sequences('public');
```

### Triggers

**`updated_at` automático**, atualizado só quando o registro realmente muda:

```sql
SELECT util.add_updated_at_trigger('public.clientes');                 -- coluna updated_at
SELECT util.add_updated_at_trigger('public.pedidos', 'alterado_em');   -- outra coluna
```

**Auditoria** em `util.audit_log`, com os campos alterados calculados por `jsonb_diff`:

```sql
SELECT util.enable_audit('public.clientes');
SELECT util.enable_audit('public.usuarios', ARRAY['senha_hash', 'updated_at']);  -- colunas ignoradas

-- Opcional: informar o usuário da aplicação
SET LOCAL util.audit_user = 'joao@empresa.com';

SELECT operation, changed_fields, changed_by, changed_at
FROM util.audit_log
WHERE table_name = 'clientes'
ORDER BY changed_at DESC;

SELECT util.disable_audit('public.clientes');
```

`UPDATE`s sem mudança efetiva (ou que só alteram colunas ignoradas) não são registrados. O usuário que altera a tabela auditada precisa de permissão de `INSERT` em `util.audit_log`.

## Estrutura do Projeto

```text
📦pg-utils
 ┣ 📂scripts
 ┃ ┣ 📜build.sh          # gera build/install.sql
 ┃ ┗ 📜test.sh           # build + instalação + testes
 ┣ 📂src
 ┃ ┣ 📂schemas
 ┃ ┣ 📂extensions
 ┃ ┣ 📂tables            # holidays, audit_log
 ┃ ┣ 📂functions
 ┃ ┃ ┣ 📂text
 ┃ ┃ ┣ 📂numeric
 ┃ ┃ ┣ 📂br
 ┃ ┃ ┣ 📂dates
 ┃ ┃ ┣ 📂json
 ┃ ┃ ┣ 📂metadata
 ┃ ┃ ┗ 📂triggers
 ┃ ┗ 📂seeds
 ┣ 📂tests
 ┣ 📜CHANGELOG.md
 ┣ 📜VERSION
 ┗ 📜README.md
```

A ordem de instalação é definida em `SECTIONS`, no `scripts/build.sh`. Dentro de cada pasta, os arquivos são instalados pela numeração do nome. Funções `LANGUAGE sql` são validadas na criação, então uma função só pode depender de funções de pastas anteriores ou de arquivos com numeração menor.

## Testes

Os testes rodam dentro de uma transação desfeita ao final, mas a instalação é efetivada: use um banco descartável.

```bash
# Usando as variáveis padrão do libpq (PGHOST, PGUSER, PGDATABASE...)
./scripts/test.sh

# Usando Docker
docker run -d --name pg-utils-test -e POSTGRES_PASSWORD=postgres postgres:17
PSQL="docker exec -i pg-utils-test psql -U postgres" ./scripts/test.sh
```

O CI executa a mesma suíte do PostgreSQL 14 ao 18 a cada push e pull request.

## Filosofia

* ✅ SQL puro / PLpgSQL
* ✅ Volatilidade correta (`IMMUTABLE` / `STABLE` / `VOLATILE`) e `PARALLEL SAFE` sempre que possível
* ❌ Sem dependência de aplicação
* ❌ Sem camada de conexão
* ❌ Sem pacotes externos
* 🧩 Funções pequenas, claras e reutilizáveis
* 📦 Foco em utilidade real no dia a dia

## Contribuição

Contribuições são bem-vindas, especialmente funções que:

* Resolvam problemas recorrentes
* Não dependam de extensões fora do contrib padrão
* Sejam genéricas o suficiente para múltiplos projetos

Convenções:

* Um objeto por arquivo, em `src/functions/<domínio>/NNN_nome.sql`
* Cabeçalho com objetivo, regras e exemplos, mais `COMMENT ON FUNCTION`
* Parâmetros com prefixo `p_` e variáveis com prefixo `v_`
* Testes no arquivo do domínio em `tests/`

Fluxo sugerido:

1) Fork do repositório
2) Crie uma branch (`feature/minha-funcao`)
3) Commit claro e objetivo
4) Pull Request

## Licença

Este projeto está sob a licença MIT.
Veja o arquivo `LICENSE` para mais detalhes.
