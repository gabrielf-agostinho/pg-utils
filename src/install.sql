-- =====================================================
-- Instalação das funções utilitárias
-- =====================================================

-- Criação do schema util
CREATE SCHEMA IF NOT EXISTS util;
COMMENT ON SCHEMA util IS 'Funções utilitárias reutilizáveis';

-- Tabelas
\i tables/holidays.sql

-- Funções
\i functions/table_exists.sql
\i functions/coalesce_empty.sql
\i functions/safe_divide.sql
\i functions/normalize_text.sql
\i functions/easter_date.sql
\i functions/generate_movable_holidays_br.sql
\i functions/business_days_between.sql
\i functions/jsonb_diff.sql

-- Seeds
\i seeds/holidays.sql