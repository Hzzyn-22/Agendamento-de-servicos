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

// [FLUXO] Endpoint analítico do Desafio Bônus para métricas de Big Data
app.get('/api/v1/dashboard', (req, res) => {
  try {
    const fsDash = require('fs');
    const dbPath = fsDash.existsSync('./src/data/database.json') ? './src/data/database.json' : './database.json';
    const raw = fsDash.readFileSync(dbPath, 'utf8');
    const db = JSON.parse(raw);
    const clientes = db.clientes || [];
    const agendamentos = db.agendamentos || [];

    // [TRANSF] Agrupa agendamentos por status e calcula totais
    const contagem = { pendente: 0, confirmado: 0, concluido: 0, cancelado: 0 };
    agendamentos.forEach(a => {
      const st = (a.status || 'pendente').toLowerCase();
      contagem[st] = (contagem[st] || 0) + 1;
    });

    res.status(200).json({
      projeto: 'AgendaPro TUI API',
      timestamp: new Date().toISOString(),
      totais: { clientes: clientes.length, agendamentos: agendamentos.length },
      por_status: contagem
    });
  } catch (err) {
    // [ERRO] Retorna HTTP 500 se falhar a leitura ou parsing do banco JSON
    res.status(500).json({ erro: 'Erro ao processar dashboard', detalhe: err.message });
  }
});

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


