#!/usr/bin/env bash
# Executa a sequência do manual: BANCO VAZIO → SCRIPT → TABELAS → RESTRIÇÕES → DADOS → CONSULTAS → VERIFICAÇÃO
# Uso:  ./run_all.sh [usuario_postgres]     (padrão: postgres)   |   saída em ../evidencias/
set -euo pipefail
cd "$(dirname "$0")"
U="${1:-postgres}"; EV=../evidencias; mkdir -p "$EV"
P="psql -X -v ON_ERROR_STOP=1 -U $U"
{
  echo "# Execução em $(date '+%Y-%m-%d %H:%M:%S %z') | $(psql --version)"
  echo "# [1/9] CREATE DATABASE (banco vazio)";            $P -d postgres -f ddl/01_create_database.sql
  echo "# [2/9] CREATE TABLE + PK/FK/UNIQUE/CHECK/DEFAULT";  $P -d erp_extrusoras -f ddl/02_create_tables.sql
  echo "# [3/9] Gatilhos de regras entre tabelas";           $P -d erp_extrusoras -f ddl/03_triggers.sql
  echo "# [4/9] INSERT — massa de dados";                    $P -d erp_extrusoras -f dados/04_massa_dados.sql
  echo "# [5/9] Verificação da estrutura";                   $P -d erp_extrusoras -f testes/09_verificacao_estrutura.sql
  echo "# [6/9] SELECT/JOIN/UPDATE/DELETE";                  $P -d erp_extrusoras -f consultas/05_dml_exemplos.sql
  echo "# [7/9] Consultas gerenciais";                       $P -d erp_extrusoras -f consultas/06_consultas_gerenciais.sql
  echo "# [8/9] Consultas de auditoria";                     $P -d erp_extrusoras -f auditoria/07_consultas_auditoria.sql
  echo "# [9/9] Testes de restrições";                       $P -d erp_extrusoras -f testes/08_testes_restricoes.sql
  echo "# FIM — sem erros (ON_ERROR_STOP)"
} 2>&1 | tee "$EV/execucao_completa.log"
