const express = require('express');

const app = express();
const PORT = process.env.PORT || 3016;

app.use(express.json());

const clientesRoutes = require('./src/routes/clientes');
const agendamentosRoutes = require('./src/routes/agendamentos');

app.get('/', (req, res) => {
    res.status(200).json({
        mensagem: 'API de Agendamento de Serviços funcionando!',
        versao: '1.0.0'
    });
});

app.use('/clientes', clientesRoutes);
app.use('/agendamentos', agendamentosRoutes);

app.use((req, res) => {
    res.status(404).json({ erro: 'Rota não encontrada' });
});

app.use((err, req, res, next) => {
    if (err instanceof SyntaxError && err.status === 400 && 'body' in err) {
        return res.status(400).json({ erro: 'JSON inválido' });
    }

    console.error(err);
    res.status(500).json({ erro: 'Erro interno do servidor' });
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(`Servidor rodando na porta ${PORT}`);
});
