const express = require('express');

const app = express();
const PORT = process.env.PORT || 3016;

app.use(express.json());

const clientesRoutes = require('./src/routes/clientes');
const agendamentosRoutes = require('./src/routes/agendamentos');

app.get('/', (req, res) => {
    res.json({
        mensagem: 'API de Agendamento de Serviços funcionando!',
        versao: '1.0.0'
    });
});

app.use('/clientes', clientesRoutes);
app.use('/agendamentos', agendamentosRoutes);

app.listen(PORT, '0.0.0.0', () => {
    console.log(`Servidor rodando na porta ${PORT}`);
});

