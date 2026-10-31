-- Projeto Integrador — Modelagem de Dados | Grupo 5 | UNICID
-- ERP de manutenção e reparo de máquinas extrusoras balão
-- SGBD: PostgreSQL 16 (UTF8)

-- 01 — CREATE DATABASE
-- Execute conectado ao banco 'postgres':  psql -U postgres -f 01_create_database.sql
DROP DATABASE IF EXISTS erp_extrusoras;
CREATE DATABASE erp_extrusoras
    ENCODING 'UTF8'
    TEMPLATE template0;
\connect erp_extrusoras
