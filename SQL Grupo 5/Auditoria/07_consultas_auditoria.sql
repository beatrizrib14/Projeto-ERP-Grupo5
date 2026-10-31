-- Projeto Integrador — Modelagem de Dados | Grupo 5 | UNICID
-- 07 — CONSULTAS DE AUDITORIA (verificam qualidade e consistência dos dados)
-- Convenção: cada consulta devolve as linhas QUE MERECEM VERIFICAÇÃO. "0 linhas" = nenhuma inconsistência.
-- Exceção: A03 e A20 são informativas (listam situações esperadas de acompanhamento).
SET client_encoding='UTF8';

\echo '=== A01 | Orçamentos APROVADOS sem ordem de serviço (aprovação sem execução)'
SELECT o.id_orcamento, o.id_solicitacao, o.versao FROM orcamento o
 WHERE o.situacao='APROVADO' AND NOT EXISTS (SELECT 1 FROM ordem_servico os WHERE os.id_orcamento=o.id_orcamento);

\echo '=== A02 | Ordens de serviço sem itens ou sem as duas parcelas a receber (ENTRADA e FINAL)'
SELECT os.id_os,
       (SELECT COUNT(*) FROM item_ordem_servico i WHERE i.id_os=os.id_os) AS itens,
       (SELECT COUNT(*) FROM conta_a_receber c WHERE c.id_os=os.id_os)    AS parcelas
  FROM ordem_servico os
 WHERE NOT EXISTS (SELECT 1 FROM item_ordem_servico i WHERE i.id_os=os.id_os)
    OR (SELECT COUNT(*) FROM conta_a_receber c WHERE c.id_os=os.id_os) <> 2;

\echo '=== A03 | (informativa) Contas a pagar vencidas e não quitadas em 2026-10-30'
SELECT cp.id_conta_pagar, cp.origem_tipo, cp.descricao, cp.valor_origem, cp.data_vencimento, cp.situacao
  FROM conta_a_pagar cp
 WHERE cp.data_vencimento < DATE '2026-10-30'
   AND cp.valor_origem > COALESCE((SELECT SUM(valor_pago) FROM pagamento p WHERE p.id_conta_pagar=cp.id_conta_pagar),0);

\echo '=== A04 | Ordens de serviço com informações incompletas ou datas fora de ordem'
SELECT id_os, situacao, data_abertura, data_execucao, data_finalizacao, data_conclusao
  FROM ordem_servico
 WHERE data_abertura IS NULL
    OR (situacao='CONCLUÍDA' AND (data_execucao IS NULL OR data_finalizacao IS NULL OR data_conclusao IS NULL))
    OR data_execucao < data_abertura OR data_finalizacao < data_execucao OR data_conclusao < data_finalizacao;

\echo '=== A05 | Movimentações financeiras sem origem válida (nem recebimento, nem pagamento, nem reserva)'
SELECT m.id_mov_fin, m.tipo, m.valor FROM movimentacao_financeira m
 WHERE m.id_recebimento IS NULL AND m.id_pagamento IS NULL
   AND NOT EXISTS (SELECT 1 FROM movimentacao_reserva r WHERE r.id_mov_fin = m.id_mov_fin);

\echo '=== A06 | Movimentações de estoque sem origem válida (entrada sem item recebido / saída sem OS)'
SELECT id_mov_estoque, tipo, id_item_receb, id_os FROM movimentacao_estoque
 WHERE (tipo='ENTRADA' AND id_item_receb IS NULL) OR (tipo='SAÍDA' AND id_os IS NULL)
    OR (id_item_receb IS NOT NULL AND id_os IS NOT NULL);

\echo '=== A07 | Valor da movimentação financeira diferente de valor_pago + multa + juros'
SELECT m.id_mov_fin, m.valor AS valor_mov, x.total AS valor_evento
  FROM movimentacao_financeira m
  JOIN (SELECT id_recebimento AS id_rec, NULL::int AS id_pag, valor_pago+multa+juros AS total FROM recebimento
        UNION ALL SELECT NULL, id_pagamento, valor_pago+multa+juros FROM pagamento) x
    ON (m.id_recebimento = x.id_rec OR m.id_pagamento = x.id_pag)
 WHERE m.valor <> x.total;

\echo '=== A08 | Pagamentos/recebimentos sem movimentação financeira correspondente (1:1)'
SELECT 'RECEBIMENTO' AS tipo, r.id_recebimento AS id FROM recebimento r
 WHERE NOT EXISTS (SELECT 1 FROM movimentacao_financeira m WHERE m.id_recebimento=r.id_recebimento)
UNION ALL
SELECT 'PAGAMENTO', p.id_pagamento FROM pagamento p
 WHERE NOT EXISTS (SELECT 1 FROM movimentacao_financeira m WHERE m.id_pagamento=p.id_pagamento);

\echo '=== A09 | Saldo armazenado da conta financeira diferente do saldo calculado pelas movimentações'
SELECT cf.id_conta_fin, cf.nome, cf.saldo_atual AS armazenado,
       COALESCE(SUM(CASE WHEN m.tipo='ENTRADA' THEN m.valor ELSE -m.valor END),0) AS calculado
  FROM conta_financeira cf LEFT JOIN movimentacao_financeira m USING (id_conta_fin)
 GROUP BY cf.id_conta_fin, cf.nome, cf.saldo_atual
HAVING cf.saldo_atual <> COALESCE(SUM(CASE WHEN m.tipo='ENTRADA' THEN m.valor ELSE -m.valor END),0);

\echo '=== A10 | Saldo de estoque negativo (saída maior que as entradas acumuladas)'
SELECT m.id_material, m.descricao,
       SUM(CASE WHEN e.tipo='ENTRADA' THEN e.quantidade ELSE -e.quantidade END) AS saldo
  FROM material m JOIN movimentacao_estoque e USING (id_material)
 GROUP BY m.id_material, m.descricao
HAVING SUM(CASE WHEN e.tipo='ENTRADA' THEN e.quantidade ELSE -e.quantidade END) < 0;

\echo '=== A11 | Quantidade recebida maior que a quantidade pedida (entregas parciais acima do pedido)'
SELECT ip.id_item_pedido, ip.quantidade AS pedida, SUM(ir.qtd_recebida) AS recebida
  FROM item_pedido ip JOIN item_recebimento ir USING (id_item_pedido)
 GROUP BY ip.id_item_pedido, ip.quantidade HAVING SUM(ir.qtd_recebida) > ip.quantidade;

\echo '=== A12 | Duplicidades: CPF/CNPJ (apenas dígitos) e número de série repetidos'
SELECT 'CLIENTE' AS tabela, regexp_replace(cpf_cnpj,'\D','','g') AS chave, COUNT(*) FROM cliente GROUP BY 2 HAVING COUNT(*)>1
UNION ALL SELECT 'TERCEIRIZADA', regexp_replace(cnpj,'\D','','g'), COUNT(*) FROM terceirizada GROUP BY 2 HAVING COUNT(*)>1
UNION ALL SELECT 'FORNECEDOR', regexp_replace(cnpj,'\D','','g'), COUNT(*) FROM fornecedor GROUP BY 2 HAVING COUNT(*)>1
UNION ALL SELECT 'MÁQUINA', upper(trim(num_serie)), COUNT(*) FROM maquina GROUP BY 2 HAVING COUNT(*)>1
UNION ALL SELECT 'RECEBIMENTO_COMPRA (nota fiscal)', upper(trim(nota_fiscal)), COUNT(*) FROM recebimento_compra GROUP BY 2 HAVING COUNT(*)>1;

\echo '=== A13 | Orçamento com valor_total diferente da soma dos itens (CR3)'
SELECT o.id_orcamento, o.valor_total, SUM(i.quantidade*i.valor_unitario) AS soma_itens
  FROM orcamento o JOIN item_orcamento i USING (id_orcamento)
 GROUP BY o.id_orcamento, o.valor_total HAVING o.valor_total <> SUM(i.quantidade*i.valor_unitario);

\echo '=== A14 | Item de OS com valor_total diferente de quantidade × valor_unitario (H4)'
SELECT id_item_os, quantidade, valor_unitario, valor_total FROM item_ordem_servico
 WHERE valor_total <> quantidade*valor_unitario;

\echo '=== A15 | Pedido de compra com valor_total diferente da soma dos itens (CR3)'
SELECT p.id_pedido, p.valor_total, SUM(i.quantidade*i.valor_unitario) AS soma_itens
  FROM pedido_compra p JOIN item_pedido i USING (id_pedido)
 GROUP BY p.id_pedido, p.valor_total HAVING p.valor_total <> SUM(i.quantidade*i.valor_unitario);

\echo '=== A16 | Máquina da OS diferente da máquina da solicitação do orçamento (CR2) ou da inspeção vinculada (H7)'
SELECT os.id_os, os.id_maquina AS maq_os, s.id_maquina AS maq_solicitacao
  FROM ordem_servico os JOIN orcamento o USING (id_orcamento) JOIN solicitacao s ON s.id_solicitacao=o.id_solicitacao
 WHERE os.id_maquina <> s.id_maquina
UNION ALL
SELECT i.id_inspecao, i.id_maquina, os.id_maquina FROM inspecao i JOIN ordem_servico os USING (id_os)
 WHERE i.id_maquina <> os.id_maquina;

\echo '=== A17 | Conta a pagar: valor_origem diferente do valor do documento de origem (F2) e origem COMPRA sem pedido'
SELECT cp.id_conta_pagar, cp.origem_tipo, cp.valor_origem
  FROM conta_a_pagar cp
  LEFT JOIN folha_pagamento f ON f.id_folha=cp.id_folha
  LEFT JOIN contratacao c ON c.id_contratacao=cp.id_contratacao
  LEFT JOIN imposto i ON i.id_imposto=cp.id_imposto
  LEFT JOIN despesa d ON d.id_despesa=cp.id_despesa
 WHERE (cp.origem_tipo='FOLHA' AND cp.valor_origem <> f.salario_liquido)
    OR (cp.origem_tipo='CONTRATAÇÃO' AND cp.valor_origem <> c.valor_contratado)
    OR (cp.origem_tipo='IMPOSTO' AND cp.valor_origem <> i.valor)
    OR (cp.origem_tipo='DESPESA' AND cp.valor_origem <> d.valor)
    OR (cp.origem_tipo='COMPRA' AND NOT EXISTS (SELECT 1 FROM pedido_compra p WHERE p.id_conta_pagar=cp.id_conta_pagar));

\echo '=== A18 | Situação PAGA/ABERTA incoerente com os pagamentos e recebimentos registrados'
SELECT 'PAGAR' AS natureza, cp.id_conta_pagar AS id, cp.situacao, cp.valor_origem AS valor, COALESCE(p.pago,0) AS quitado
  FROM conta_a_pagar cp LEFT JOIN (SELECT id_conta_pagar, SUM(valor_pago) pago FROM pagamento GROUP BY 1) p USING (id_conta_pagar)
 WHERE (cp.situacao='PAGA' AND COALESCE(p.pago,0) < cp.valor_origem) OR (cp.situacao<>'PAGA' AND COALESCE(p.pago,0) >= cp.valor_origem)
UNION ALL
SELECT 'RECEBER', cr.id_conta_receber, cr.situacao, cr.valor, COALESCE(r.pago,0)
  FROM conta_a_receber cr LEFT JOIN (SELECT id_conta_receber, SUM(valor_pago) pago FROM recebimento GROUP BY 1) r USING (id_conta_receber)
 WHERE (cr.situacao='PAGA' AND COALESCE(r.pago,0) < cr.valor) OR (cr.situacao='ABERTA' AND COALESCE(r.pago,0) > 0)
    OR (cr.situacao<>'PAGA' AND COALESCE(r.pago,0) >= cr.valor);

\echo '=== A19 | Contratação de cotação não aprovada, ou valor contratado diferente do proposto'
SELECT ct.id_contratacao, c.situacao AS situacao_cotacao, c.valor_proposto, ct.valor_contratado
  FROM contratacao ct JOIN cotacao c USING (id_cotacao)
 WHERE c.situacao IS DISTINCT FROM 'APROVADA' OR ct.valor_contratado <> c.valor_proposto;

\echo '=== A20 | (informativa) Solicitações com mais de uma versão de orçamento APROVADA (P20) e histórico de versões'
SELECT id_solicitacao, COUNT(*) AS versoes, COUNT(*) FILTER (WHERE situacao='APROVADO') AS aprovadas,
       string_agg('v'||versao||':'||COALESCE(situacao,'aguardando'), ' → ' ORDER BY versao) AS historico
  FROM orcamento GROUP BY id_solicitacao HAVING COUNT(*) > 1 OR COUNT(*) FILTER (WHERE situacao='APROVADO') > 1
 ORDER BY id_solicitacao;

\echo '=== A21 | Chaves estrangeiras não validadas (integridade referencial, via catálogo)'
-- Lista FKs não validadas (criadas NOT VALID ou desabilitadas); com as 51 FKs validadas retorna 0.
SELECT conrelid::regclass AS tabela, conname FROM pg_constraint WHERE contype='f' AND NOT convalidated;
