// [FLUXO] (Azul): Entradas de dados, requisições (req.body, req.query), leitura de arquivos/APIs.
const path = require('path');
const express = require('express');

// [FLUXO] (Azul): Entradas de dados, requisições (req.body, req.query), leitura de arquivos/APIs.
const app = express();
const PORT = process.env.PORT || 3016;

// [TRANSF] (Verde): Regras de negócio, filtros (.filter(), .map()), normalização (toUpperCase()), parsing.
app.use(express.json());

// [FLUXO] (Azul): Entradas de dados, requisições (req.body, req.query), leitura de arquivos/APIs.

// [FLUXO] (Azul): Entradas de dados, requisições (req.body, req.query), leitura de arquivos/APIs.

const clientesRoutes = require('./src/routes/clientes');
const agendamentosRoutes = require('./src/routes/agendamentos');

// [FLUXO] (Azul): Entradas de dados, requisições (req.body, req.query), leitura de arquivos/APIs.
app.get('/', (req, res) => {
    res.status(200).json({
        mensagem: 'API de Agendamento de Serviços funcionando!',
        versao: '1.0.0'
    });
});

// [FLUXO] (Azul): Entradas de dados, requisições (req.body, req.query), leitura de arquivos/APIs.
app.use('/clientes', clientesRoutes);
app.use('/agendamentos', agendamentosRoutes);

//[ERRO] (Vermelho): Validações críticas, exceções (400, 404, 500), pontos de falha ou try/catch.
app.use((req, res) => {
    res.status(404).json({ erro: 'Rota não encontrada' });
});

//[ERRO] (Vermelho): Validações críticas, exceções (400, 404, 500), pontos de falha ou try/catch.
app.use((err, req, res, next) => {
    if (err instanceof SyntaxError && err.status === 400 && 'body' in err) {
        return res.status(400).json({ erro: 'JSON inválido' });
    }

// [ERRO] (Vermelho): Validações críticas, exceções (400, 404, 500), pontos de falha ou try/catch.
    console.error(err);
    res.status(500).json({ erro: 'Erro interno do servidor' });
});

// [FLUXO] (Azul): Entradas de dados, requisições (req.body, req.query), leitura de arquivos/APIs.
app.listen(PORT, '0.0.0.0', () => {
    console.log(`Servidor rodando na porta ${PORT}`);
});


