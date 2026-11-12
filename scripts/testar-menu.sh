#!/bin/bash

PASTA="$(cd "$(dirname "$0")/.." && pwd)"
BASE="http://localhost:${PORT:-3016}"

VERDE='\033[1;32m'
VERMELHO='\033[1;31m'
AMARELO='\033[1;33m'
AZUL='\033[1;36m'
RESET='\033[0m'

# Liga a API automaticamente se estiver parada
if ! curl -s "$BASE/" >/dev/null; then
    bash "$PASTA/scripts/automacao.sh" start || exit 1
fi

rodar() {
    local TITULO="$1"
    local METODO="$2"
    local ROTA="$3"
    local DADOS="$4"
    local TMP=$(mktemp)

    echo -e "\n${AZUL}----------------------------------------------------${RESET}"
    echo -e "${AZUL}$TITULO${RESET}"

    if [ -n "$DADOS" ]; then
        echo -e "${AMARELO}Comando:${RESET} curl -i -X $METODO \"$BASE$ROTA\" -d '$DADOS'"
        STATUS=$(curl -sS -D - -o "$TMP" -X "$METODO" "$BASE$ROTA" \
            -H "Content-Type: application/json" -d "$DADOS" | grep -m1 "^HTTP/" | tr -d '\r')
    else
        echo -e "${AMARELO}Comando:${RESET} curl -i -X $METODO \"$BASE$ROTA\""
        STATUS=$(curl -sS -D - -o "$TMP" -X "$METODO" "$BASE$ROTA" | grep -m1 "^HTTP/" | tr -d '\r')
    fi

    if [[ "$STATUS" == *" 200 "* || "$STATUS" == *" 201 "* ]]; then
        echo -e "${AMARELO}Status:${RESET}  ${VERDE}$STATUS${RESET}"
    else
        echo -e "${AMARELO}Status:${RESET}  ${VERMELHO}$STATUS${RESET}"
    fi

    echo -e "${AMARELO}Saída:${RESET}"
    jq . "$TMP" 2>/dev/null || cat "$TMP"
    rm -f "$TMP"
}

t1_201() {
    rodar "1. POST /clientes -> Deve retornar 201 Created" \
        "POST" "/clientes" "{\"nome\":\"Teste Apresentacao\",\"email\":\"teste.$(date +%s)@email.com\",\"telefone\":\"11999999999\"}"
}

t2_200_query() {
    rodar "2. GET com Query Params -> Deve retornar 200 OK" \
        "GET" "/agendamentos?status=pendente" ""
}

t3_200_crud() {
    # Cria um cliente temporário para atualizar e excluir sem apagar seus dados reais
    ID=$(curl -s -X POST "$BASE/clientes" -H "Content-Type: application/json" \
        -d "{\"nome\":\"Temp\",\"email\":\"temp.$(date +%s)@email.com\"}" | jq -r '.id')

    rodar "3A. PATCH /clientes/$ID -> Deve retornar 200 OK" \
        "PATCH" "/clientes/$ID" '{"nome":"Temp Editado"}'

    rodar "3B. DELETE /clientes/$ID -> Deve retornar 200 OK" \
        "DELETE" "/clientes/$ID" ""
}

t4_400() {
    rodar "4. Validação de Payload -> Deve retornar 400 Bad Request" \
        "POST" "/clientes" '{"nome":"","email":"email-invalido"}'
}

t5_404() {
    rodar "5. Busca Inexistente -> Deve retornar 404 Not Found" \
        "GET" "/clientes/99999" ""
}

while true; do
    echo -e "\n===================================================="
    echo "       TESTE DOS REQUISITOS DO ITEM 1 (API)"
    echo "===================================================="
    echo " 1) [201 Created]     Cadastrar (POST)"
    echo " 2) [200 OK]          Query Params (?status=pendente)"
    echo " 3) [200 OK]          Atualizar e Excluir (PATCH/DELETE)"
    echo " 4) [400 Bad Request] Erro de validação de payload"
    echo " 5) [404 Not Found]   Erro de ID não encontrado"
    echo " 6) [TODOS]           Executar os 5 testes acima"
    echo " 0) Sair"
    echo "===================================================="
    read -rp "Escolha: " op

    case "$op" in
        1) t1_201 ;;
        2) t2_200_query ;;
        3) t3_200_crud ;;
        4) t4_400 ;;
        5) t5_404 ;;
        6) t1_201; t2_200_query; t3_200_crud; t4_400; t5_404 ;;
        0) exit 0 ;;
        *) echo -e "${VERMELHO}Opção inválida!${RESET}" ;;
    esac
done
