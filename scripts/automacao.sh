#!/bin/bash

# [TRANSF] (Verde): Regras de negócio, filtros (.filter(), .map()), normalização (toUpperCase()), parsing.
PASTA="$(cd "$(dirname "$0")/.." && pwd)"
PID_FILE="$PASTA/api.pid"
LOG_FILE="$PASTA/api.log"
PORTA="${PORT:-3016}"

# [FLUXO] (Azul): Entradas de dados, requisições (req.body, req.query), leitura de arquivos/APIs.
cd "$PASTA" || exit 1

case "$1" in
    start)
# [FLUXO] (Azul): Entradas de dados, requisições (req.body, req.query), leitura de arquivos/APIs.
        if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
            echo "API já está em execução."
            exit 0
        fi

        echo "Iniciando API..."
# [FLUXO] (Azul): Entradas de dados, requisições (req.body, req.query), leitura de arquivos/APIs.
        PORT="$PORTA" node server.js >> "$LOG_FILE" 2>&1 &
        echo $! > "$PID_FILE"

# [FLUXO] (Azul): Entradas de dados, requisições (req.body, req.query), leitura de arquivos/APIs.
        for i in {1..10}; do
            if curl -s "http://localhost:$PORTA/" > /dev/null; then
                echo "API iniciada com sucesso!"
                echo "PID: $(cat "$PID_FILE")"
                exit 0
            fi
            sleep 1
        done
# [ERRO] (Vermelho): Validações críticas, exceções (400, 404, 500), pontos de falha ou try/catch.
        echo "Não foi possível iniciar a API."
        cat "$LOG_FILE"
        exit 1
        ;;

    stop)
        if [ -f "$PID_FILE" ]; then
# [TRANSF] (Verde): Regras de negócio, filtros (.filter(), .map()), normalização (toUpperCase()), parsing.
            PID=$(cat "$PID_FILE")

            if kill -0 "$PID" 2>/dev/null; then
                kill "$PID"
                echo "Solicitação de encerramento enviada."
            else
# [ERRO] (Vermelho): Validações críticas, exceções (400, 404, 500), pontos de falha ou try/catch.
                echo "Processo já estava parado."
            fi

            rm -f "$PID_FILE"
        else
# [ERRO] (Vermelho): Validações críticas, exceções (400, 404, 500), pontos de falha ou try/catch.
            echo "API não está registrada."
        fi
        ;;

    status)
# [FLUXO] (Azul): Entradas de dados, requisições (req.body, req.query), leitura de arquivos/APIs.
        if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
            echo "API em execução."
            ps -p "$(cat "$PID_FILE")" -o pid,cmd
        else
# [ERRO] (Vermelho): Validações críticas, exceções (400, 404, 500), pontos de falha ou try/catch.
            echo "API parada."
        fi
        ;;

    *)
# [ERRO] (Vermelho): Validações críticas, exceções (400, 404, 500), pontos de falha ou try/catch.
        echo "Uso: ./scripts/automacao.sh {start|stop|status}"
        exit 1
        ;;
esac
