#!/bin/bash

BASE="http://localhost:${PORT:-3016}"

# Verificar se o jq está instalado
if ! command -v jq >/dev/null 2>&1; then
    echo "ERRO: jq não está instalado."
    exit 1
fi

# Buscar clientes
CLIENTES=$(curl -fsS "$BASE/clientes") || {
    echo "ERRO: Não foi possível consultar os clientes."
    echo "Verifique se a API está ligada."
    exit 1
}

# Buscar agendamentos
AGENDAMENTOS=$(curl -fsS "$BASE/agendamentos") || {
    echo "ERRO: Não foi possível consultar os agendamentos."
    exit 1
}

# Conferir se as respostas são listas JSON
if ! echo "$CLIENTES" | jq -e 'type == "array"' >/dev/null ||
   ! echo "$AGENDAMENTOS" | jq -e 'type == "array"' >/dev/null; then
    echo "ERRO: Resposta inválida da API."
    exit 1
fi

TOTAL=$(echo "$AGENDAMENTOS" | jq 'length')

echo ""
echo "=========================================="
echo "       SISTEMA DE AGENDAMENTO"
echo "=========================================="

if [ "$TOTAL" -eq 0 ]; then
    echo "Nenhum agendamento encontrado."
else
    jq -r --argjson clientes "$CLIENTES" '
        .[] as $a
        | ([ $clientes[] |
             select(.id == $a.clienteId) |
             .nome ][0] // "CLIENTE NÃO ENCONTRADO") as $nome
        | "------------------------------------------\n" +
          "CLIENTE: \($nome)\n" +
          "SERVIÇO: \($a.servico // "-")\n" +
          "DATA: \($a.data // "-")\n" +
          "HORÁRIO: \($a.horario // "-")\n" +
          "STATUS: \(
              if $a.status == "confirmado" then "CONFIRMADO (APROVADO)"
              elif $a.status == "pendente" then "PENDENTE"
              elif $a.status == "cancelado" then "CANCELADO"
              elif $a.status == "concluido" then "CONCLUÍDO"
              else ($a.status // "NÃO INFORMADO" | ascii_upcase)
              end
          )\n"
    ' <<< "$AGENDAMENTOS"
fi

echo "=========================================="
echo "TOTAL DE AGENDAMENTOS: $TOTAL"
echo "=========================================="
