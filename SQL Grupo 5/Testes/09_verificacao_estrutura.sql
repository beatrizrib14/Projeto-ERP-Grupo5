-- Projeto Integrador — Modelagem de Dados | Grupo 5 | UNICID
-- 09 — VERIFICAÇÃO DA ESTRUTURA CRIADA (compara o banco com o modelo lógico: 35 tabelas, 229 colunas, 51 FKs)
SET client_encoding='UTF8';
\echo '=== V01 Contagens do catálogo'
SELECT (SELECT COUNT(*) FROM information_schema.tables  WHERE table_schema='public' AND table_type='BASE TABLE') AS tabelas,
       (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema='public') AS colunas,
       (SELECT COUNT(*) FROM pg_constraint c JOIN pg_namespace n ON n.oid=c.connamespace WHERE n.nspname='public' AND c.contype='p') AS pks,
       (SELECT COUNT(*) FROM pg_constraint c JOIN pg_namespace n ON n.oid=c.connamespace WHERE n.nspname='public' AND c.contype='f') AS fks,
       (SELECT COUNT(*) FROM pg_constraint c JOIN pg_namespace n ON n.oid=c.connamespace WHERE n.nspname='public' AND c.contype='u') AS uniques,
       (SELECT COUNT(*) FROM pg_constraint c JOIN pg_namespace n ON n.oid=c.connamespace WHERE n.nspname='public' AND c.contype='c') AS checks,
       (SELECT COUNT(*) FROM pg_trigger t JOIN pg_class c ON c.oid=t.tgrelid JOIN pg_namespace n ON n.oid=c.relnamespace WHERE n.nspname='public' AND NOT t.tgisinternal) AS gatilhos;
\echo '=== V02 Regras de exclusão/atualização das FKs (esperado: apenas RESTRICT/CASCADE)'
SELECT confdeltype AS on_delete, confupdtype AS on_update, COUNT(*) AS fks FROM pg_constraint WHERE contype='f' GROUP BY 1,2;
\echo '=== V03 Linhas por tabela (massa de teste carregada)'
SELECT table_name AS tabela,
       (xpath('/row/c/text()', query_to_xml(format('select count(*) as c from %I', table_name), false, true, '')))[1]::text::int AS linhas
  FROM information_schema.tables WHERE table_schema='public' AND table_type='BASE TABLE' ORDER BY 1;
