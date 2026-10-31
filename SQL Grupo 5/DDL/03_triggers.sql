-- Projeto Integrador — Modelagem de Dados | Grupo 5 | UNICID
-- ERP de manutenção e reparo de máquinas extrusoras balão
-- SGBD: PostgreSQL 16 (UTF8)

-- 03 — Regras entre tabelas que não cabem em CHECK (gatilhos PL/pgSQL)
SET client_encoding='UTF8';

-- 1) ORDEM_SERVIÇO: orçamento APROVADO e máquina coerente com a solicitação do orçamento (CR2/R06)
CREATE OR REPLACE FUNCTION fn_os_regras() RETURNS trigger AS $$
DECLARE v_sit varchar(20); v_maq integer;
BEGIN
    SELECT o.situacao, s.id_maquina INTO v_sit, v_maq
      FROM orcamento o JOIN solicitacao s ON s.id_solicitacao = o.id_solicitacao
     WHERE o.id_orcamento = NEW.id_orcamento;
    IF v_sit IS DISTINCT FROM 'APROVADO' THEN
        RAISE EXCEPTION 'OS exige orçamento APROVADO (orçamento % está %)', NEW.id_orcamento, COALESCE(v_sit,'sem decisão');
    END IF;
    IF v_maq <> NEW.id_maquina THEN
        RAISE EXCEPTION 'Máquina da OS (%) difere da máquina da solicitação do orçamento (%)', NEW.id_maquina, v_maq;
    END IF;
    RETURN NEW;
END $$ LANGUAGE plpgsql;
CREATE TRIGGER trg_os_regras BEFORE INSERT OR UPDATE OF id_orcamento, id_maquina ON ordem_servico
    FOR EACH ROW EXECUTE FUNCTION fn_os_regras();

-- 2) ITEM_RECEBIMENTO: o item recebido deve pertencer ao pedido do recebimento (entregas parciais)
CREATE OR REPLACE FUNCTION fn_item_receb_pedido() RETURNS trigger AS $$
DECLARE v_ped_item integer; v_ped_receb integer;
BEGIN
    SELECT id_pedido INTO v_ped_item  FROM item_pedido        WHERE id_item_pedido = NEW.id_item_pedido;
    SELECT id_pedido INTO v_ped_receb FROM recebimento_compra WHERE id_receb_compra = NEW.id_receb_compra;
    IF v_ped_item <> v_ped_receb THEN
        RAISE EXCEPTION 'Item % pertence ao pedido %, mas o recebimento % é do pedido %',
            NEW.id_item_pedido, v_ped_item, NEW.id_receb_compra, v_ped_receb;
    END IF;
    RETURN NEW;
END $$ LANGUAGE plpgsql;
CREATE TRIGGER trg_item_receb_pedido BEFORE INSERT OR UPDATE ON item_recebimento
    FOR EACH ROW EXECUTE FUNCTION fn_item_receb_pedido();

-- 3) MOVIMENTAÇÃO_ESTOQUE: em ENTRADA, o material é o do item pedido recebido (R42)
CREATE OR REPLACE FUNCTION fn_mov_estoque_material() RETURNS trigger AS $$
DECLARE v_mat integer;
BEGIN
    IF NEW.tipo = 'ENTRADA' THEN
        SELECT ip.id_material INTO v_mat
          FROM item_recebimento ir JOIN item_pedido ip ON ip.id_item_pedido = ir.id_item_pedido
         WHERE ir.id_item_receb = NEW.id_item_receb;
        IF v_mat <> NEW.id_material THEN
            RAISE EXCEPTION 'Material da entrada (%) difere do material do item recebido (%)', NEW.id_material, v_mat;
        END IF;
    END IF;
    RETURN NEW;
END $$ LANGUAGE plpgsql;
CREATE TRIGGER trg_mov_estoque_material BEFORE INSERT OR UPDATE ON movimentacao_estoque
    FOR EACH ROW EXECUTE FUNCTION fn_mov_estoque_material();

-- 4) MOVIMENTAÇÃO_RESERVA: a movimentação financeira usa a conta do capital de emergência (R45)
CREATE OR REPLACE FUNCTION fn_mov_reserva_conta() RETURNS trigger AS $$
DECLARE v_cf_mov integer; v_cf_cap integer;
BEGIN
    IF NEW.id_mov_fin IS NOT NULL THEN
        SELECT id_conta_fin INTO v_cf_mov FROM movimentacao_financeira WHERE id_mov_fin = NEW.id_mov_fin;
        SELECT id_conta_fin INTO v_cf_cap FROM capital_emergencia      WHERE id_capital = NEW.id_capital;
        IF v_cf_mov <> v_cf_cap THEN
            RAISE EXCEPTION 'Conta da movimentação financeira (%) difere da conta do capital de emergência (%)', v_cf_mov, v_cf_cap;
        END IF;
    END IF;
    RETURN NEW;
END $$ LANGUAGE plpgsql;
CREATE TRIGGER trg_mov_reserva_conta BEFORE INSERT OR UPDATE ON movimentacao_reserva
    FOR EACH ROW EXECUTE FUNCTION fn_mov_reserva_conta();

-- 5) ORÇAMENTO: preserva o histórico de versões (não apaga versão; não troca solicitação nem versão)
CREATE OR REPLACE FUNCTION fn_orcamento_historico() RETURNS trigger AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        RAISE EXCEPTION 'Versões de orçamento não podem ser excluídas (histórico preservado)';
    END IF;
    IF NEW.id_solicitacao <> OLD.id_solicitacao OR NEW.versao <> OLD.versao THEN
        RAISE EXCEPTION 'Solicitação e versão do orçamento não podem ser alteradas; crie uma nova versão';
    END IF;
    RETURN NEW;
END $$ LANGUAGE plpgsql;
CREATE TRIGGER trg_orcamento_historico BEFORE UPDATE OR DELETE ON orcamento
    FOR EACH ROW EXECUTE FUNCTION fn_orcamento_historico();
