#!/bin/bash

PASTA="$(cd "$(dirname "$0")/.." && pwd)"
BASE="http://localhost:${PORT:-3016}"

# 1. Garante que curl e jq estão instalados
for cmd in curl jq; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "Erro: instale o '$cmd' primeiro (sudo apt install $cmd)"
        exit 1
    fi
done

# 2. Liga a API automaticamente se estiver desligada
if ! curl -s "$BASE/" >/dev/null; then
    echo "API desligada. Iniciando..."
    bash "$PASTA/scripts/automacao.sh" start || exit 1
fi

# --- FUNÇÕES ---

listar_clientes() {
    echo -e "\n--- CLIENTES ---"
    curl -s "$BASE/clientes" | jq -r '.[] | "ID: \(.id) | \(.nome) (\(.email))"'
}

novo_cliente() {
    read -rp "Nome do cliente: " nome
    read -rp "E-mail: " email
    read -rp "Telefone: " tel

    JSON=$(jq -n --arg n "$nome" --arg e "$email" --arg t "$tel" '{nome:$n, email:$e, telefone:$t}')
    curl -s -X POST "$BASE/clientes" -H "Content-Type: application/json" -d "$JSON" | jq .
}

listar_agendamentos() {
    CLIENTES=$(curl -s "$BASE/clientes")
    AGENDAMENTOS=$(curl -s "$BASE/agendamentos")

    echo -e "\n================ AGENDAMENTOS ================"
    if [ "$(echo "$AGENDAMENTOS" | jq 'length')" -eq 0 ]; then
        echo "Nenhum agendamento cadastrado."
        return
    fi

    jq -r --argjson c "$CLIENTES" '
        .[] as $a
        | ([ $c[] | select(.id == $a.clienteId) | .nome ][0] // "Sem nome") as $cliente
        | "ID: #\($a.id) | \($a.data) às \($a.horario) | [\($a.status | ascii_upcase)]\n   Cliente: \($cliente) | Serviço: \($a.servico)\n----------------------------------------------"
    ' <<< "$AGENDAMENTOS"
}

novo_agendamento() {
    listar_clientes
    echo -e "\n--- NOVO AGENDAMENTO ---"
    read -rp "ID do Cliente: " cid
    read -rp "Serviço: " servico
    read -rp "Data (AAAA-MM-DD): " data
    read -rp "Horário (HH:MM): " hora

    JSON=$(jq -n --argjson id "${cid:-0}" --arg s "$servico" --arg d "$data" --arg h "$hora" \
        '{clienteId:$id, servico:$s, data:$d, horario:$h}')

    curl -s -X POST "$BASE/agendamentos" -H "Content-Type: application/json" -d "$JSON" | jq .
}

editar_agendamento() {
    listar_agendamentos
    echo -e "\n--- EDITAR AGENDAMENTO (Enter para manter atual) ---"
    read -rp "ID do Agendamento: " id
    read -rp "Novo serviço: " servico
    read -rp "Nova data (AAAA-MM-DD): " data
    read -rp "Novo horário (HH:MM): " hora

    JSON="{}"
    [ -n "$servico" ] && JSON=$(echo "$JSON" | jq --arg v "$servico" '. + {servico:$v}')
    [ -n "$data" ]    && JSON=$(echo "$JSON" | jq --arg v "$data" '. + {data:$v}')
    [ -n "$hora" ]    && JSON=$(echo "$JSON" | jq --arg v "$hora" '. + {horario:$v}')

    curl -s -X PATCH "$BASE/agendamentos/$id" -H "Content-Type: application/json" -d "$JSON" | jq .
}

mudar_status() {
    listar_agendamentos
    echo -e "\n--- MUDAR STATUS ---"
    read -rp "ID do Agendamento: " id
    echo "1) pendente   2) confirmado   3) concluido   4) cancelado"
    read -rp "Escolha o novo status: " op

    case "$op" in
        1) st="pendente" ;;
        2) st="confirmado" ;;
        3) st="concluido" ;;
        4) st="cancelado" ;;
        *) echo "Opção inválida!"; return ;;
    esac

    curl -s -X PATCH "$BASE/agendamentos/$id" -H "Content-Type: application/json" -d "{\"status\":\"$st\"}" | jq .
}

excluir_agendamento() {
    listar_agendamentos
    read -rp "ID do Agendamento para excluir: " id
    curl -s -X DELETE "$BASE/agendamentos/$id" | jq .
}

# --- MENU PRINCIPAL ---

while true; do
    echo -e "\n==============================="
    echo "   GESTÃO DE AGENDAMENTOS"
    echo "==============================="
    echo "1) Listar agendamentos"
    echo "2) Novo agendamento"
    echo "3) Editar agendamento"
    echo "4) Mudar status"
    echo "5) Excluir agendamento"
    echo "6) Listar clientes"
    echo "7) Cadastrar cliente"
    echo "0) Sair"
    echo "==============================="
    read -rp "Opção: " opcao

    case "$opcao" in
        1) listar_agendamentos ;;
        2) novo_agendamento ;;
        3) editar_agendamento ;;
        4) mudar_status ;;
        5) excluir_agendamento ;;
        6) listar_clientes ;;
        7) novo_cliente ;;
        0) exit 0 ;;
        *) echo "Opção inválida." ;;
    esac
done
