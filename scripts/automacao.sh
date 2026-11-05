#!/bin/bash

cd "$(dirname "$0")/.." || exit 1

case "$1" in
    start)
        echo "Iniciando API..."
        npm start > api.log 2>&1 &
        echo $! > api.pid
        echo "API iniciada em segundo plano!"
        ;;

    stop)
        if [ -f api.pid ]; then
            PID=$(cat api.pid)
            kill "$PID" 2>/dev/null
            rm -f api.pid
            echo "API encerrada!"
        else
            echo "API não está registrada."
        fi
        ;;

    status)
        if [ -f api.pid ] && kill -0 "$(cat api.pid)" 2>/dev/null; then
            echo "API em execução!"
        else
            echo "API parada."
        fi
        ;;

    *)
        echo "Use: ./scripts/automacao.sh {start|stop|status}"
        ;;
esac

