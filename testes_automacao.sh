#!/bin/bash
// [FLUXO] (Azul): Entradas de dados, requisições (req.body, req.query), leitura de arquivos/APIs.
cd "$(dirname "$0")/.." || exit 1

// [TRANSF] (Verde): Regras de negócio, filtros (.filter(), .map()), normalização (toUpperCase()), parsing.
case "$1" in
    start)
        echo "Iniciando API..."
// [FLUXO] (Azul): Entradas de dados, requisições (req.body, req.query), leitura de arquivos/APIs.
        npm start > api.log 2>&1 &
        echo $! > api.pid
        echo "API iniciada em segundo plano!"
        ;;

    stop)
        if [ -f api.pid ]; then
// [TRANSF] (Verde): Regras de negócio, filtros (.filter(), .map()), normalização (toUpperCase()), parsing.
            PID=$(cat api.pid)
            kill "$PID" 2>/dev/null
            rm -f api.pid
            echo "API encerrada!"
        else
// [ERRO] (Vermelho): Validações críticas, exceções (400, 404, 500), pontos de falha ou try/catch.
            echo "API não está registrada."
        fi
        ;;
// [FLUXO] (Azul): Entradas de dados, requisições (req.body, req.query), leitura de arquivos/APIs.
    status)
        if [ -f api.pid ] && kill -0 "$(cat api.pid)" 2>/dev/null; then
            echo "API em execução!"
        else
// [ERRO] (Vermelho): Validações críticas, exceções (400, 404, 500), pontos de falha ou try/catch.
            echo "API parada."
        fi
        ;;

    *)
// [ERRO] (Vermelho): Validações críticas, exceções (400, 404, 500), pontos de falha ou try/catch.
        echo "Use: ./scripts/automacao.sh {start|stop|status}"
        ;;
esac
