#!/bin/bash

# [FLUXO] Definindo endpoints da API na porta 3016 e arquivo CSV de destino
API_AG="http://localhost:3016/agendamentos"
API_CLI="http://localhost:3016/clientes"
CSV_OUT="dataset_analitico.csv"

./scripts/automacao.sh start >/dev/null 2>&1

echo "[FLUXO] Extraindo dados brutos da API..."
DADOS_JSON=$(curl -s "$API_AG")
CLIENTES_JSON=$(curl -s "$API_CLI")

# [ERRO] Verificando se a API respondeu com conteúdo válido
if [ -z "$DADOS_JSON" ] || [ "$DADOS_JSON" == "[]" ] || ! echo "$DADOS_JSON" | jq -e . >/dev/null 2>&1; then
  echo "[ERRO] Falha na extração: API offline ou sem registros."
  exit 1
fi

# [TRANSF] Cruzando clienteId com o nome e convertendo JSON para CSV tabular usando jq
echo "[TRANSF] Transformando JSON em CSV analítico..."
echo "$DADOS_JSON" | jq -r --argjson clis "$CLIENTES_JSON" '
  ($clis | map({(.id | tostring): .nome}) | add // {}) as $mapa |
  (["ID","CLIENTE","SERVICO","DATA","HORARIO","STATUS"] | @csv),
  (.[] | [
    .id,
    ($mapa[.clienteId | tostring] // "Desconhecido"),
    (.servico | ascii_upcase),
    .data,
    .horario,
    (.status | ascii_upcase)
  ] | @csv)
' > "$CSV_OUT"

echo "[SUCESSO] Dataset gerado em $CSV_OUT:"
column -t -s ',' "$CSV_OUT"
