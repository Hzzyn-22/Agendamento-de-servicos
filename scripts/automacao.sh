#!/bin/bash

PASTA="$(cd "$(dirname "$0")/.." && pwd)"
PID_FILE="$PASTA/api.pid"
LOG_FILE="$PASTA/api.log"
PORTA="${PORT:-3016}"

cd "$PASTA" || exit 1

case "$1" in
    start)
        if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
            echo "API já está em execução."
            exit 0
        fi

        echo "Iniciando API..."
        PORT="$PORTA" node server.js >> "$LOG_FILE" 2>&1 &
        echo $! > "$PID_FILE"

        for i in {1..10}; do
            if curl -s "http://localhost:$PORTA/" > /dev/null; then
                echo "API iniciada com sucesso!"
                echo "PID: $(cat "$PID_FILE")"
                exit 0
            fi
            sleep 1
        done

        echo "Não foi possível iniciar a API."
        cat "$LOG_FILE"
        exit 1
        ;;

    stop)
        if [ -f "$PID_FILE" ]; then
            PID=$(cat "$PID_FILE")

            if kill -0 "$PID" 2>/dev/null; then
                kill "$PID"
                echo "Solicitação de encerramento enviada."
            else
                echo "Processo já estava parado."
            fi

            rm -f "$PID_FILE"
        else
            echo "API não está registrada."
        fi
        ;;

    status)
        if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
            echo "API em execução."
            ps -p "$(cat "$PID_FILE")" -o pid,cmd
        else
            echo "API parada."
        fi
        ;;

    *)
        echo "Uso: ./scripts/automacao.sh {start|stop|status}"
        exit 1
        ;;
esac
