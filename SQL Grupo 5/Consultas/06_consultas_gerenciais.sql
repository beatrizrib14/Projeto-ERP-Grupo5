-- Projeto Integrador — Modelagem de Dados | Grupo 5 | UNICID
-- 06 — CONSULTAS GERENCIAIS (cada uma responde a uma pergunta de negócio)
SET client_encoding='UTF8';

\echo '=== G01 | Quantas ordens de serviço foram abertas por mês?'
-- Objetivo: medir o volume de trabalho aberto por período.
SELECT to_char(data_abertura,'YYYY-MM') AS mes, COUNT(*) AS os_abertas
  FROM ordem_servico GROUP BY 1 ORDER BY 1;

\echo '=== G02 | Quais ordens de serviço estão em andamento e há quantos dias?'
-- Objetivo: priorizar a fila de execução/revisão (data de referência 2026-10-30).
SELECT os.id_os, c.razao_nome AS cliente, m.num_serie, os.situacao,
       DATE '2026-10-30' - os.data_abertura AS dias_desde_abertura
  FROM ordem_servico os JOIN maquina m USING (id_maquina) JOIN cliente c USING (id_cliente)
 WHERE os.situacao IN ('EM EXECUÇÃO','EM REVISÃO')
 ORDER BY dias_desde_abertura DESC;

\echo '=== G03 | Quais serviços são mais executados e quanto faturam?'
-- Objetivo: identificar os serviços de maior demanda e receita (valor praticado nos itens da OS).
SELECT s.nome, SUM(i.quantidade) AS qtd_executada, SUM(i.valor_total) AS valor_total
  FROM item_ordem_servico i JOIN servico s USING (id_servico)
 GROUP BY s.nome ORDER BY qtd_executada DESC, valor_total DESC;

\echo '=== G04 | Quais máquinas têm maior recorrência de manutenção?'
-- Objetivo: apoiar a manutenção preventiva (solicitações + ordens por máquina).
SELECT m.num_serie, c.razao_nome AS cliente,
       COUNT(DISTINCT s.id_solicitacao) AS solicitacoes, COUNT(DISTINCT os.id_os) AS ordens_servico
  FROM maquina m JOIN cliente c USING (id_cliente)
  LEFT JOIN solicitacao s ON s.id_maquina = m.id_maquina
  LEFT JOIN ordem_servico os ON os.id_maquina = m.id_maquina
 GROUP BY m.num_serie, c.razao_nome
HAVING COUNT(DISTINCT s.id_solicitacao) > 0
 ORDER BY solicitacoes DESC, ordens_servico DESC, m.num_serie;

\echo '=== G05 | Quais clientes mais solicitam serviços e quantos orçamentos aprovaram?'
-- Objetivo: reconhecer clientes estratégicos e a taxa de aprovação.
SELECT c.razao_nome AS cliente, COUNT(DISTINCT s.id_solicitacao) AS solicitacoes,
       COUNT(DISTINCT o.id_orcamento) FILTER (WHERE o.situacao='APROVADO') AS orcamentos_aprovados
  FROM cliente c JOIN solicitacao s USING (id_cliente)
  LEFT JOIN orcamento o ON o.id_solicitacao = s.id_solicitacao
 GROUP BY c.razao_nome ORDER BY solicitacoes DESC, c.razao_nome;

\echo '=== G06 | Quais materiais estão com estoque abaixo do mínimo?'
-- Objetivo: orientar compras. Saldo calculado pelas movimentações (não existe saldo armazenado em MATERIAL).
SELECT m.descricao, m.unidade, m.estoque_minimo,
       COALESCE(SUM(CASE WHEN e.tipo='ENTRADA' THEN e.quantidade ELSE -e.quantidade END),0) AS saldo
  FROM material m LEFT JOIN movimentacao_estoque e USING (id_material)
 GROUP BY m.id_material, m.descricao, m.unidade, m.estoque_minimo
HAVING COALESCE(SUM(CASE WHEN e.tipo='ENTRADA' THEN e.quantidade ELSE -e.quantidade END),0) < m.estoque_minimo
 ORDER BY m.descricao;

\echo '=== G07 | Quanto foi comprado por mês e de quais fornecedores?'
-- Objetivo: acompanhar o volume de compras por período.
SELECT to_char(p.data_pedido,'YYYY-MM') AS mes, f.razao_social AS fornecedor,
       COUNT(*) AS pedidos, SUM(p.valor_total) AS valor_comprado
  FROM pedido_compra p JOIN fornecedor f USING (id_fornecedor)
 GROUP BY 1,2 ORDER BY 1,2;

\echo '=== G08 | Quanto se gasta por categoria de despesa administrativa?'
-- Objetivo: controlar despesas fixas e operacionais (aluguel, energia, internet, transporte).
SELECT categoria, COUNT(*) AS lancamentos, SUM(valor) AS total
  FROM despesa GROUP BY categoria ORDER BY total DESC;

\echo '=== G09 | Quanto há a pagar e a receber em aberto?'
-- Objetivo: planejar o caixa. Saldo = valor da conta − pagamentos/recebimentos registrados.
SELECT 'A RECEBER' AS natureza, COUNT(*) AS contas,
       SUM(cr.valor - COALESCE(r.pago,0)) AS saldo_em_aberto
  FROM conta_a_receber cr
  LEFT JOIN (SELECT id_conta_receber, SUM(valor_pago) pago FROM recebimento GROUP BY 1) r USING (id_conta_receber)
 WHERE cr.valor - COALESCE(r.pago,0) > 0
UNION ALL
SELECT 'A PAGAR', COUNT(*), SUM(cp.valor_origem - COALESCE(p.pago,0))
  FROM conta_a_pagar cp
  LEFT JOIN (SELECT id_conta_pagar, SUM(valor_pago) pago FROM pagamento GROUP BY 1) p USING (id_conta_pagar)
 WHERE cp.valor_origem - COALESCE(p.pago,0) > 0;

\echo '=== G10 | Quanto foi recebido e pago por mês (movimentações efetivadas)?'
-- Objetivo: acompanhar entradas e saídas realizadas, separando pagamento/recebimento de contas previstas.
SELECT to_char(m.data,'YYYY-MM') AS mes,
       SUM(m.valor) FILTER (WHERE m.id_recebimento IS NOT NULL) AS recebido,
       SUM(m.valor) FILTER (WHERE m.id_pagamento IS NOT NULL)   AS pago
  FROM movimentacao_financeira m
 WHERE m.id_recebimento IS NOT NULL OR m.id_pagamento IS NOT NULL
 GROUP BY 1 ORDER BY 1;

\echo '=== G11 | Quanto foi contratado com cada terceirizada?'
-- Objetivo: acompanhar a dependência de terceirizadas (cotação aprovada → contratação).
SELECT t.razao_social AS terceirizada, COUNT(*) AS contratacoes,
       SUM(ct.valor_contratado) AS valor_contratado
  FROM contratacao ct JOIN cotacao c USING (id_cotacao) JOIN terceirizada t USING (id_terceirizada)
 GROUP BY t.razao_social ORDER BY valor_contratado DESC;

\echo '=== G12 | Qual o desempenho financeiro por mês (entradas, saídas e resultado)?'
-- Objetivo: resultado de caixa mensal considerando apenas recebimentos e pagamentos (exclui reserva de emergência).
SELECT to_char(data,'YYYY-MM') AS mes,
       SUM(valor) FILTER (WHERE tipo='ENTRADA') AS entradas,
       SUM(valor) FILTER (WHERE tipo='SAÍDA')   AS saidas,
       SUM(CASE WHEN tipo='ENTRADA' THEN valor ELSE -valor END) AS resultado
  FROM movimentacao_financeira
 WHERE id_recebimento IS NOT NULL OR id_pagamento IS NOT NULL
 GROUP BY 1 ORDER BY 1;

\echo '=== G13 | Qual o fluxo financeiro vinculado a cada OS? (rastreabilidade pedida na devolutiva)'
-- Objetivo: ligar OS → contas a receber → recebimentos, e OS → cotação → contratação → conta a pagar → pagamentos.
SELECT os.id_os,
       COALESCE(rc.a_receber,0) AS a_receber, COALESCE(rc.recebido,0) AS recebido,
       COALESCE(pg.contratado,0) AS contratado_terceirizada, COALESCE(pg.pago,0) AS pago_terceirizada
  FROM ordem_servico os
  LEFT JOIN (SELECT cr.id_os, SUM(cr.valor) a_receber, SUM(r.pago) recebido
               FROM conta_a_receber cr
               LEFT JOIN (SELECT id_conta_receber, SUM(valor_pago) pago FROM recebimento GROUP BY 1) r USING (id_conta_receber)
              GROUP BY cr.id_os) rc ON rc.id_os = os.id_os
  LEFT JOIN (SELECT c.id_os, SUM(ct.valor_contratado) contratado, SUM(p.pago) pago
               FROM contratacao ct JOIN cotacao c USING (id_cotacao)
               JOIN conta_a_pagar cp ON cp.id_contratacao = ct.id_contratacao
               LEFT JOIN (SELECT id_conta_pagar, SUM(valor_pago) pago FROM pagamento GROUP BY 1) p USING (id_conta_pagar)
              GROUP BY c.id_os) pg ON pg.id_os = os.id_os
 ORDER BY os.id_os;
