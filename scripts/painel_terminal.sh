#!/bin/bash

API="http://localhost:3016"

# Tema visual escuro/ciano para as caixas de diálogo do whiptail
export NEWT_COLORS='
root=,blue
window=,lightgray
border=black,lightgray
shadow=,black
title=blue,lightgray
textbox=black,lightgray
button=white,blue
actbutton=white,cyan
listbox=black,lightgray
actlistbox=white,blue
entry=white,blue
label=black,lightgray
'

# [FLUXO] Garante que a API back-end esteja rodando na porta 3016
cd ~/Agendamento-de-servicos || exit 1
./scripts/automacao.sh start >/dev/null 2>&1

# [ERRO] Valida dependências necessárias no Debian (whiptail e jq)
if ! command -v whiptail >/dev/null 2>&1 || ! command -v jq >/dev/null 2>&1; then
  echo "[ERRO] Instale os pacotes necessários: sudo apt update && sudo apt install -y whiptail jq"
  exit 1
fi

msg() {
  whiptail --title "$1" --scrolltext --msgbox "$2" 20 78
}

while true; do
  # [FLUXO] Consome os endpoints REST da API em JSON
  CLI_JSON=$(curl -s "$API/clientes")
  AG_JSON=$(curl -s "$API/agendamentos")
  echo "$CLI_JSON" | jq -e . >/dev/null 2>&1 || CLI_JSON="[]"
  echo "$AG_JSON" | jq -e . >/dev/null 2>&1 || AG_JSON="[]"

  # [TRANSF] Agrega métricas em tempo real via jq para o cabeçalho do painel
  T_CLI=$(echo "$CLI_JSON" | jq 'length')
  T_AG=$(echo "$AG_JSON" | jq 'length')
  N_PEND=$(echo "$AG_JSON" | jq '[.[] | select(.status=="pendente")] | length')
  N_CONF=$(echo "$AG_JSON" | jq '[.[] | select(.status=="confirmado")] | length')
  N_CONC=$(echo "$AG_JSON" | jq '[.[] | select(.status=="concluido")] | length')

  RESUMO="Clientes: $T_CLI  |  Agendamentos: $T_AG (Pendentes: $N_PEND | Confirmados: $N_CONF | Concluídos: $N_CONC)\n\nUse as setas [↑/↓] para navegar, [Tab] para botões e [Enter] para confirmar:"

  OP=$(whiptail --title "AGENDAPRO TUI — API REST BACK-END (PORTA 3016)" \
    --cancel-button "Sair" \
    --menu "$RESUMO" 22 78 9 \
    "1" "Listar Clientes cadastrados (GET /clientes)" \
    "2" "Cadastrar Novo Cliente (POST /clientes)" \
    "3" "Listar Agendamentos (GET /agendamentos)" \
    "4" "Novo Agendamento (POST /agendamentos)" \
    "5" "Alterar Status de Agendamento (PATCH /agendamentos/:id)" \
    "6" "Excluir Agendamento (DELETE /agendamentos/:id)" \
    "7" "Executar Pipeline ETL -> Gerar CSV Analítico" \
    "8" "Rodar Bateria de Testes Automatizados (testes.sh)" \
    "0" "Encerrar painel" 3>&1 1>&2 2>&3)

  STATUS_SAIDA=$?
  if [ $STATUS_SAIDA -ne 0 ] || [ "$OP" = "0" ]; then
    clear
    exit 0
  fi

  case $OP in
    1)
      # [TRANSF] Formata o JSON de clientes em colunas alinhadas para exibição
      TABELA=$(echo "$CLI_JSON" | jq -r '(["ID","NOME","E-MAIL","TELEFONE"] | @tsv), (.[] | [.id, .nome, .email, (.telefone // "-")] | @tsv)' | column -t -s $'\t')
      [ "$T_CLI" -eq 0 ] && TABELA="Nenhum cliente cadastrado no momento."
      msg "CLIENTES CADASTRADOS ($T_CLI)" "$TABELA"
      ;;

    2)
      # [FLUXO] Coleta os campos do novo cliente via caixas de texto interativas
      NOME=$(whiptail --title "Novo Cliente (1/3)" --inputbox "Nome completo do cliente:" 10 60 3>&1 1>&2 2>&3) || continue
      EMAIL=$(whiptail --title "Novo Cliente (2/3)" --inputbox "E-mail do cliente:" 10 60 3>&1 1>&2 2>&3) || continue
      TEL=$(whiptail --title "Novo Cliente (3/3)" --inputbox "Telefone (ex: 11999998888):" 10 60 3>&1 1>&2 2>&3) || continue

      PAYLOAD=$(jq -n --arg n "$NOME" --arg e "$EMAIL" --arg t "$TEL" '{nome:$n, email:$e, telefone:$t}')
      RESP=$(curl -s -w "\n%{http_code}" -X POST "$API/clientes" -H "Content-Type: application/json" -d "$PAYLOAD")
      CODE=$(echo "$RESP" | tail -n1)
      BODY=$(echo "$RESP" | sed '$d')

      # [ERRO] Valida o código HTTP retornado pela API Express
      if [ "$CODE" -eq 201 ] || [ "$CODE" -eq 200 ]; then
        msg "Sucesso (HTTP $CODE)" "Cliente cadastrado com sucesso:\n\n$BODY"
      else
        msg "[ERRO] Falha no Cadastro (HTTP $CODE)" "$BODY"
      fi
      ;;

    3)
      # [TRANSF] Cruza clienteId com /clientes para exibir o primeiro nome na tabela
      TABELA=$(echo "$AG_JSON" | jq -r --argjson clis "$CLI_JSON" '
        ($clis | map({(.id | tostring): (.nome | gsub("^\\s+"; "") | split(" ")[0])}) | add // {}) as $mapa |
        (["ID","CLIENTE","SERVIÇO","DATA","HORA","STATUS"] | @tsv),
        (.[] | [.id, ($mapa[.clienteId | tostring] // "ID #\(.clienteId)"), .servico, .data, .horario, .status] | @tsv)
      ' | column -t -s $'\t')
      [ "$T_AG" -eq 0 ] && TABELA="Nenhum agendamento registrado no momento."
      msg "AGENDAMENTOS REGISTRADOS ($T_AG)" "$TABELA"
      ;;

    4)
      # [ERRO] Impede agendamento se não houver clientes cadastrados
      if [ "$T_CLI" -eq 0 ]; then
        msg "[ERRO] Sem Clientes" "Cadastre pelo menos um cliente antes de criar um agendamento."
        continue
      fi

      # [TRANSF] Monta lista dinâmica de clientes para seleção com as setas
      ITENS_CLI=()
      while IFS=$'\t' read -r cid cnome cemail; do
        ITENS_CLI+=("$cid" "$cnome ($cemail)")
      done < <(echo "$CLI_JSON" | jq -r '.[] | [.id, .nome, .email] | @tsv')

      CID=$(whiptail --title "Novo Agendamento (1/4)" --menu "Selecione o cliente com as setas:" 18 70 8 "${ITENS_CLI[@]}" 3>&1 1>&2 2>&3) || continue
      SERV=$(whiptail --title "Novo Agendamento (2/4)" --inputbox "Descrição do serviço:" 10 60 3>&1 1>&2 2>&3) || continue
      DATA=$(whiptail --title "Novo Agendamento (3/4)" --inputbox "Data (AAAA-MM-DD):" 10 60 "$(date +%F)" 3>&1 1>&2 2>&3) || continue
      HORA=$(whiptail --title "Novo Agendamento (4/4)" --inputbox "Horário (HH:MM):" 10 60 "10:00" 3>&1 1>&2 2>&3) || continue

      PAYLOAD=$(jq -n --arg cid "$CID" --arg s "$SERV" --arg d "$DATA" --arg h "$HORA" '{clienteId:($cid|tonumber), servico:$s, data:$d, horario:$h}')
      RESP=$(curl -s -w "\n%{http_code}" -X POST "$API/agendamentos" -H "Content-Type: application/json" -d "$PAYLOAD")
      CODE=$(echo "$RESP" | tail -n1)
      BODY=$(echo "$RESP" | sed '$d')

      if [ "$CODE" -eq 201 ] || [ "$CODE" -eq 200 ]; then
        msg "Sucesso (HTTP $CODE)" "Agendamento registrado:\n\n$BODY"
      else
        msg "[ERRO] Falha ao Agendar (HTTP $CODE)" "$BODY"
      fi
      ;;

    5)
      if [ "$T_AG" -eq 0 ]; then
        msg "[ERRO] Lista Vazia" "Não há agendamentos para atualizar."
        continue
      fi

      # [TRANSF] Monta menu dinâmico exibindo o primeiro nome do cliente
      ITENS_AG=()
      while IFS=$'\t' read -r aid cnome serv data hora st; do
        ITENS_AG+=("$aid" "$cnome | $serv ($data $hora) [$st]")
      done < <(echo "$AG_JSON" | jq -r --argjson clis "$CLI_JSON" '
        ($clis | map({(.id | tostring): (.nome | gsub("^\\s+"; "") | split(" ")[0])}) | add // {}) as $mapa |
        .[] | [.id, ($mapa[.clienteId | tostring] // "ID #\(.clienteId)"), .servico, .data, .horario, .status] | @tsv
      ')

      AID=$(whiptail --title "Alterar Status (1/2)" --menu "Escolha o agendamento:" 18 74 8 "${ITENS_AG[@]}" 3>&1 1>&2 2>&3) || continue

      NOVO_ST=$(whiptail --title "Alterar Status (2/2)" --menu "Selecione o novo status para #$AID:" 15 60 4 \
        "pendente" "Aguardando confirmação" \
        "confirmado" "Horário confirmado" \
        "concluido" "Serviço finalizado" \
        "cancelado" "Agendamento cancelado" 3>&1 1>&2 2>&3) || continue

      RESP=$(curl -s -w "\n%{http_code}" -X PATCH "$API/agendamentos/$AID" -H "Content-Type: application/json" -d "$(jq -n --arg st "$NOVO_ST" '{status:$st}')")
      CODE=$(echo "$RESP" | tail -n1)
      BODY=$(echo "$RESP" | sed '$d')

      if [ "$CODE" -eq 200 ]; then
        msg "Status Atualizado (HTTP $CODE)" "$BODY"
      else
        msg "[ERRO] Falha na Atualização (HTTP $CODE)" "$BODY"
      fi
      ;;

    6)
      if [ "$T_AG" -eq 0 ]; then
        msg "[ERRO] Lista Vazia" "Não há agendamentos para excluir."
        continue
      fi

      # [TRANSF] Lista agendamentos com o primeiro nome do cliente para remoção
      ITENS_AG=()
      while IFS=$'\t' read -r aid cnome serv data hora st; do
        ITENS_AG+=("$aid" "$cnome | $serv ($data $hora) [$st]")
      done < <(echo "$AG_JSON" | jq -r --argjson clis "$CLI_JSON" '
        ($clis | map({(.id | tostring): (.nome | gsub("^\\s+"; "") | split(" ")[0])}) | add // {}) as $mapa |
        .[] | [.id, ($mapa[.clienteId | tostring] // "ID #\(.clienteId)"), .servico, .data, .horario, .status] | @tsv
      ')

      AID=$(whiptail --title "Excluir Agendamento" --menu "Selecione o agendamento para remover:" 18 74 8 "${ITENS_AG[@]}" 3>&1 1>&2 2>&3) || continue

      if whiptail --title "Confirmar Exclusão" --yesno "Deseja realmente excluir o agendamento #$AID?" 10 55; then
        RESP=$(curl -s -w "\n%{http_code}" -X DELETE "$API/agendamentos/$AID")
        CODE=$(echo "$RESP" | tail -n1)
        if [ "$CODE" -eq 200 ]; then
          msg "Excluído (HTTP $CODE)" "Agendamento #$AID removido com sucesso."
        else
          msg "[ERRO] Falha ao Excluir (HTTP $CODE)" "$(echo "$RESP" | sed '$d')"
        fi
      fi
      ;;

    7)
      # [TRANSF] Pipeline ETL: enriquece JSON com nome do cliente e exporta CSV
      echo "$AG_JSON" | jq -r --argjson clis "$CLI_JSON" '
        ($clis | map({(.id | tostring): .nome}) | add // {}) as $mapa |
        (["ID","CLIENTE_ID","CLIENTE","SERVICO","DATA","HORARIO","STATUS"] | @csv),
        (.[] | [.id, .clienteId, ($mapa[.clienteId | tostring] // "Desconhecido"), .servico, .data, .horario, .status] | @csv)
      ' > dataset_agendamentos.csv
      CSV_FORMATADO=$(column -t -s ',' dataset_agendamentos.csv)
      msg "PIPELINE ETL CONCLUÍDO — dataset_agendamentos.csv" "Arquivo CSV exportado com sucesso ($T_AG registros):\n\n$CSV_FORMATADO"
      ;;

    8)
      # [FLUXO] Executa a suíte de testes Bash e exibe o log na janela
      SAIDA_TESTES=$(./scripts/testes.sh 2>&1 | sed 's/\x1b\[[0-9;]*m//g')
      msg "RESULTADO DOS TESTES AUTOMATIZADOS" "$SAIDA_TESTES"
      ;;
  esac
done
