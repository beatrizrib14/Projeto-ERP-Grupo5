-- Projeto Integrador — Modelagem de Dados | Grupo 5 | UNICID
-- 05 — SELECT, JOIN, UPDATE e DELETE (demonstração do CRUD sobre a massa de teste)
-- Tudo roda dentro de uma transação revertida (ROLLBACK): a massa de dados não é alterada.
SET client_encoding='UTF8';
\echo '=== D01 SELECT + JOIN: ordens de serviço com cliente, máquina e responsável'
SELECT os.id_os, c.razao_nome AS cliente, m.num_serie, f.nome AS responsavel, os.situacao
  FROM ordem_servico os
  JOIN maquina m     ON m.id_maquina = os.id_maquina
  JOIN cliente c     ON c.id_cliente = m.id_cliente
  JOIN funcionario f ON f.id_funcionario = os.id_funcionario
 ORDER BY os.id_os;

BEGIN;
\echo '=== D02 INSERT: nova solicitação'
INSERT INTO solicitacao (id_cliente,id_maquina,id_funcionario,problema_descrito,data_solicitacao,status)
VALUES (5,7,2,'TESTE: solicitação criada pelo script de demonstração','2026-10-30','AGUARDANDO ORÇAMENTO')
RETURNING id_solicitacao, status;

\echo '=== D03 UPDATE: avança o status da solicitação criada'
UPDATE solicitacao SET status = 'EM ANDAMENTO'
 WHERE problema_descrito LIKE 'TESTE: solicitação criada%'
RETURNING id_solicitacao, status;

\echo '=== D04 UPDATE: recalcula o saldo das contas financeiras a partir das movimentações (CR3)'
UPDATE conta_financeira cf
   SET saldo_atual = COALESCE((SELECT SUM(CASE WHEN m.tipo='ENTRADA' THEN m.valor ELSE -m.valor END)
                                 FROM movimentacao_financeira m WHERE m.id_conta_fin = cf.id_conta_fin),0)
RETURNING id_conta_fin, nome, saldo_atual;

\echo '=== D05 DELETE: remove a solicitação criada (sem dependentes)'
DELETE FROM solicitacao WHERE problema_descrito LIKE 'TESTE: solicitação criada%'
RETURNING id_solicitacao;
ROLLBACK;
\echo '=== D06 Estado após ROLLBACK: solicitações cadastradas'
SELECT COUNT(*) AS total_solicitacoes FROM solicitacao;
