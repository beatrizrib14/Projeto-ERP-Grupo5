-- Projeto Integrador — Modelagem de Dados | Grupo 5 | UNICID
-- 08 — TESTES DE RESTRIÇÕES (tentativas de violação que DEVEM ser rejeitadas) e testes de sensibilidade da auditoria
-- Cada teste executa dentro de um bloco com EXCEPTION; o resultado (REJEITADO = esperado) é gravado em tabela temporária.
-- Nenhum dado persistente é alterado (tudo é revertido).
SET client_encoding='UTF8';
CREATE TEMP TABLE resultado_teste (cod text, regra text, esperado text, obtido text, ok boolean);

CREATE OR REPLACE FUNCTION pg_temp.tenta(p_cod text, p_regra text, p_sql text) RETURNS void AS $$
DECLARE v_msg text; v_aceito boolean := false;
BEGIN
    BEGIN
        EXECUTE p_sql;
        v_aceito := true;
        RAISE EXCEPTION 'desfaz';              -- desfaz o que foi aceito (subtransação)
    EXCEPTION WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS v_msg = MESSAGE_TEXT;
    END;
    IF v_aceito THEN
        INSERT INTO resultado_teste VALUES (p_cod, p_regra, 'REJEITADO', 'ACEITO (falha do teste)', false);
    ELSE
        INSERT INTO resultado_teste VALUES (p_cod, p_regra, 'REJEITADO', 'REJEITADO: '||left(v_msg,95), true);
    END IF;
END $$ LANGUAGE plpgsql;

\o /dev/null
-- PK / UNIQUE
SELECT pg_temp.tenta('T01','PK duplicada em CLIENTE',$$INSERT INTO cliente (id_cliente,cpf_cnpj) VALUES (1,'99.999.999/0001-99')$$);
SELECT pg_temp.tenta('T02','UNIQUE cpf_cnpj do cliente',$$INSERT INTO cliente (cpf_cnpj) VALUES ('10.000.000/0001-01')$$);
SELECT pg_temp.tenta('T03','UNIQUE num_serie da máquina',$$INSERT INTO maquina (id_cliente,num_serie) VALUES (1,'TESTE-EXT-001')$$);
SELECT pg_temp.tenta('T04','UNIQUE (id_solicitacao, versao) do orçamento',$$INSERT INTO orcamento (id_solicitacao,versao) VALUES (1,2)$$);
SELECT pg_temp.tenta('T05','UNIQUE (id_os, parcela) da conta a receber',$$INSERT INTO conta_a_receber (id_os,parcela) VALUES (1,'ENTRADA')$$);
SELECT pg_temp.tenta('T06','UNIQUE id_cotacao em CONTRATAÇÃO (R31 1:1)',$$INSERT INTO contratacao (id_cotacao) VALUES (1)$$);
-- NOT NULL
SELECT pg_temp.tenta('T07','NOT NULL id_cliente em MÁQUINA',$$INSERT INTO maquina (num_serie) VALUES ('TESTE-X')$$);
-- FK
SELECT pg_temp.tenta('T08','FK inexistente: máquina de cliente que não existe',$$INSERT INTO maquina (id_cliente,num_serie) VALUES (999,'TESTE-Y')$$);
SELECT pg_temp.tenta('T09','ON DELETE RESTRICT: excluir cliente com máquinas',$$DELETE FROM cliente WHERE id_cliente=1$$);
SELECT pg_temp.tenta('T10','ON DELETE RESTRICT: excluir OS que possui inspeção, itens e contas vinculados',$$DELETE FROM ordem_servico WHERE id_os=1$$);
-- CHECK
SELECT pg_temp.tenta('T11','Item de orçamento com serviço E material',$$INSERT INTO item_orcamento (id_orcamento,id_servico,id_material,quantidade) VALUES (10,1,1,1)$$);
SELECT pg_temp.tenta('T12','Item de orçamento sem serviço e sem material',$$INSERT INTO item_orcamento (id_orcamento,quantidade) VALUES (10,1)$$);
SELECT pg_temp.tenta('T13','Item de OS com serviço E material',$$INSERT INTO item_ordem_servico (id_os,id_servico,id_material,quantidade) VALUES (1,1,1,1)$$);
SELECT pg_temp.tenta('T14','Quantidade zero em item de OS',$$INSERT INTO item_ordem_servico (id_os,id_servico,quantidade) VALUES (1,1,0)$$);
SELECT pg_temp.tenta('T15','Domínio de situação do orçamento',$$UPDATE orcamento SET situacao='TALVEZ' WHERE id_orcamento=10$$);
SELECT pg_temp.tenta('T16','Versão de orçamento menor que 1',$$INSERT INTO orcamento (id_solicitacao,versao) VALUES (8,0)$$);
SELECT pg_temp.tenta('T17','Movimentação de estoque ENTRADA sem item recebido',$$INSERT INTO movimentacao_estoque (id_material,tipo,quantidade) VALUES (1,'ENTRADA',5)$$);
SELECT pg_temp.tenta('T18','Movimentação de estoque SAÍDA sem OS',$$INSERT INTO movimentacao_estoque (id_material,tipo,quantidade) VALUES (1,'SAÍDA',5)$$);
SELECT pg_temp.tenta('T19','Movimentação de estoque com quantidade negativa',$$INSERT INTO movimentacao_estoque (id_material,id_os,tipo,quantidade) VALUES (1,1,'SAÍDA',-1)$$);
SELECT pg_temp.tenta('T20','Movimentação financeira com recebimento E pagamento',$$INSERT INTO movimentacao_financeira (id_conta_fin,id_recebimento,id_pagamento,tipo,valor) VALUES (2,1,1,'ENTRADA',1)$$);
SELECT pg_temp.tenta('T21','Movimentação financeira de pagamento como ENTRADA',$$INSERT INTO movimentacao_financeira (id_conta_fin,id_pagamento,tipo,valor) VALUES (2,1,'ENTRADA',1)$$);
SELECT pg_temp.tenta('T22','Conta a pagar com duas origens (folha e despesa)',$$INSERT INTO conta_a_pagar (id_folha,id_despesa,origem_tipo,valor_origem) VALUES (6,6,'FOLHA',10)$$);
SELECT pg_temp.tenta('T23','Conta a pagar origem_tipo incoerente com a FK',$$INSERT INTO conta_a_pagar (id_despesa,origem_tipo,valor_origem) VALUES (6,'IMPOSTO',10)$$);
SELECT pg_temp.tenta('T24','Pagamento com valor negativo',$$INSERT INTO pagamento (id_conta_pagar,valor_pago) VALUES (16,-5)$$);
SELECT pg_temp.tenta('T25','Reserva EXECUTADA sem movimentação financeira',$$INSERT INTO movimentacao_reserva (id_capital,tipo,valor,situacao) VALUES (1,'UTILIZAÇÃO',10,'EXECUTADA')$$);
SELECT pg_temp.tenta('T26','Reserva que volta a SOLICITADA mantendo a movimentação financeira (EXECUTADA ⇔ id_mov_fin)',$$UPDATE movimentacao_reserva SET situacao='SOLICITADA' WHERE id_mov_reserva=2$$);
SELECT pg_temp.tenta('T27','Movimentação de máquina ENVIO sem terceirizada',$$INSERT INTO movimentacao_maquina (id_maquina,id_funcionario,tipo) VALUES (1,1,'ENVIO')$$);
SELECT pg_temp.tenta('T28','Benefício com data_fim antes de data_inicio',$$INSERT INTO funcionario_beneficio (id_funcionario,id_beneficio,data_inicio,data_fim) VALUES (1,1,'2026-05-01','2026-04-01')$$);
SELECT pg_temp.tenta('T29','Encargo com tipo fora do domínio (INSS/FGTS)',$$INSERT INTO encargo (id_folha,tipo) VALUES (1,'IRRF')$$);
SELECT pg_temp.tenta('T30','Competência da folha que não é o 1º dia do mês',$$INSERT INTO folha_pagamento (id_funcionario,competencia) VALUES (1,'2026-11-15')$$);
-- Gatilhos (regras entre tabelas)
SELECT pg_temp.tenta('T31','OS a partir de orçamento NÃO aprovado (recusado)',$$INSERT INTO ordem_servico (id_orcamento,id_maquina,id_funcionario) VALUES (1,1,1)$$);
SELECT pg_temp.tenta('T32','OS a partir de orçamento sem decisão',$$INSERT INTO ordem_servico (id_orcamento,id_maquina,id_funcionario) VALUES (10,2,1)$$);
SELECT pg_temp.tenta('T33','OS com máquina diferente da solicitação do orçamento',$$INSERT INTO ordem_servico (id_orcamento,id_maquina,id_funcionario) VALUES (2,2,1)$$);
SELECT pg_temp.tenta('T34','Item recebido de pedido diferente do recebimento',$$INSERT INTO item_recebimento (id_receb_compra,id_item_pedido,qtd_recebida) VALUES (1,4,1)$$);
SELECT pg_temp.tenta('T35','Entrada de estoque com material diferente do item recebido',$$INSERT INTO movimentacao_estoque (id_material,id_item_receb,tipo,quantidade) VALUES (2,1,'ENTRADA',1)$$);
SELECT pg_temp.tenta('T36','Reserva com movimentação financeira de outra conta',$$INSERT INTO movimentacao_reserva (id_capital,id_mov_fin,tipo,valor,situacao) VALUES (1,1,'UTILIZAÇÃO',10,'EXECUTADA')$$);
SELECT pg_temp.tenta('T37','Excluir versão de orçamento (histórico preservado)',$$DELETE FROM orcamento WHERE id_orcamento=1$$);
SELECT pg_temp.tenta('T38','Trocar a versão de um orçamento emitido',$$UPDATE orcamento SET versao=9 WHERE id_orcamento=2$$);

-- Testes POSITIVOS (devem ser ACEITOS): histórico de versões, 1:N orçamento→OS e entrega parcial
CREATE OR REPLACE FUNCTION pg_temp.aceita(p_cod text, p_regra text, p_sql text) RETURNS void AS $$
DECLARE v_msg text; v_aceito boolean := false;
BEGIN
    BEGIN
        EXECUTE p_sql;
        v_aceito := true;
        RAISE EXCEPTION 'desfaz';
    EXCEPTION WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS v_msg = MESSAGE_TEXT;
    END;
    IF v_aceito THEN
        INSERT INTO resultado_teste VALUES (p_cod, p_regra, 'ACEITO', 'ACEITO', true);
    ELSE
        INSERT INTO resultado_teste VALUES (p_cod, p_regra, 'ACEITO', 'REJEITADO: '||left(v_msg,95), false);
    END IF;
END $$ LANGUAGE plpgsql;
SELECT pg_temp.aceita('P01','Nova versão de orçamento (v3) para a solicitação 6',$$INSERT INTO orcamento (id_solicitacao,versao) VALUES (6,3)$$);
SELECT pg_temp.aceita('P02','Segunda OS para o mesmo orçamento aprovado (R05 1:N)',$$INSERT INTO ordem_servico (id_orcamento,id_maquina,id_funcionario) VALUES (3,3,1)$$);
SELECT pg_temp.aceita('P03','Inspeção sem OS (INSPEÇÃO pode ocorrer sem OS)',$$INSERT INTO inspecao (id_maquina,id_funcionario) VALUES (7,1)$$);
SELECT pg_temp.aceita('P04','Terceiro recebimento parcial do item 4 (correia faltante)',$$INSERT INTO recebimento_compra (id_pedido,nota_fiscal) VALUES (2,'NF-TESTE-0099'); INSERT INTO item_recebimento (id_receb_compra,id_item_pedido,qtd_recebida) VALUES ((SELECT max(id_receb_compra) FROM recebimento_compra),4,4)$$);
SELECT pg_temp.aceita('P05','Pagamento parcelado (duas parcelas na mesma conta)',$$INSERT INTO pagamento (id_conta_pagar,numero_parcela,valor_pago) VALUES (20,1,450); INSERT INTO pagamento (id_conta_pagar,numero_parcela,valor_pago) VALUES (20,2,450)$$);

\o
\echo '=== RESULTADO DOS TESTES DE RESTRIÇÃO'
SELECT cod, regra, obtido, CASE WHEN ok THEN 'OK' ELSE 'FALHA' END AS status FROM resultado_teste ORDER BY cod;
SELECT COUNT(*) AS total, COUNT(*) FILTER (WHERE ok) AS ok, COUNT(*) FILTER (WHERE NOT ok) AS falhas FROM resultado_teste;

-- Sensibilidade da auditoria: injeta inconsistências (sem as restrições de CHECK que as impediriam) e confirma que as consultas as detectam
\echo '=== SENSIBILIDADE DA AUDITORIA (dados inconsistentes injetados e revertidos)'
BEGIN;
UPDATE conta_financeira SET saldo_atual = saldo_atual + 100 WHERE id_conta_fin=2;                -- A09
UPDATE movimentacao_financeira SET valor = valor + 1 WHERE id_mov_fin=1;                          -- A07
UPDATE item_ordem_servico SET valor_total = valor_total + 1 WHERE id_item_os=1;                   -- A14
UPDATE orcamento SET valor_total = valor_total + 1 WHERE id_orcamento=3;                          -- A13
INSERT INTO movimentacao_estoque (id_material,id_os,tipo,quantidade,data) VALUES (4,1,'SAÍDA',50,'2026-10-30'); -- A10 (estoque negativo)
SELECT 'A07 divergência de valor' AS teste, COUNT(*) AS linhas_detectadas FROM (
  SELECT m.id_mov_fin FROM movimentacao_financeira m JOIN recebimento r ON r.id_recebimento=m.id_recebimento WHERE m.valor <> r.valor_pago+r.multa+r.juros) x
UNION ALL SELECT 'A09 saldo armazenado ≠ calculado', COUNT(*) FROM (
  SELECT cf.id_conta_fin FROM conta_financeira cf LEFT JOIN movimentacao_financeira m USING (id_conta_fin) GROUP BY cf.id_conta_fin, cf.saldo_atual
   HAVING cf.saldo_atual <> COALESCE(SUM(CASE WHEN m.tipo='ENTRADA' THEN m.valor ELSE -m.valor END),0)) y
UNION ALL SELECT 'A14 item OS com total divergente', COUNT(*) FROM item_ordem_servico WHERE valor_total <> quantidade*valor_unitario
UNION ALL SELECT 'A13 orçamento com total divergente', COUNT(*) FROM (
  SELECT o.id_orcamento FROM orcamento o JOIN item_orcamento i USING (id_orcamento) GROUP BY o.id_orcamento, o.valor_total HAVING o.valor_total <> SUM(i.quantidade*i.valor_unitario)) z
UNION ALL SELECT 'A10 estoque negativo', COUNT(*) FROM (
  SELECT id_material FROM movimentacao_estoque GROUP BY id_material HAVING SUM(CASE WHEN tipo='ENTRADA' THEN quantidade ELSE -quantidade END) < 0) w;
ROLLBACK;
\echo '=== Estado após ROLLBACK (deve estar consistente): saldo conta 2 e total de movimentações de estoque'
SELECT (SELECT saldo_atual FROM conta_financeira WHERE id_conta_fin=2) AS saldo_conta_2, (SELECT COUNT(*) FROM movimentacao_estoque) AS mov_estoque;
