-- =====================================================
-- Instalação das funções utilitárias
-- =====================================================

-- Criação do schema util
CREATE SCHEMA IF NOT EXISTS util;
COMMENT ON SCHEMA util IS 'Funções utilitárias reutilizáveis';

-- Funções
\i functions/coalesce_empty.sql
\i functions/safe_divide.sql
\i functions/normalize_text.sql