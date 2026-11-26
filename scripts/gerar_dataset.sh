#!/bin/bash

URL_API="http://localhost:3016/agendamentos"
ARQUIVO_CSV="dataset_analitico.csv"

# [FLUXO] Extract: Consome os dados brutos de agendamentos direto da API
RESPOSTA=$(curl -s "$URL_API")

# [ERRO] Valida se a API respondeu e se o retorno é um JSON válido
if [ -z "$RESPOSTA" ] || ! echo "$RESPOSTA" | jq empty 2>/dev/null; then
    echo "Erro: Falha ao extrair JSON válido de $URL_API. Verifique se a API está rodando."
    exit 1
fi

# [TRANSF] Transform & Load: Normaliza o JSON e exporta para formato tabular CSV
echo "$RESPOSTA" | jq -r '
  (["ID","CLIENTE","SERVICO","DATA","STATUS"] | @csv),
  (.[] | [
    (.id // "N/A"),
    (.cliente // .cliente_nome // .clienteId // "N/A"),
    (.servico // "N/A"),
    (.data // "N/A"),
    (.status // "AGENDADO")
  ] | @csv)
' > "$ARQUIVO_CSV"

# [TRANSF] Agregação rápida para relatório estatístico no terminal
TOTAL=$(echo "$RESPOSTA" | jq 'length')
echo "=========================================="
echo " PIPELINE ETL CONCLUÍDO COM SUCESSO"
echo "=========================================="
echo "Total de registros extraídos: $TOTAL"
echo "Arquivo gerado: $ARQUIVO_CSV"
echo "------------------------------------------"
cat "$ARQUIVO_CSV"
