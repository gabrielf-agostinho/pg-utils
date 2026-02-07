# pg-utils

Biblioteca de utilitários para PostgreSQL, composta por **funções, procedures e helpers SQL/PLpgSQL** voltados a facilitar operações comuns de banco de dados que o PostgreSQL não cobre nativamente ou cobre de forma verbosa.

O foco do projeto é **produtividade**, **clareza** e **reutilização**, sem dependência de linguagens externas, ORMs ou pacotes de terceiros.


## Objetivo

O `pg-utils` existe para centralizar funções utilitárias que normalmente acabam sendo reescritas em múltiplos projetos, como:

- Manipulação e inspeção de metadados
- Operações auxiliares em schemas, tabelas e colunas
- Funções genéricas reutilizáveis
- Abstrações simples para tarefas repetitivas em SQL

Tudo isso **diretamente no PostgreSQL**.

## Estrutura do Projeto

```text
📦pg-utils
 ┣ 📂src
 ┃ ┣ 📂extensions
 ┃ ┃ ┗ 📜001_unaccent.sql
 ┃ ┣ 📂functions
 ┃ ┃ ┣ 📜001_table_exists.sql
 ┃ ┃ ┣ 📜002_coalesce_empty.sql
 ┃ ┃ ┣ 📜003_normalize_text.sql
 ┃ ┃ ┣ 📜004_safe_divide.sql
 ┃ ┃ ┣ 📜006_easter_date.sql
 ┃ ┃ ┣ 📜007_generate_movable_holidays_br.sql
 ┃ ┃ ┣ 📜008_business_days_between.sql
 ┃ ┃ ┗ 📜009_jsonb_diff.sql.sql
 ┃ ┣ 📂schemas
 ┃ ┃ ┗ 📜001_util.sql
 ┃ ┣ 📂scripts
 ┃ ┃ ┗ 📜build.sh
 ┃ ┣ 📂seeds
 ┃ ┃ ┗ 📜001_holidays.sql
 ┃ ┗ 📂tables
 ┃ ┃ ┗ 📜001_holidays.sql
 ┣ 📜.gitignore
 ┣ 📜LICENSE
 ┗ 📜README.md
 ```

 ## Instalação
 
 Clone o repositório:

 ```bash
 git clone https://github.com/gabrielf-agostinho/pg-utils.git
 ```

 Faça a build do script de instalação
 
 ```bash
 ./src/scripts/build.sh
 ```

 Execute o script SQL no seu banco PostgreSQL:
 
 ```bash
 \i install.sql
 ```

 ## Uso
Após a instalação, as funções ficam disponíveis no schema configurado (ex.: util).

Exemplo genérico de chamada:

```sql
 SELECT util.nome_da_funcao(param1, param2);
 ```

 Consulte os arquivos SQL para entender parâmetros, retornos e exemplos de uso de cada função.

 ## Filosofia
* ✅ SQL puro / PLpgSQL

* ❌ Sem dependência de aplicação

* ❌ Sem camada de conexão

* ❌ Sem pacotes externos

* 🧩 Funções pequenas, claras e reutilizáveis

* 📦 Foco em utilidade real no dia a dia

## Observações
* Algumas funções podem assumir versões específicas do PostgreSQL

* Recomenda-se revisar o código antes de uso em produção

* Ideal para ambientes de desenvolvimento, scripts administrativos ou bases utilitárias

## Contribuição

Contribuições são bem-vindas, especialmente funções que:

* Resolvam problemas recorrentes

* Não dependam de extensões externas

* Sejam genéricas o suficiente para múltiplos projetos

Fluxo sugerido:

1) Fork do repositório

2) Crie uma branch (feature/minha-funcao)

3) Commit claro e objetivo

4) Pull Request

## Licença
Este projeto está sob a licença MIT.
Veja o arquivo `LICENSE` para mais detalhes.