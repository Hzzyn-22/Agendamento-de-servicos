#!/bin/bash

PASTA="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PASTA" || exit 1

BASE="http://localhost:${PORT:-3016}"
RELATORIO="$PASTA/resultado_execucao.log"

if ! command -v jq >/dev/null 2>&1; then
    echo "Erro: instale o jq antes de executar os testes."
    exit 1
fi

if ! curl -s "$BASE/" >/dev/null; then
    echo "Erro: a API não está funcionando."
    echo "Execute primeiro: ./scripts/automacao.sh start"
    exit 1
fi

: > "$RELATORIO"

TOTAL=0
APROVADOS=0
REPROVADOS=0

registrar() {
    TOTAL=$((TOTAL + 1))

    if [ "$HTTP_CODE" = "$ESPERADO" ]; then
        APROVADOS=$((APROVADOS + 1))
        RESULTADO="APROVADO"
    else
        REPROVADOS=$((REPROVADOS + 1))
        RESULTADO="REPROVADO"
    fi

    {
        echo "Teste: $DESCRICAO"
        echo "Esperado: $ESPERADO | Recebido: $HTTP_CODE"
        echo "Resultado: $RESULTADO"
        echo "Resposta: $BODY"
        echo "----------------------------------------"
    } | tee -a "$RELATORIO"
}

requisicao() {
    METODO="$1"
    ROTA="$2"
    DADOS="$3"
    ESPERADO="$4"
    DESCRICAO="$5"

    if [ -n "$DADOS" ]; then
        RESPOSTA=$(curl -sS -w '\n%{http_code}' \
            -X "$METODO" "$BASE$ROTA" \
            -H "Content-Type: application/json" \
            -d "$DADOS")
    else
        RESPOSTA=$(curl -sS -w '\n%{http_code}' \
            -X "$METODO" "$BASE$ROTA")
    fi

    HTTP_CODE=$(printf '%s\n' "$RESPOSTA" | tail -n 1)
    BODY=$(printf '%s\n' "$RESPOSTA" | sed '$d')

    registrar
}

echo "INICIANDO TESTES DA API"
echo "Data: $(date)"
echo "----------------------------------------" | tee "$RELATORIO"

requisicao GET "/" "" 200 "Verificar funcionamento da API"

requisicao POST "/clientes" \
'{"nome":"Luis Henrique","email":"luis.teste@email.com","telefone":"11999999999"}' \
201 "Cadastrar cliente"

CLIENTE_ID=$(echo "$BODY" | jq -r '.id // empty')

if [ -z "$CLIENTE_ID" ]; then
    echo "Não foi possível obter o ID do cliente."
    exit 1
fi

requisicao GET "/clientes" "" 200 "Listar clientes"
requisicao GET "/clientes/$CLIENTE_ID" "" 200 "Buscar cliente por ID"

requisicao GET "/clientes?nome=Luis" "" 200 "Filtrar clientes por nome"

requisicao PUT "/clientes/$CLIENTE_ID" \
'{"telefone":"11888888888"}' \
200 "Atualizar cliente"

requisicao PATCH "/clientes/$CLIENTE_ID" \
'{"nome":"Luis Atualizado"}' \
200 "Atualizar parcialmente cliente"

requisicao POST "/clientes" \
'{"nome":"","email":"email-invalido"}' \
400 "Validar cadastro de cliente"

requisicao GET "/clientes/99999" "" 404 "Buscar cliente inexistente"

requisicao POST "/agendamentos" \
"{\"clienteId\":$CLIENTE_ID,\"servico\":\"Corte de cabelo\",\"data\":\"2026-11-10\",\"horario\":\"14:00\"}" \
201 "Cadastrar agendamento"

AGENDAMENTO_ID=$(echo "$BODY" | jq -r '.id // empty')

if [ -z "$AGENDAMENTO_ID" ]; then
    echo "Não foi possível obter o ID do agendamento."
    exit 1
fi

requisicao GET "/agendamentos" "" 200 "Listar agendamentos"

requisicao GET "/agendamentos/$AGENDAMENTO_ID" "" 200 "Buscar agendamento por ID"

requisicao GET "/agendamentos?status=pendente" "" 200 "Filtrar por status"

requisicao GET "/agendamentos?clienteId=$CLIENTE_ID" "" 200 "Filtrar por cliente"

requisicao PUT "/agendamentos/$AGENDAMENTO_ID" \
'{"status":"confirmado"}' \
200 "Atualizar status do agendamento"

requisicao PATCH "/agendamentos/$AGENDAMENTO_ID" \
'{"horario":"15:00"}' \
200 "Atualizar parcialmente agendamento"

requisicao POST "/agendamentos" \
'{"clienteId":99999,"servico":"Teste","data":"2026-11-10","horario":"14:00"}' \
400 "Validar cliente inexistente"

requisicao GET "/agendamentos/99999" "" 404 "Buscar agendamento inexistente"

requisicao DELETE "/agendamentos/$AGENDAMENTO_ID" "" 200 "Excluir agendamento"

requisicao DELETE "/clientes/$CLIENTE_ID" "" 200 "Excluir cliente"

requisicao GET "/clientes/$CLIENTE_ID" "" 404 "Confirmar exclusão do cliente"

{
    echo ""
    echo "========== RESULTADO FINAL =========="
    echo "Total de testes: $TOTAL"
    echo "Aprovados: $APROVADOS"
    echo "Reprovados: $REPROVADOS"
    echo "====================================="
} | tee -a "$RELATORIO"

if [ "$REPROVADOS" -gt 0 ]; then
    exit 1
fi
