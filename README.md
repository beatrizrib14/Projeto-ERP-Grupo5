# ERP para manutenção e reparo de máquinas extrusoras balão

**Projeto Integrador — Modelagem de Dados · Ciência da Computação · UNICID · Grupo 5**

Banco de dados relacional (PostgreSQL 16) de um sistema ERP para uma empresa de manutenção, reparo e restauração de máquinas extrusoras balão: do modelo conceitual (DER) ao banco implementado, populado, consultado e testado.

| Indicador | Valor |
|---|---|
| Tabelas / colunas | 35 / 229 |
| Chaves primárias / estrangeiras | 35 / 51 |
| Restrições UNIQUE / CHECK | 15 / 64 |
| Gatilhos PL/pgSQL | 5 |
| Índices (em FKs não UNIQUE) | 43 |
| Registros da massa de teste | 292 |
| Consultas gerenciais / de auditoria | 13 / 21 |
| Testes de restrição | 43 (43 conformes, 0 falhas) |

## Sumário

1. [Identificação do projeto](#1-identificação-do-projeto)
2. [Sobre o projeto](#2-sobre-o-projeto)
3. [Problema identificado](#3-problema-identificado)
4. [Objetivos](#4-objetivos)
5. [Escopo do sistema](#5-escopo-do-sistema)
6. [Fluxo operacional](#6-fluxo-operacional)
7. [Tecnologias utilizadas](#7-tecnologias-utilizadas)
8. [Modelagem conceitual — DER](#8-modelagem-conceitual--der)
9. [Modelo lógico relacional](#9-modelo-lógico-relacional)
10. [Normalização](#10-normalização)
11. [Dicionário de dados](#11-dicionário-de-dados)
12. [Modelo físico](#12-modelo-físico)
13. [Estrutura do banco de dados](#13-estrutura-do-banco-de-dados)
14. [Scripts SQL](#14-scripts-sql)
15. [Massa de dados, testes e evidências](#15-massa-de-dados-testes-e-evidências)
16. [Consultas gerenciais e de auditoria](#16-consultas-gerenciais-e-de-auditoria)
17. [Como executar o projeto](#17-como-executar-o-projeto)
Pendências registradas: [ao final do documento](#pendências-registradas)

---

## 1. Identificação do projeto

| Campo | Informação |
|---|---|
| Projeto | Projeto Integrador — Modelagem de Dados |
| Estudo de caso | ERP de uma empresa de manutenção de máquinas extrusoras balão |
| Instituição | Universidade Cidade de São Paulo (UNICID) |
| Curso | Ciência da Computação |
| Grupo | 5 |
| Etapa | Entrega final (2026) |

## 2. Sobre o projeto

A entrega final evolui a primeira entrega do grupo (nota 7,0). O trabalho revisou o DER, consolidou o modelo lógico aprovado (revisão 3), analisou a normalização, produziu o dicionário de dados e o modelo físico, e implementou o banco em PostgreSQL 16 com massa de dados, consultas e testes executados.

O relatório completo é o documento de referência do projeto: [`Entrega_Final_Grupo5_Revisada.pdf`](docs/revisao-modelagem/Entrega_Final_Grupo5_Revisada.pdf) (versão em [DOCX](docs/revisao-modelagem/Entrega_Final_Grupo5_Revisada.docx)). Este README resume o conteúdo e indica onde cada artefato está.

## 3. Problema identificado

A empresa estudada é enxuta (um proprietário e um funcionário). Segundo a caracterização da primeira entrega e o fluxograma da empresa:

- as solicitações dos clientes chegam por WhatsApp;
- as informações ficam distribuídas entre conversas e planilhas, com retrabalho e risco de divergência;
- cada serviço passa por inspeção, orçamento (com possíveis renegociações), execução própria ou terceirizada e cobrança em duas parcelas (40% e 60%);
- é preciso controlar compras, estoque, folha de pagamento, despesas, impostos e capital de emergência.

Não havia um registro único que ligasse cliente, máquina, atendimento, serviço executado e movimentação financeira.

## 4. Objetivos

**Objetivo geral.** Modelar e implementar um banco de dados relacional que centralize e dê rastreabilidade às operações da empresa, da solicitação do cliente à entrega da máquina e ao respectivo fluxo financeiro.

**Objetivos específicos**

1. Revisar a primeira entrega e atender aos cinco apontamentos da devolutiva (SOLICITAÇÃO/FUNCIONÁRIO, integração financeira, itens de orçamento e de ordem de serviço, versões do orçamento e cardinalidades).
2. Consolidar o DER e o modelo lógico relacional (35 tabelas).
3. Verificar a normalização até a 3FN e registrar as hipóteses que dependem da empresa.
4. Elaborar o dicionário de dados e o modelo físico em PostgreSQL 16.
5. Implementar o banco por scripts SQL reproduzíveis, a partir de banco vazio.
6. Validar o banco com massa de dados, consultas gerenciais, consultas de auditoria e testes de restrições.

## 5. Escopo do sistema

O modelo cobre cinco módulos (35 tabelas, 229 atributos):

| Módulo | Tabelas | Atributos | Conteúdo |
|---|---|---|---|
| Manutenção e operações | 10 | 70 | cliente, máquina, solicitação, orçamento (versões e itens), ordem de serviço (itens), inspeção, movimentação de máquina, serviço |
| Terceirização | 3 | 20 | terceirizada, cotação, contratação |
| Compras e estoque | 7 | 37 | fornecedor, material, pedido de compra, itens, recebimento de compra, movimentação de estoque |
| Financeiro | 10 | 72 | contas a receber e a pagar, recebimento, pagamento, movimentação financeira, conta financeira, imposto, despesa, capital de emergência, movimentação de reserva |
| Recursos humanos | 5 | 30 | funcionário, benefício, funcionário_benefício, folha de pagamento, encargo |

**Fora do escopo desta versão:** perfis de acesso (RF21) e trilha de alterações (RF22) não estão implementados — pendência P14 do relatório.

A distribuição por módulo segue o Cap. 5 do relatório.

## 6. Fluxo operacional

Fluxo principal da empresa, conforme o fluxograma unificado ([`fluxograma_unificado.png`](docs/diagramas/fluxograma_unificado.png)):

1. **Solicitação** do cliente (registrada com cliente, máquina e, opcionalmente, o funcionário que atendeu).
2. **Orçamento**, com versão numerada e itens (serviço ou material); renegociações geram novas versões.
3. **Aprovação** e cobrança da **entrada (40%)**.
4. **Inspeção** da máquina e abertura da **ordem de serviço**.
5. **Execução** interna e/ou **terceirização** (cotação, contratação e movimentação da máquina).
6. **Conferência** do serviço.
7. Cobrança do **saldo final (60%)** e **entrega** da máquina.

Em paralelo, o sistema trata compras e estoque, folha de pagamento, despesas, impostos e o capital de emergência, todos refletidos em contas a pagar e movimentações financeiras.

## 7. Tecnologias utilizadas

| Tecnologia | Uso | Comprovação |
|---|---|---|
| PostgreSQL 16 (UTF8) | SGBD de todo o projeto: DDL, dados, consultas, testes | scripts em [`sql/`](sql/) e log em [`evidencias/execucao_completa.log`](evidencias/execucao_completa.log) (PostgreSQL 16.15) |
| PL/pgSQL | cinco gatilhos de regras entre tabelas | [`sql/ddl/03_triggers.sql`](sql/ddl/03_triggers.sql) |
| psql e Bash | execução automatizada dos nove scripts | [`sql/run_all.sh`](sql/run_all.sh) |
| DBeaver 26.2.3 | execução dos scripts e geração do diagrama ER pelo grupo, conforme exigência do professor | scripts adaptados em [`sql_dbeaver/`](sql_dbeaver/) e guia [`LEIA-ME_DBeaver.md`](sql_dbeaver/LEIA-ME_DBeaver.md) |
| Python | gerador determinístico da massa de dados | [`docs/ia/gen_seed.py`](docs/ia/gen_seed.py) |
| Claude (Anthropic) | assistente na geração dos scripts e da massa de dados; a responsabilidade técnica é do grupo | [`docs/ia/prompts_massa_dados.md`](docs/ia/prompts_massa_dados.md) |

## 8. Modelagem conceitual — DER

O DER (notação Chen) é o da primeira entrega após as correções das etapas anteriores, e corresponde ao modelo lógico: as relações R01 a R52 (sem R07, removida) equivalem às 51 chaves estrangeiras. As alterações em relação à primeira entrega estão justificadas no Cap. 2 do relatório.

| Arquivo | Descrição |
|---|---|
| [`docs/diagramas/DER_Final.png`](docs/diagramas/DER_Final.png) | DER final (fundo escuro) |
| [`docs/diagramas/DER_Final.svg`](docs/diagramas/DER_Final.svg) | versão vetorial |
| [`docs/diagramas/DER_Final_branco.png`](docs/diagramas/DER_Final_branco.png) | versão em fundo branco, para impressão |
| [`docs/diagramas/DER_Final_branco.svg`](docs/diagramas/DER_Final_branco.svg) | versão vetorial em fundo branco |
| [`docs/diagramas/fluxograma_unificado.png`](docs/diagramas/fluxograma_unificado.png) | fluxograma unificado da empresa |
| [`docs/primeira-entrega/ERP_Modelo_original_clovis_.pdf`](docs/primeira-entrega/ERP_Modelo_original_clovis_.pdf) | primeira entrega (modelo original) |

## 9. Modelo lógico relacional

O modelo lógico aprovado (revisão 3) tem **35 tabelas, 51 chaves estrangeiras e 229 colunas**. O Cap. 3 do relatório lista, por tabela, a PK, as FKs e as restrições UNIQUE.

| Arquivo | Descrição |
|---|---|
| [`docs/modelo-logico/Modelo_Logico_Relacional.png`](docs/modelo-logico/Modelo_Logico_Relacional.png) | diagrama (fundo escuro) |
| [`docs/modelo-logico/Modelo_Logico_Relacional.svg`](docs/modelo-logico/Modelo_Logico_Relacional.svg) | versão vetorial |
| [`docs/modelo-logico/MLR_branco.png`](docs/modelo-logico/MLR_branco.png) | versão em fundo branco |
| [`docs/modelo-logico/MLR_branco.svg`](docs/modelo-logico/MLR_branco.svg) | versão vetorial em fundo branco |
| [`docs/modelo-logico/Modelo_Logico_Relacional.docx`](docs/modelo-logico/Modelo_Logico_Relacional.docx) | modelo lógico em documento editável |

## 10. Normalização

Análise completa em [`docs/normalizacao/Normalizacao_Modelo_Logico.pdf`](docs/normalizacao/Normalizacao_Modelo_Logico.pdf) ([DOCX](docs/normalizacao/Normalizacao_Modelo_Logico.docx)); síntese no Cap. 4 do relatório.

| Forma normal | Conclusão |
|---|---|
| 1FN | As 35 tabelas atendem. Listas do negócio (itens, benefícios, cotações, encargos, parcelas) estão em tabelas próprias. Ressalva: H1 e H2 (vários telefones, endereços, contatos ou especialidades). |
| 2FN | Todas as PKs são de coluna única, logo não há dependência parcial em relação à PK. As chaves candidatas compostas, como (id_solicitacao, versao) e (id_os, parcela), foram examinadas sem dependência parcial. |
| 3FN | Nenhuma violação é confirmada pelos documentos. Cinco casos dependem de hipóteses (H3 a H7) e quatro redundâncias são controladas (CR1 a CR4). Nenhuma decomposição foi aplicada. |

As redundâncias controladas são protegidas por CHECK e gatilhos (`ck_cap_origem`, `ck_mov_estoque_origem`, `trg_os_regras`) e monitoradas pelas consultas de auditoria A07, A09 e A13 a A17.

**Hipóteses a validar com a empresa:** H1 a H8 (ver Cap. 4.2 do relatório). Enquanto não validadas, permanecem como pendências.

## 11. Dicionário de dados

O dicionário descreve as 35 tabelas e os 229 atributos (descrição, tipo, PK, FK, NULL, UNIQUE, DEFAULT, CHECK e regra). Foi gerado do mesmo código que produz o DDL, por isso é coerente com o banco: o catálogo confirma 229 colunas.

| Arquivo | Conteúdo |
|---|---|
| [`docs/dicionario-dados/dicionario_dados.csv`](docs/dicionario-dados/dicionario_dados.csv) | dicionário completo em CSV |
| Cap. 5 do relatório | síntese por módulo |
| Anexo C do [`Anexos_Tecnicos_Grupo5.pdf`](docs/anexos/Anexos_Tecnicos_Grupo5.pdf) | dicionário completo formatado (páginas 17 a 71; ver [índice dos anexos](docs/anexos/00_INDICE.md)) |

## 12. Modelo físico

SGBD: **PostgreSQL 16**. Nenhuma decisão física altera a estrutura conceitual do modelo lógico. Descrição resumida em [`docs/modelo-fisico/modelo_fisico.md`](docs/modelo-fisico/modelo_fisico.md); justificativas no Cap. 6 do relatório.

| Código | Decisão |
|---|---|
| D-F1 | Nomes físicos em minúsculas e sem acento; colunas mantêm os nomes do modelo lógico |
| D-F2 | PK substituta `INTEGER GENERATED BY DEFAULT AS IDENTITY`; chaves naturais viram UNIQUE |
| D-F3 | Valores monetários `NUMERIC(14,2)`; alíquota `(6,3)`; percentual `(5,2)`; quantidades `(12,3)` |
| D-F4 | CHECK de valor monetário não negativo (exceto saldos) |
| D-F5 | Datas em `DATE`; data e hora em `TIMESTAMP`; competência como `DATE` no dia 1 |
| D-F6 | Domínios documentados viram `CHECK ... IN (...)`; domínios não documentados ficam livres (P11) |
| D-F7 | 51 FKs com `ON UPDATE CASCADE` e `ON DELETE RESTRICT`; índice em cada FK não UNIQUE (43) |
| D-F8 | Cinco regras entre tabelas implementadas por gatilhos PL/pgSQL |
| D-F9 | Regras circulares ou pendentes (origem COMPRA e pedido, origem única da movimentação, uma versão aprovada por solicitação) ficam em consultas de auditoria |

## 13. Estrutura do banco de dados

Totais verificados no catálogo do PostgreSQL pelo script `09_verificacao_estrutura.sql`:

| Elemento | Quantidade |
|---|---|
| Tabelas | 35 |
| Colunas | 229 |
| Chaves primárias | 35 |
| Chaves estrangeiras | 51 (todas `ON DELETE RESTRICT`, `ON UPDATE CASCADE`) |
| Restrições UNIQUE | 15 |
| Restrições CHECK | 64 |
| Índices em FKs não UNIQUE | 43 |
| Gatilhos | 5 |

**Gatilhos (PL/pgSQL)**

| Gatilho | Tabela | Regra protegida |
|---|---|---|
| `trg_os_regras` | `ordem_servico` | O orçamento deve estar APROVADO e a máquina da OS deve ser a da solicitação do orçamento |
| `trg_item_receb_pedido` | `item_recebimento` | O item recebido pertence ao pedido do recebimento |
| `trg_mov_estoque_material` | `movimentacao_estoque` | Em ENTRADA, o material é o do item de pedido recebido |
| `trg_mov_reserva_conta` | `movimentacao_reserva` | A conta da movimentação financeira é a do capital de emergência |
| `trg_orcamento_historico` | `orcamento` | Impede apagar versão e trocar solicitação ou versão (preserva o histórico) |

> **Divergência registrada.** O Cap. 6 do relatório descreve `trg_os_regras` como "BEFORE INSERT OR UPDATE". No script [`03_triggers.sql`](sql/ddl/03_triggers.sql) o gatilho dispara em `BEFORE INSERT OR UPDATE OF id_orcamento, id_maquina`. O banco e os 43 testes seguem o script; a redação do relatório e o script devem ser harmonizados por decisão do grupo.

## 14. Scripts SQL

Os nove scripts estão em [`sql/`](sql/). A ordem abaixo é a numeração dos arquivos; o executor automático [`run_all.sh`](sql/run_all.sh) roda o 09 logo após o 04 (ver seção [17](#17-como-executar-o-projeto)).

| Nº | Arquivo | Finalidade |
|---|---|---|
| 01 | [`sql/ddl/01_create_database.sql`](sql/ddl/01_create_database.sql) | Cria o banco `erp_extrusoras` (UTF8), removendo antes um banco de mesmo nome |
| 02 | [`sql/ddl/02_create_tables.sql`](sql/ddl/02_create_tables.sql) | 35 `CREATE TABLE` com PK, UNIQUE, CHECK, NOT NULL, DEFAULT; 51 FKs; 43 índices |
| 03 | [`sql/ddl/03_triggers.sql`](sql/ddl/03_triggers.sql) | 5 gatilhos PL/pgSQL |
| 04 | [`sql/dados/04_massa_dados.sql`](sql/dados/04_massa_dados.sql) | `INSERT` em todas as tabelas, recálculo dos saldos e ajuste das sequências |
| 05 | [`sql/consultas/05_dml_exemplos.sql`](sql/consultas/05_dml_exemplos.sql) | `SELECT`, `JOIN`, `INSERT`, `UPDATE` e `DELETE` em transação revertida (`ROLLBACK`) |
| 06 | [`sql/consultas/06_consultas_gerenciais.sql`](sql/consultas/06_consultas_gerenciais.sql) | 13 consultas gerenciais |
| 07 | [`sql/auditoria/07_consultas_auditoria.sql`](sql/auditoria/07_consultas_auditoria.sql) | 21 consultas de auditoria |
| 08 | [`sql/testes/08_testes_restricoes.sql`](sql/testes/08_testes_restricoes.sql) | 43 testes de restrições e de sensibilidade da auditoria, sem alterar dados persistentes |
| 09 | [`sql/testes/09_verificacao_estrutura.sql`](sql/testes/09_verificacao_estrutura.sql) | Contagens do catálogo, regras das FKs e linhas por tabela |

## 15. Massa de dados, testes e evidências

**Massa de dados.** Os dados são fictícios (prefixo `TESTE`), com CNPJ e CPF sintéticos sem validade fiscal e sem dado pessoal real. A carga é gerada por script determinístico ([`docs/ia/gen_seed.py`](docs/ia/gen_seed.py)), que calcula totais, parcelas de 40% e 60%, folha, impostos e saldos para manter a coerência entre tabelas. O resultado é o arquivo [`04_massa_dados.sql`](sql/dados/04_massa_dados.sql): **292 registros em 35 tabelas**, todas com dados.

| Grupo | Cobertura da massa |
|---|---|
| Operação | 6 clientes, 9 máquinas, 10 solicitações, 9 inspeções, 11 orçamentos (inclui versões), 6 OS com 16 itens |
| Terceirização | 3 terceirizadas, 6 cotações, 3 contratações, 16 movimentações de máquina |
| Compras e estoque | 2 pedidos, 3 recebimentos (um parcial), 14 movimentações de estoque |
| Financeiro | 20 contas a pagar, 15 pagamentos, 12 contas a receber, 10 recebimentos, 27 movimentações financeiras |
| Recursos humanos e administrativo | 2 funcionários, 6 folhas, 12 encargos, 3 impostos, 6 despesas, 1 reserva com 5 movimentos |

**Resultados verificados**

| Verificação | Resultado |
|---|---|
| Execução integral a partir de banco vazio (`psql -v ON_ERROR_STOP=1`, PostgreSQL 16.15) | nenhum erro nos nove passos |
| Estrutura | 35 tabelas, 229 colunas, 35 PKs, 51 FKs, 15 UNIQUE, 64 CHECK, 5 gatilhos |
| Carga | 292 registros sem violação |
| Consultas de auditoria | 0 linhas nas 19 consultas de integridade; 2 informativas (A03 e A20) |
| Testes de restrições | 43 de 43 conformes, 0 falhas |

O log integral dessa execução está em [`evidencias/execucao_completa.log`](evidencias/execucao_completa.log). O Anexo H do [`Anexos_Tecnicos_Grupo5.pdf`](docs/anexos/Anexos_Tecnicos_Grupo5.pdf) traz os testes por restrição e o log (páginas 159 a 185).

**Execução no DBeaver.** O grupo executou os scripts adaptados de [`sql_dbeaver/`](sql_dbeaver/) no DBeaver 26.2.3, sobre PostgreSQL 16, em 30/10/2026, e obteve as mesmas contagens (35 tabelas, 229 colunas, 35 PKs, 51 FKs, 15 UNIQUE, 64 CHECK, 5 gatilhos, 292 registros e 43 testes OK com 0 falhas), além do diagrama ER gerado pela própria ferramenta. As capturas de tela dessa execução ainda precisam ser adicionadas ao repositório (ver [Pendências registradas](#pendências-registradas)).

**Limites.** Foram testados apenas o PostgreSQL 16 (16.15 no ambiente de elaboração e a versão instalada no DBeaver do grupo); desempenho e concorrência não foram avaliados; a massa é pequena e fictícia.

## 16. Consultas gerenciais e de auditoria

### Consultas gerenciais (13) — [`06_consultas_gerenciais.sql`](sql/consultas/06_consultas_gerenciais.sql)

| Cód. | Pergunta do gestor |
|---|---|
| G01 | Quantas ordens de serviço foram abertas por mês? |
| G02 | Quais ordens de serviço estão em andamento e há quantos dias? |
| G03 | Quais serviços são mais executados e quanto faturam? |
| G04 | Quais máquinas têm maior recorrência de manutenção? |
| G05 | Quais clientes mais solicitam serviços e quantos orçamentos aprovaram? |
| G06 | Quais materiais estão com estoque abaixo do mínimo? |
| G07 | Quanto foi comprado por mês e de quais fornecedores? |
| G08 | Quanto se gasta por categoria de despesa administrativa? |
| G09 | Quanto há a pagar e a receber em aberto? |
| G10 | Quanto foi recebido e pago por mês (movimentações efetivadas)? |
| G11 | Quanto foi contratado com cada terceirizada? |
| G12 | Qual o desempenho financeiro por mês (entradas, saídas e resultado)? |
| G13 | Qual o fluxo financeiro vinculado a cada OS? (rastreabilidade pedida na devolutiva) |

### Consultas de auditoria (21) — [`07_consultas_auditoria.sql`](sql/auditoria/07_consultas_auditoria.sql)

Cada consulta devolve as linhas que merecem verificação; "0 linhas" indica ausência da inconsistência. A03 e A20 são informativas.

| Cód. | Verificação |
|---|---|
| A01 | Orçamentos aprovados sem ordem de serviço |
| A02 | OS sem itens ou sem as duas parcelas a receber (entrada e final) |
| A03 | (informativa) Contas a pagar vencidas e não quitadas na data de referência |
| A04 | OS com informações incompletas ou datas fora de ordem |
| A05 | Movimentações financeiras sem origem válida |
| A06 | Movimentações de estoque sem origem válida |
| A07 | Valor da movimentação diferente de valor pago + multa + juros |
| A08 | Pagamentos e recebimentos sem movimentação financeira correspondente |
| A09 | Saldo armazenado da conta diferente do saldo calculado |
| A10 | Saldo de estoque negativo |
| A11 | Quantidade recebida maior que a pedida |
| A12 | Duplicidades de CPF/CNPJ e de número de série |
| A13 | Orçamento com total diferente da soma dos itens |
| A14 | Item de OS com total diferente de quantidade × valor unitário |
| A15 | Pedido de compra com total diferente da soma dos itens |
| A16 | Máquina da OS diferente da máquina da solicitação ou da inspeção |
| A17 | Conta a pagar com valor de origem diferente do documento de origem |
| A18 | Situação PAGA/ABERTA incoerente com os pagamentos e recebimentos |
| A19 | Contratação de cotação não aprovada ou com valor diferente do proposto |
| A20 | (informativa) Solicitações com mais de uma versão de orçamento aprovada |
| A21 | Chaves estrangeiras não validadas |

SQL e leitura de cada resultado: Anexos F e G do [`Anexos_Tecnicos_Grupo5.pdf`](docs/anexos/Anexos_Tecnicos_Grupo5.pdf) e Cap. 10 e 11 do relatório.

## 17. Como executar o projeto

### Pré-requisitos

- PostgreSQL 16 instalado e em execução (porta padrão 5432).
- Um usuário com permissão para criar bancos (por exemplo, `postgres`).
- Para a execução automática: `psql` no PATH e um terminal Bash (Linux, macOS ou Git Bash no Windows).
- Para a execução no DBeaver: DBeaver 26.2.3 (ou compatível) com o driver do PostgreSQL.

> **Atenção.** O script `01_create_database.sql` executa `DROP DATABASE IF EXISTS erp_extrusoras`. Se já existir um banco com esse nome, ele será apagado.

### Opção A — execução automática (psql)

```bash
cd sql
./run_all.sh postgres
```

O argumento é o usuário do PostgreSQL (padrão: `postgres`). O script usa `psql -X -v ON_ERROR_STOP=1`, interrompe no primeiro erro e grava o log em `evidencias/execucao_completa.log`. Ordem executada:

| Passo | Arquivo | Banco de destino |
|---|---|---|
| 1 | `ddl/01_create_database.sql` | `postgres` |
| 2 | `ddl/02_create_tables.sql` | `erp_extrusoras` |
| 3 | `ddl/03_triggers.sql` | `erp_extrusoras` |
| 4 | `dados/04_massa_dados.sql` | `erp_extrusoras` |
| 5 | `testes/09_verificacao_estrutura.sql` | `erp_extrusoras` |
| 6 | `consultas/05_dml_exemplos.sql` | `erp_extrusoras` |
| 7 | `consultas/06_consultas_gerenciais.sql` | `erp_extrusoras` |
| 8 | `auditoria/07_consultas_auditoria.sql` | `erp_extrusoras` |
| 9 | `testes/08_testes_restricoes.sql` | `erp_extrusoras` |

### Opção B — execução manual (psql)

A partir da pasta `sql/`:

```bash
psql -U postgres -d postgres       -f ddl/01_create_database.sql
psql -U postgres -d erp_extrusoras -f ddl/02_create_tables.sql
psql -U postgres -d erp_extrusoras -f ddl/03_triggers.sql
psql -U postgres -d erp_extrusoras -f dados/04_massa_dados.sql
psql -U postgres -d erp_extrusoras -f testes/09_verificacao_estrutura.sql
psql -U postgres -d erp_extrusoras -f consultas/05_dml_exemplos.sql
psql -U postgres -d erp_extrusoras -f consultas/06_consultas_gerenciais.sql
psql -U postgres -d erp_extrusoras -f auditoria/07_consultas_auditoria.sql
psql -U postgres -d erp_extrusoras -f testes/08_testes_restricoes.sql
```

Os scripts da pasta `sql/` usam comandos exclusivos do psql (`\echo`), portanto devem ser executados pelo psql e não por outros clientes.

### Opção C — DBeaver

Os scripts da pasta [`sql_dbeaver/`](sql_dbeaver/) têm o mesmo conteúdo SQL, sem os comandos exclusivos do psql. Passo a passo completo em [`sql_dbeaver/LEIA-ME_DBeaver.md`](sql_dbeaver/LEIA-ME_DBeaver.md). Resumo:

1. Crie uma conexão PostgreSQL (`localhost`, `5432`, banco `postgres`).
2. Com a conexão ao banco `postgres`, execute `ddl/01_create_database.sql` como script (**Alt+X**).
3. Atualize a lista de bancos (F5) e conecte-se ao banco `erp_extrusoras` (o banco ativo aparece na barra de ferramentas).
4. Nesse banco, execute com **Alt+X**, nesta ordem: `02`, `03`, `04`, `09`, `05`, `06`, `07` e `08`.
5. Para gerar o diagrama ER: clique com o botão direito em `public` (esquema), escolha **Visualizar diagrama** e salve como imagem.

Observação: o script `03_triggers.sql` não remove gatilhos existentes; se for executado duas vezes, o PostgreSQL retorna o erro `42710` (gatilho já existe). Nesse caso basta não repetir o script ou remover os gatilhos antes (`DROP TRIGGER IF EXISTS ...`).

### Verificação do resultado

Após a carga, o script `09_verificacao_estrutura.sql` deve retornar:

| tabelas | colunas | pks | fks | uniques | checks | gatilhos |
|---|---|---|---|---|---|---|
| 35 | 229 | 35 | 51 | 15 | 64 | 5 |

A consulta de linhas por tabela soma **292** registros. O script `08_testes_restricoes.sql` deve exibir **43 testes OK e 0 falhas**, e as consultas de auditoria (exceto A03 e A20) devem retornar 0 linhas.

## Pendências registradas

Pendências e divergências declaradas no relatório final, que não devem ser consideradas concluídas:

| Item | Situação |
|---|---|
| Histórico de commits | PENDENTE — depende de o grupo versionar o repositório |
| Evidências colaborativas e contribuição de todos os integrantes | PENDENTE — depende do grupo |
| Apresentação e defesa final | PENDENTE — manual específico não fornecido |
| Hipóteses H1 a H8 (normalização) | A validar com a empresa |
| Domínios livres (P11), perfis de acesso e trilha de alterações (P14/PF3), uma versão aprovada por solicitação (P20), atributos da primeira entrega ausentes no modelo (P22) | A validar com a empresa e o professor |
| Devolutiva original da primeira entrega (D1) | Não anexada; apontamentos usados conforme descritos no pedido |

Itens de repositório ainda a incluir pelo grupo: capturas de tela da execução no DBeaver (estrutura, 43 testes e diagrama ER) e o conteúdo da pasta `apresentacao/`.

---

*Projeto Integrador — Modelagem de Dados · Grupo 5 · UNICID · 2026*
