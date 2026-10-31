-- Projeto Integrador — Modelagem de Dados | Grupo 5 | UNICID
-- 04 — MASSA DE DADOS DE TESTE (INSERT INTO)
-- ATENÇÃO: todos os dados são FICTÍCIOS ("TESTE"), gerados para validar o banco.
-- Nenhum dado pessoal real de cliente, funcionário ou fornecedor foi utilizado.
-- CNPJ/CPF abaixo são sequências sintéticas, sem validade fiscal.
-- Valores monetários, totais e saldos foram CALCULADOS pelo gerador gen_seed.py e
-- conferidos pelas consultas de auditoria (sql/auditoria).
SET client_encoding='UTF8';
BEGIN;
-- FUNCIONÁRIO (empresa com proprietário e um funcionário [M §4.2])
INSERT INTO funcionario (id_funcionario, nome, cpf, cargo, salario_base, data_admissao, situacao) VALUES
  (1, 'TESTE Proprietário', '000.000.001-01', 'Proprietário', 2500.00, '2020-01-02', 'ATIVO'),
  (2, 'TESTE Funcionário', '000.000.002-02', 'Auxiliar técnico', 1800.00, '2022-03-01', 'ATIVO');

INSERT INTO beneficio (id_beneficio, nome, tipo, valor_padrao) VALUES
  (1, 'Vale-transporte', 'TRANSPORTE', 220.00),
  (2, 'Vale-refeição', 'ALIMENTAÇÃO', 600.00);

INSERT INTO funcionario_beneficio (id_func_benef, id_funcionario, id_beneficio, valor, data_inicio, data_fim) VALUES
  (1, 1, 1, 220.00, '2026-01-01', NULL),
  (2, 1, 2, 600.00, '2026-01-01', NULL),
  (3, 2, 1, 220.00, '2026-01-01', NULL),
  (4, 2, 2, 600.00, '2026-01-01', NULL);

-- CLIENTES (pessoas jurídicas)
INSERT INTO cliente (id_cliente, razao_nome, cpf_cnpj, endereco, telefone, email, status) VALUES
  (1, 'TESTE Plásticos Aurora Ltda', '10.000.000/0001-01', 'Rua Teste, 100 - Cidade Teste/SP', '(00) 90000-0001', 'contato@teste1.example', 'ATIVO'),
  (2, 'TESTE Embalagens Horizonte S.A.', '10.000.000/0002-02', 'Rua Teste, 200 - Cidade Teste/SP', '(00) 90000-0002', 'contato@teste2.example', 'ATIVO'),
  (3, 'TESTE Filmes Flexíveis Vale Ltda', '10.000.000/0003-03', 'Rua Teste, 300 - Cidade Teste/SP', '(00) 90000-0003', 'contato@teste3.example', 'ATIVO'),
  (4, 'TESTE Indústria Delta Ltda', '10.000.000/0004-04', 'Rua Teste, 400 - Cidade Teste/SP', '(00) 90000-0004', 'contato@teste4.example', 'ATIVO'),
  (5, 'TESTE Bolhas & Cia Ltda', '10.000.000/0005-05', 'Rua Teste, 500 - Cidade Teste/SP', '(00) 90000-0005', 'contato@teste5.example', 'ATIVO'),
  (6, 'TESTE Polímeros Norte Ltda', '10.000.000/0006-06', 'Rua Teste, 600 - Cidade Teste/SP', '(00) 90000-0006', 'contato@teste6.example', 'ATIVO');

INSERT INTO maquina (id_maquina, id_cliente, fabricante_modelo, num_serie, descricao) VALUES
  (1, 1, 'TESTE Extrusora Balão Modelo A', 'TESTE-EXT-001', 'Extrusora balão 1 camada'),
  (2, 1, 'TESTE Extrusora Balão Modelo A', 'TESTE-EXT-002', 'Extrusora balão 1 camada'),
  (3, 2, 'TESTE Extrusora Balão Modelo B', 'TESTE-EXT-003', 'Extrusora balão 2 camadas'),
  (4, 3, 'TESTE Extrusora Balão Modelo B', 'TESTE-EXT-004', 'Extrusora balão 2 camadas'),
  (5, 3, 'TESTE Extrusora Balão Modelo A', 'TESTE-EXT-005', 'Extrusora balão 1 camada'),
  (6, 4, 'TESTE Extrusora Balão Modelo C', 'TESTE-EXT-006', 'Extrusora balão 3 camadas'),
  (7, 5, 'TESTE Extrusora Balão Modelo A', 'TESTE-EXT-007', 'Extrusora balão 1 camada'),
  (8, 6, 'TESTE Extrusora Balão Modelo C', 'TESTE-EXT-008', 'Extrusora balão 3 camadas'),
  (9, 6, 'TESTE Extrusora Balão Modelo B', 'TESTE-EXT-009', 'Extrusora balão 2 camadas');

INSERT INTO terceirizada (id_terceirizada, razao_social, cnpj, especialidade, contato, telefone, endereco) VALUES
  (1, 'TESTE Tornearia Alfa Ltda', '20.000.000/0001-01', 'Tornearia mecânica', 'Contato Alfa', '(00) 91000-0001', 'Rua Teste, 10 - Cidade Teste/SP'),
  (2, 'TESTE Usinagem Beta Ltda', '20.000.000/0002-02', 'Usinagem de precisão', 'Contato Beta', '(00) 91000-0002', 'Rua Teste, 20 - Cidade Teste/SP'),
  (3, 'TESTE Restauração Gama Ltda', '20.000.000/0003-03', 'Restauração de peças', 'Contato Gama', '(00) 91000-0003', 'Rua Teste, 30 - Cidade Teste/SP');

INSERT INTO servico (id_servico, nome, descricao, valor_padrao) VALUES
  (1, 'Restauração de cabeçote', 'Restauração do cabeçote da extrusora', 5200),
  (2, 'Troca de rosca', 'Substituição da rosca/parafuso de extrusão', 1800),
  (3, 'Torneamento de peças', 'Torneamento mecânico (valor por peça)', 650),
  (4, 'Montagem de resistência', 'Montagem e ajuste de resistência de aquecimento', 1400),
  (5, 'Revisão geral', 'Revisão geral de máquina extrusora', 4200),
  (6, 'Calibração do anel de ar', 'Calibração do anel de ar de resfriamento', 1100);

INSERT INTO material (id_material, descricao, unidade, estoque_minimo) VALUES
  (1, 'Resistência cerâmica', 'UN', 10),
  (2, 'Termopar', 'UN', 5),
  (3, 'Rolamento 6205', 'UN', 8),
  (4, 'Correia de transmissão', 'UN', 5),
  (5, 'Graxa industrial', 'KG', 3),
  (6, 'Parafuso M10', 'UN', 50);

INSERT INTO fornecedor (id_fornecedor, razao_social, cnpj, endereco, telefone, contato) VALUES
  (1, 'TESTE Peças Industriais Ltda', '30.000.000/0001-01', 'Rua Teste, 40 - Cidade Teste/SP', '(00) 92000-0001', 'Contato Forn 1'),
  (2, 'TESTE Suprimentos Técnicos Ltda', '30.000.000/0002-02', 'Rua Teste, 50 - Cidade Teste/SP', '(00) 92000-0002', 'Contato Forn 2');

INSERT INTO solicitacao (id_solicitacao, id_cliente, id_maquina, id_funcionario, problema_descrito, data_solicitacao, status) VALUES
  (1, 1, 1, 2, 'Aquecimento irregular e vazamento no cabeçote', '2026-08-03', 'ENCERRADA'),
  (2, 2, 3, 2, 'Ruído no rolamento e necessidade de revisão', '2026-08-18', 'ENCERRADA'),
  (3, 3, 4, 1, 'Variação de espessura do filme', '2026-09-01', 'ENCERRADA'),
  (4, 3, 5, 2, 'Revisão preventiva geral', '2026-09-15', 'ENCERRADA'),
  (5, 4, 6, 2, 'Cabeçote com desgaste e resistência queimada', '2026-09-28', 'EM ANDAMENTO'),
  (6, 5, 7, 1, 'Revisão geral solicitada', '2026-10-02', 'EM NEGOCIAÇÃO'),
  (7, 6, 8, 2, 'Desgaste de rosca e peças torneadas', '2026-10-06', 'EM ANDAMENTO'),
  (8, 1, 2, 1, 'Rosca com folga', '2026-10-20', 'AGUARDANDO ORÇAMENTO'),
  (9, 6, 9, 2, 'Máquina sem aquecimento (inspeção)', '2026-10-22', 'EM INSPEÇÃO'),
  (10, 1, 1, 1, 'Nova calibração do anel de ar', '2026-10-25', 'ENCERRADA');

-- ORÇAMENTOS (várias versões por solicitação; valor_total = soma dos itens)
INSERT INTO orcamento (id_orcamento, id_solicitacao, versao, valor_total, prazo_dias, data_emissao, data_decisao, situacao) VALUES
  (1, 1, 1, 7760, 20, '2026-08-05', '2026-08-08', 'RECUSADO'),
  (2, 1, 2, 6460, 18, '2026-08-12', '2026-08-16', 'APROVADO'),
  (3, 2, 1, 4670, 15, '2026-08-20', '2026-08-25', 'APROVADO'),
  (4, 3, 1, 3650, 12, '2026-09-03', '2026-09-08', 'APROVADO'),
  (5, 4, 1, 4520, 10, '2026-09-17', '2026-09-22', 'APROVADO'),
  (6, 5, 1, 5460.00, 14, '2026-09-30', '2026-10-03', 'APROVADO'),
  (7, 6, 1, 4200, 10, '2026-10-04', '2026-10-07', 'RECUSADO'),
  (8, 6, 2, 1100, 7, '2026-10-09', NULL, NULL),
  (9, 7, 1, 7800, 20, '2026-10-10', '2026-10-13', 'APROVADO'),
  (10, 8, 1, 1800, 10, '2026-10-22', NULL, NULL),
  (11, 10, 1, 1100, 5, '2026-10-26', '2026-10-28', 'RECUSADO');

INSERT INTO item_orcamento (id_item_orcamento, id_orcamento, id_servico, id_material, quantidade, valor_unitario) VALUES
  (1, 1, 1, NULL, 1, 5200),
  (2, 1, 2, NULL, 1, 1800),
  (3, 1, NULL, 1, 2, 380),
  (4, 2, 1, NULL, 1, 4600),
  (5, 2, 6, NULL, 1, 1100),
  (6, 2, NULL, 1, 2, 380),
  (7, 3, 5, NULL, 1, 4200),
  (8, 3, NULL, 3, 4, 95),
  (9, 3, NULL, 5, 2, 45),
  (10, 4, 3, NULL, 3, 650),
  (11, 4, 4, NULL, 1, 1400),
  (12, 4, NULL, 2, 2, 150),
  (13, 5, 5, NULL, 1, 4200),
  (14, 5, NULL, 4, 2, 160),
  (15, 6, 1, NULL, 1, 5200),
  (16, 6, NULL, 3, 2, 95),
  (17, 6, NULL, 6, 20, 3.50),
  (18, 7, 5, NULL, 1, 4200),
  (19, 8, 6, NULL, 1, 1100),
  (20, 9, 3, NULL, 4, 650),
  (21, 9, 1, NULL, 1, 5200),
  (22, 10, 2, NULL, 1, 1800),
  (23, 11, 6, NULL, 1, 1100);

-- ORDENS DE SERVIÇO (somente de orçamentos APROVADOS)
INSERT INTO ordem_servico (id_os, id_orcamento, id_maquina, id_funcionario, data_abertura, data_execucao, data_finalizacao, data_conclusao, situacao) VALUES
  (1, 2, 1, 1, '2026-08-17', '2026-08-25', '2026-09-10', '2026-09-12', 'CONCLUÍDA'),
  (2, 3, 3, 1, '2026-08-26', '2026-09-02', '2026-09-15', '2026-09-18', 'CONCLUÍDA'),
  (3, 4, 4, 2, '2026-09-09', '2026-09-14', '2026-09-30', '2026-10-02', 'CONCLUÍDA'),
  (4, 5, 5, 1, '2026-09-23', '2026-10-01', '2026-10-12', NULL, 'EM REVISÃO'),
  (5, 6, 6, 1, '2026-10-04', '2026-10-10', NULL, NULL, 'EM EXECUÇÃO'),
  (6, 9, 8, 2, '2026-10-14', '2026-10-20', NULL, NULL, 'EM EXECUÇÃO');

INSERT INTO item_ordem_servico (id_item_os, id_os, id_servico, id_material, quantidade, valor_unitario, valor_total) VALUES
  (1, 1, 1, NULL, 1, 4600, 4600),
  (2, 1, 6, NULL, 1, 1100, 1100),
  (3, 1, NULL, 1, 2, 380, 760),
  (4, 2, 5, NULL, 1, 4200, 4200),
  (5, 2, NULL, 3, 4, 95, 380),
  (6, 2, NULL, 5, 2, 45, 90),
  (7, 3, 3, NULL, 3, 650, 1950),
  (8, 3, 4, NULL, 1, 1400, 1400),
  (9, 3, NULL, 2, 2, 150, 300),
  (10, 4, 5, NULL, 1, 4200, 4200),
  (11, 4, NULL, 4, 2, 160, 320),
  (12, 5, 1, NULL, 1, 5200, 5200),
  (13, 5, NULL, 3, 2, 95, 190),
  (14, 5, NULL, 6, 20, 3.50, 70.00),
  (15, 6, 3, NULL, 4, 650, 2600),
  (16, 6, 1, NULL, 1, 5200, 5200);

-- INSPEÇÕES (algumas sem OS)
INSERT INTO inspecao (id_inspecao, id_os, id_maquina, id_funcionario, data_inspecao, resultado, motivo_reprovacao) VALUES
  (1, 1, 1, 1, '2026-08-18', 'APROVADO', NULL),
  (2, 2, 3, 1, '2026-08-27', 'APROVADO', NULL),
  (3, 3, 4, 1, '2026-09-10', 'APROVADO', NULL),
  (4, 4, 5, 1, '2026-09-24', 'APROVADO', NULL),
  (5, 5, 6, 1, '2026-10-05', 'APROVADO', NULL),
  (6, 6, 8, 1, '2026-10-15', 'APROVADO', NULL),
  (7, NULL, 9, 1, '2026-10-23', 'REPROVADO', 'Cabeçote com trinca; necessita restauração em terceirizada'),
  (8, NULL, 2, 1, '2026-10-21', 'APROVADO', NULL),
  (9, 3, 4, 1, '2026-09-29', 'REPROVADO', 'Espessura fora do padrão após retorno; retorna à terceirizada');

INSERT INTO cotacao (id_cotacao, id_os, id_terceirizada, valor_proposto, prazo_dias, data_cotacao, situacao) VALUES
  (1, 6, 1, 1800, 10, '2026-10-15', 'APROVADA'),
  (2, 6, 2, 2100, 7, '2026-10-15', 'RECUSADA'),
  (3, 6, 3, 1950, 12, '2026-10-16', 'RECUSADA'),
  (4, 3, 2, 800, 5, '2026-09-11', 'APROVADA'),
  (5, 3, 1, 900, 6, '2026-09-11', 'RECUSADA'),
  (6, 1, 3, 600, 4, '2026-08-18', 'APROVADA');

INSERT INTO contratacao (id_contratacao, id_cotacao, data_contratacao, valor_contratado, prazo_dias, servico_contratado) VALUES
  (1, 1, '2026-10-18', 1800, 10, 'Torneamento de peças e restauração do cabeçote'),
  (2, 4, '2026-09-12', 800, 5, 'Usinagem do componente da máquina'),
  (3, 6, '2026-08-19', 600, 4, 'Restauração de peça do cabeçote');

INSERT INTO movimentacao_maquina (id_mov_maquina, id_maquina, id_terceirizada, id_os, id_funcionario, tipo, data_hora, origem, destino, motivo) VALUES
  (1, 1, NULL, 1, 1, 'ENTRADA', '2026-08-17 09:00', 'Cliente', 'Empresa', 'Recebimento para inspeção'),
  (2, 1, 3, 1, 1, 'ENVIO', '2026-08-19 14:00', 'Empresa', 'TESTE Restauração Gama', 'Restauração de peça'),
  (3, 1, 3, 1, 1, 'RETORNO', '2026-08-23 10:30', 'TESTE Restauração Gama', 'Empresa', 'Retorno do serviço'),
  (4, 1, NULL, 1, 1, 'DEVOLUÇÃO', '2026-09-12 16:00', 'Empresa', 'Cliente', 'Entrega ao cliente'),
  (5, 3, NULL, 2, 1, 'ENTRADA', '2026-08-26 10:00', 'Cliente', 'Empresa', 'Recebimento para revisão'),
  (6, 3, NULL, 2, 1, 'DEVOLUÇÃO', '2026-09-18 15:00', 'Empresa', 'Cliente', 'Entrega ao cliente'),
  (7, 4, NULL, 3, 2, 'ENTRADA', '2026-09-09 11:00', 'Cliente', 'Empresa', 'Recebimento para correção'),
  (8, 4, 2, 3, 2, 'ENVIO', '2026-09-12 13:00', 'Empresa', 'TESTE Usinagem Beta', 'Usinagem'),
  (9, 4, 2, 3, 2, 'RETORNO', '2026-09-20 09:30', 'TESTE Usinagem Beta', 'Empresa', 'Retorno da usinagem'),
  (10, 4, 2, 3, 2, 'ENVIO', '2026-09-30 10:00', 'Empresa', 'TESTE Usinagem Beta', 'Retorno por reprovação técnica'),
  (11, 4, 2, 3, 2, 'RETORNO', '2026-10-01 10:00', 'TESTE Usinagem Beta', 'Empresa', 'Correção concluída'),
  (12, 4, NULL, 3, 2, 'DEVOLUÇÃO', '2026-10-02 17:00', 'Empresa', 'Cliente', 'Entrega ao cliente'),
  (13, 5, NULL, 4, 1, 'ENTRADA', '2026-09-23 10:00', 'Cliente', 'Empresa', 'Recebimento para revisão'),
  (14, 6, NULL, 5, 1, 'ENTRADA', '2026-10-04 10:00', 'Cliente', 'Empresa', 'Recebimento para reparo'),
  (15, 8, NULL, 6, 2, 'ENTRADA', '2026-10-14 10:00', 'Cliente', 'Empresa', 'Recebimento para reparo'),
  (16, 8, 1, 6, 2, 'ENVIO', '2026-10-18 14:00', 'Empresa', 'TESTE Tornearia Alfa', 'Torneamento e restauração');

-- COMPRAS
INSERT INTO pedido_compra (id_pedido, id_fornecedor, data_pedido, valor_total, situacao) VALUES
  (1, 1, '2026-08-05', 3550, 'RECEBIDO'),
  (2, 2, '2026-09-01', 900.00, 'PARCIALMENTE RECEBIDO');

INSERT INTO item_pedido (id_item_pedido, id_pedido, id_material, quantidade, valor_unitario) VALUES
  (1, 1, 1, 20, 110),
  (2, 1, 2, 10, 45),
  (3, 1, 3, 30, 30),
  (4, 2, 4, 10, 60),
  (5, 2, 5, 10, 18),
  (6, 2, 6, 200, 0.60);

-- Recebimentos de compra (entregas parciais)
INSERT INTO recebimento_compra (id_receb_compra, id_pedido, nota_fiscal, data_recebimento, situacao) VALUES
  (1, 1, 'NF-TESTE-0001', '2026-08-12', 'PARCIAL'),
  (2, 1, 'NF-TESTE-0002', '2026-08-26', 'COMPLETO'),
  (3, 2, 'NF-TESTE-0003', '2026-09-12', 'PARCIAL');

INSERT INTO item_recebimento (id_item_receb, id_receb_compra, id_item_pedido, qtd_recebida) VALUES
  (1, 1, 1, 12),
  (2, 1, 2, 10),
  (3, 1, 3, 30),
  (4, 2, 1, 8),
  (5, 3, 4, 6),
  (6, 3, 5, 10),
  (7, 3, 6, 200);

-- MOVIMENTAÇÕES DE ESTOQUE (saldo = entradas − saídas; não é armazenado em MATERIAL)
INSERT INTO movimentacao_estoque (id_mov_estoque, id_material, id_os, id_item_receb, tipo, quantidade, data) VALUES
  (1, 1, NULL, 1, 'ENTRADA', 12, '2026-08-12'),
  (2, 2, NULL, 2, 'ENTRADA', 10, '2026-08-12'),
  (3, 3, NULL, 3, 'ENTRADA', 30, '2026-08-12'),
  (4, 1, NULL, 4, 'ENTRADA', 8, '2026-08-26'),
  (5, 4, NULL, 5, 'ENTRADA', 6, '2026-09-12'),
  (6, 5, NULL, 6, 'ENTRADA', 10, '2026-09-12'),
  (7, 6, NULL, 7, 'ENTRADA', 200, '2026-09-12'),
  (8, 1, 1, NULL, 'SAÍDA', 2, '2026-08-25'),
  (9, 3, 2, NULL, 'SAÍDA', 4, '2026-09-02'),
  (10, 5, 2, NULL, 'SAÍDA', 2, '2026-09-02'),
  (11, 2, 3, NULL, 'SAÍDA', 2, '2026-09-14'),
  (12, 4, 4, NULL, 'SAÍDA', 2, '2026-10-01'),
  (13, 3, 5, NULL, 'SAÍDA', 2, '2026-10-10'),
  (14, 6, 5, NULL, 'SAÍDA', 20, '2026-10-10');

-- FOLHA E ENCARGOS (valores fictícios; fórmula do líquido: bruto − descontos + benefícios + horas extras, apenas para a massa de teste — H6)
INSERT INTO folha_pagamento (id_folha, id_funcionario, competencia, salario_bruto, descontos, beneficios, horas_extras, salario_liquido) VALUES
  (1, 1, '2026-08-01', 2500, 275, 820, 0, 3045),
  (2, 2, '2026-08-01', 1800, 150, 820, 0, 2470),
  (3, 1, '2026-09-01', 2500, 275, 820, 0, 3045),
  (4, 2, '2026-09-01', 1800, 150, 820, 100, 2570),
  (5, 1, '2026-10-01', 2500, 275, 820, 0, 3045),
  (6, 2, '2026-10-01', 1800, 150, 820, 150, 2620);

INSERT INTO encargo (id_encargo, id_folha, tipo, base_calculo, valor) VALUES
  (1, 1, 'INSS', 2500, 200.00),
  (2, 1, 'FGTS', 2500, 200.00),
  (3, 2, 'INSS', 1800, 144.00),
  (4, 2, 'FGTS', 1800, 144.00),
  (5, 3, 'INSS', 2500, 200.00),
  (6, 3, 'FGTS', 2500, 200.00),
  (7, 4, 'INSS', 1800, 144.00),
  (8, 4, 'FGTS', 1800, 144.00),
  (9, 5, 'INSS', 2500, 200.00),
  (10, 5, 'FGTS', 2500, 200.00),
  (11, 6, 'INSS', 1800, 144.00),
  (12, 6, 'FGTS', 1800, 144.00);

-- IMPOSTOS E DESPESAS
INSERT INTO imposto (id_imposto, tipo, aliquota, base_calculo, valor, competencia) VALUES
  (1, 'SIMPLES NACIONAL', 6.000, 4452.00, 267.12, '2026-08-01'),
  (2, 'SIMPLES NACIONAL', 6.000, 9946.00, 596.76, '2026-09-01'),
  (3, 'SIMPLES NACIONAL', 6.000, 8994.00, 539.64, '2026-10-01');

INSERT INTO despesa (id_despesa, categoria, descricao, valor, data) VALUES
  (1, 'ALUGUEL', 'Aluguel do galpão - set/2026', 900, '2026-09-05'),
  (2, 'ALUGUEL', 'Aluguel do galpão - out/2026', 900, '2026-10-05'),
  (3, 'ENERGIA', 'Energia elétrica - set/2026', 280, '2026-09-10'),
  (4, 'ENERGIA', 'Energia elétrica - out/2026', 310, '2026-10-10'),
  (5, 'INTERNET', 'Internet - set/2026', 120, '2026-09-10'),
  (6, 'TRANSPORTE', 'Transporte de máquinas - out/2026', 260, '2026-10-03');

-- FINANCEIRO (saldo_atual recalculado ao final)
INSERT INTO conta_financeira (id_conta_fin, nome, tipo, saldo_atual) VALUES
  (1, 'Caixa TESTE', 'CAIXA', 0),
  (2, 'Banco TESTE', 'BANCO', 0),
  (3, 'Reserva de emergência TESTE', 'BANCO', 0);

INSERT INTO conta_a_receber (id_conta_receber, id_os, valor, percentual, parcela, data_vencimento, situacao) VALUES
  (1, 1, 2584.00, 40, 'ENTRADA', '2026-08-20', 'PAGA'),
  (2, 1, 3876.00, 60, 'FINAL', '2026-09-12', 'PAGA'),
  (3, 2, 1868.00, 40, 'ENTRADA', '2026-08-30', 'PAGA'),
  (4, 2, 2802.00, 60, 'FINAL', '2026-09-25', 'PAGA'),
  (5, 3, 1460.00, 40, 'ENTRADA', '2026-09-12', 'PAGA'),
  (6, 3, 2190.00, 60, 'FINAL', '2026-10-02', 'PAGA'),
  (7, 4, 1808.00, 40, 'ENTRADA', '2026-09-27', 'PAGA'),
  (8, 4, 2712.00, 60, 'FINAL', '2026-10-22', 'PARCIAL'),
  (9, 5, 2184.00, 40, 'ENTRADA', '2026-10-10', 'PAGA'),
  (10, 5, 3276.00, 60, 'FINAL', '2026-11-20', 'ABERTA'),
  (11, 6, 3120.00, 40, 'ENTRADA', '2026-10-18', 'PAGA'),
  (12, 6, 4680.00, 60, 'FINAL', '2026-11-30', 'ABERTA');

INSERT INTO recebimento (id_recebimento, id_conta_receber, numero_parcela, valor_pago, data_pagamento, forma_pagamento, multa, juros) VALUES
  (1, 1, NULL, 2584.00, '2026-08-20', 'PIX', 0, 0),
  (2, 2, NULL, 3876.00, '2026-09-12', 'BOLETO', 0, 0),
  (3, 3, NULL, 1868.00, '2026-08-30', 'DINHEIRO', 0, 0),
  (4, 4, NULL, 2802.00, '2026-09-25', 'PIX', 0, 0),
  (5, 5, NULL, 1460.00, '2026-09-12', 'PIX', 0, 0),
  (6, 6, NULL, 2190.00, '2026-10-08', 'BOLETO', 26.28, 10.00),
  (7, 7, NULL, 1808.00, '2026-09-27', 'PIX', 0, 0),
  (8, 8, 1, 1500.00, '2026-10-15', 'PIX', 0, 0),
  (9, 9, NULL, 2184.00, '2026-10-10', 'PIX', 0, 0),
  (10, 11, NULL, 3120.00, '2026-10-18', 'PIX', 0, 0);

INSERT INTO conta_a_pagar (id_conta_pagar, id_folha, id_contratacao, id_imposto, id_despesa, descricao, origem_tipo, valor_origem, data_vencimento, situacao) VALUES
  (1, NULL, 1, NULL, NULL, 'Contratação de terceirizada #1', 'CONTRATAÇÃO', 1800, '2026-11-15', 'ABERTA'),
  (2, NULL, 2, NULL, NULL, 'Contratação de terceirizada #2', 'CONTRATAÇÃO', 800, '2026-10-05', 'PAGA'),
  (3, NULL, 3, NULL, NULL, 'Contratação de terceirizada #3', 'CONTRATAÇÃO', 600, '2026-09-20', 'PAGA'),
  (4, 1, NULL, NULL, NULL, 'Folha 2026-08 func 1', 'FOLHA', 3045, '2026-09-05', 'PAGA'),
  (5, 2, NULL, NULL, NULL, 'Folha 2026-08 func 2', 'FOLHA', 2470, '2026-09-05', 'PAGA'),
  (6, 3, NULL, NULL, NULL, 'Folha 2026-09 func 1', 'FOLHA', 3045, '2026-10-05', 'PAGA'),
  (7, 4, NULL, NULL, NULL, 'Folha 2026-09 func 2', 'FOLHA', 2570, '2026-10-05', 'PAGA'),
  (8, 5, NULL, NULL, NULL, 'Folha 2026-10 func 1', 'FOLHA', 3045, '2026-11-05', 'ABERTA'),
  (9, 6, NULL, NULL, NULL, 'Folha 2026-10 func 2', 'FOLHA', 2620, '2026-11-05', 'ABERTA'),
  (10, NULL, NULL, 1, NULL, 'Imposto 2026-08', 'IMPOSTO', 267.12, '2026-09-20', 'PAGA'),
  (11, NULL, NULL, 2, NULL, 'Imposto 2026-09', 'IMPOSTO', 596.76, '2026-10-20', 'PAGA'),
  (12, NULL, NULL, 3, NULL, 'Imposto 2026-10', 'IMPOSTO', 539.64, '2026-11-20', 'ABERTA'),
  (13, NULL, NULL, NULL, 1, 'Aluguel do galpão - set/2026', 'DESPESA', 900, '2026-09-05', 'PAGA'),
  (14, NULL, NULL, NULL, 2, 'Aluguel do galpão - out/2026', 'DESPESA', 900, '2026-10-05', 'PAGA'),
  (15, NULL, NULL, NULL, 3, 'Energia elétrica - set/2026', 'DESPESA', 280, '2026-09-10', 'PAGA'),
  (16, NULL, NULL, NULL, 4, 'Energia elétrica - out/2026', 'DESPESA', 310, '2026-10-10', 'ABERTA'),
  (17, NULL, NULL, NULL, 5, 'Internet - set/2026', 'DESPESA', 120, '2026-09-10', 'PAGA'),
  (18, NULL, NULL, NULL, 6, 'Transporte de máquinas - out/2026', 'DESPESA', 260, '2026-10-03', 'PAGA'),
  (19, NULL, NULL, NULL, NULL, 'Pedido de compra #1', 'COMPRA', 3550, '2026-09-20', 'PAGA'),
  (20, NULL, NULL, NULL, NULL, 'Pedido de compra #2', 'COMPRA', 900.00, '2026-10-12', 'VENCIDA');

INSERT INTO pagamento (id_pagamento, id_conta_pagar, numero_parcela, valor_pago, data_pagamento, forma_pagamento, multa, juros) VALUES
  (1, 19, 1, 1775.00, '2026-08-20', 'TRANSFERÊNCIA', 0, 0),
  (2, 19, 2, 1775.00, '2026-09-20', 'TRANSFERÊNCIA', 0, 0),
  (3, 3, NULL, 600, '2026-09-20', 'PIX', 0, 0),
  (4, 2, NULL, 800, '2026-10-10', 'PIX', 8.00, 1.60),
  (5, 4, NULL, 3045, '2026-09-05', 'PIX', 0, 0),
  (6, 5, NULL, 2470, '2026-09-05', 'PIX', 0, 0),
  (7, 6, NULL, 3045, '2026-10-05', 'PIX', 0, 0),
  (8, 7, NULL, 2570, '2026-10-05', 'PIX', 0, 0),
  (9, 10, NULL, 267.12, '2026-09-20', 'BOLETO', 0, 0),
  (10, 11, NULL, 596.76, '2026-10-20', 'BOLETO', 0, 0),
  (11, 13, NULL, 900, '2026-09-05', 'PIX', 0, 0),
  (12, 14, NULL, 900, '2026-10-05', 'PIX', 0, 0),
  (13, 15, NULL, 280, '2026-09-10', 'PIX', 0, 0),
  (14, 17, NULL, 120, '2026-09-10', 'PIX', 0, 0),
  (15, 18, NULL, 260, '2026-10-03', 'PIX', 0, 0);

-- Vínculo pedido de compra → conta a pagar (origem COMPRA)
UPDATE pedido_compra SET id_conta_pagar = 19 WHERE id_pedido = 1;
UPDATE pedido_compra SET id_conta_pagar = 20 WHERE id_pedido = 2;

-- MOVIMENTAÇÕES FINANCEIRAS (valor = valor_pago + multa + juros — P17)
INSERT INTO movimentacao_financeira (id_mov_fin, id_conta_fin, id_recebimento, id_pagamento, tipo, data, valor, descricao, origem) VALUES
  (1, 2, 1, NULL, 'ENTRADA', '2026-08-20', 2584.00, 'Recebimento #1', 'RECEBIMENTO'),
  (2, 2, 2, NULL, 'ENTRADA', '2026-09-12', 3876.00, 'Recebimento #2', 'RECEBIMENTO'),
  (3, 1, 3, NULL, 'ENTRADA', '2026-08-30', 1868.00, 'Recebimento #3', 'RECEBIMENTO'),
  (4, 2, 4, NULL, 'ENTRADA', '2026-09-25', 2802.00, 'Recebimento #4', 'RECEBIMENTO'),
  (5, 2, 5, NULL, 'ENTRADA', '2026-09-12', 1460.00, 'Recebimento #5', 'RECEBIMENTO'),
  (6, 2, 6, NULL, 'ENTRADA', '2026-10-08', 2226.28, 'Recebimento #6', 'RECEBIMENTO'),
  (7, 2, 7, NULL, 'ENTRADA', '2026-09-27', 1808.00, 'Recebimento #7', 'RECEBIMENTO'),
  (8, 2, 8, NULL, 'ENTRADA', '2026-10-15', 1500.00, 'Recebimento #8', 'RECEBIMENTO'),
  (9, 2, 9, NULL, 'ENTRADA', '2026-10-10', 2184.00, 'Recebimento #9', 'RECEBIMENTO'),
  (10, 2, 10, NULL, 'ENTRADA', '2026-10-18', 3120.00, 'Recebimento #10', 'RECEBIMENTO'),
  (11, 2, NULL, 1, 'SAÍDA', '2026-08-20', 1775.00, 'Pagamento #1', 'PAGAMENTO'),
  (12, 2, NULL, 2, 'SAÍDA', '2026-09-20', 1775.00, 'Pagamento #2', 'PAGAMENTO'),
  (13, 2, NULL, 3, 'SAÍDA', '2026-09-20', 600, 'Pagamento #3', 'PAGAMENTO'),
  (14, 2, NULL, 4, 'SAÍDA', '2026-10-10', 809.60, 'Pagamento #4', 'PAGAMENTO'),
  (15, 2, NULL, 5, 'SAÍDA', '2026-09-05', 3045, 'Pagamento #5', 'PAGAMENTO'),
  (16, 2, NULL, 6, 'SAÍDA', '2026-09-05', 2470, 'Pagamento #6', 'PAGAMENTO'),
  (17, 2, NULL, 7, 'SAÍDA', '2026-10-05', 3045, 'Pagamento #7', 'PAGAMENTO'),
  (18, 2, NULL, 8, 'SAÍDA', '2026-10-05', 2570, 'Pagamento #8', 'PAGAMENTO'),
  (19, 2, NULL, 9, 'SAÍDA', '2026-09-20', 267.12, 'Pagamento #9', 'PAGAMENTO'),
  (20, 2, NULL, 10, 'SAÍDA', '2026-10-20', 596.76, 'Pagamento #10', 'PAGAMENTO'),
  (21, 2, NULL, 11, 'SAÍDA', '2026-09-05', 900, 'Pagamento #11', 'PAGAMENTO'),
  (22, 2, NULL, 12, 'SAÍDA', '2026-10-05', 900, 'Pagamento #12', 'PAGAMENTO'),
  (23, 2, NULL, 13, 'SAÍDA', '2026-09-10', 280, 'Pagamento #13', 'PAGAMENTO'),
  (24, 2, NULL, 14, 'SAÍDA', '2026-09-10', 120, 'Pagamento #14', 'PAGAMENTO'),
  (25, 2, NULL, 15, 'SAÍDA', '2026-10-03', 260, 'Pagamento #15', 'PAGAMENTO'),
  (26, 3, NULL, NULL, 'ENTRADA', '2026-09-01', 5000, 'Recomposição inicial da reserva', 'RESERVA'),
  (27, 3, NULL, NULL, 'SAÍDA', '2026-10-08', 800, 'Utilização da reserva - peça urgente', 'RESERVA');

INSERT INTO capital_emergencia (id_capital, id_conta_fin, valor_reserva, saldo_reserva, data_definicao, situacao) VALUES
  (1, 3, 5000, 4200, '2026-09-01', 'ATIVO');

INSERT INTO movimentacao_reserva (id_mov_reserva, id_capital, id_mov_fin, tipo, valor, motivo, data_solicitacao, data_aprovacao, situacao) VALUES
  (1, 1, 26, 'RECOMPOSIÇÃO', 5000, 'Constituição da reserva', '2026-08-30', '2026-09-01', 'EXECUTADA'),
  (2, 1, 27, 'UTILIZAÇÃO', 800, 'Peça urgente para OS em execução', '2026-10-07', '2026-10-07', 'EXECUTADA'),
  (3, 1, NULL, 'UTILIZAÇÃO', 1500, 'Imprevisto na máquina do cliente', '2026-10-27', NULL, 'SOLICITADA'),
  (4, 1, NULL, 'UTILIZAÇÃO', 2000, 'Despesa não prevista', '2026-10-15', '2026-10-16', 'REJEITADA'),
  (5, 1, NULL, 'RECOMPOSIÇÃO', 500, 'Reposição parcial', '2026-10-28', '2026-10-29', 'APROVADA');

-- Saldos das contas financeiras (CR3): recalculados a partir das movimentações efetivadas
UPDATE conta_financeira cf SET saldo_atual = COALESCE((SELECT SUM(CASE WHEN m.tipo='ENTRADA' THEN m.valor ELSE -m.valor END)
                                                        FROM movimentacao_financeira m WHERE m.id_conta_fin = cf.id_conta_fin),0);
UPDATE capital_emergencia ce SET saldo_reserva = (SELECT saldo_atual FROM conta_financeira cf WHERE cf.id_conta_fin = ce.id_conta_fin);

-- Ajusta as sequências das colunas IDENTITY após inserir IDs explícitos
DO $$
DECLARE r record;
BEGIN
  FOR r IN SELECT c.table_name, c.column_name FROM information_schema.columns c
           WHERE c.table_schema='public' AND c.is_identity='YES' LOOP
    EXECUTE format('SELECT setval(pg_get_serial_sequence(%L,%L), COALESCE((SELECT MAX(%I) FROM %I),0)+1, false)', r.table_name, r.column_name, r.column_name, r.table_name);
  END LOOP;
END $$;
COMMIT;
