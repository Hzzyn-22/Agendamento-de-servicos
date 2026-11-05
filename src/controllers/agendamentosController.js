const { lerDados, salvarDados } = require('../data/database');

exports.listar = (req, res) => {
    res.json(lerDados().agendamentos);
};

exports.buscar = (req, res) => {
    const dados = lerDados();
    const agendamento = dados.agendamentos.find(
        a => a.id === Number(req.params.id)
    );

    if (!agendamento) {
        return res.status(404).json({ erro: 'Agendamento não encontrado' });
    }

    res.json(agendamento);
};

exports.criar = (req, res) => {
    const { clienteId, servico, data, horario } = req.body;

    if (!clienteId || !servico || !data || !horario) {
        return res.status(400).json({ erro: 'Preencha todos os campos' });
    }

    const dados = lerDados();

    const cliente = dados.clientes.find(c => c.id === Number(clienteId));

    if (!cliente) {
        return res.status(400).json({ erro: 'Cliente não cadastrado' });
    }

    const agendamento = {
        id: dados.agendamentos.length
            ? Math.max(...dados.agendamentos.map(a => a.id)) + 1
            : 1,
        clienteId: Number(clienteId),
        servico,
        data,
        horario,
        status: 'pendente'
    };

    dados.agendamentos.push(agendamento);
    salvarDados(dados);

    res.status(201).json(agendamento);
};

exports.atualizar = (req, res) => {
    const dados = lerDados();
    const agendamento = dados.agendamentos.find(
        a => a.id === Number(req.params.id)
    );

    if (!agendamento) {
        return res.status(404).json({ erro: 'Agendamento não encontrado' });
    }

    Object.assign(agendamento, req.body, { id: agendamento.id });
    salvarDados(dados);

    res.json(agendamento);
};

exports.excluir = (req, res) => {
    const dados = lerDados();
    const id = Number(req.params.id);

    if (!dados.agendamentos.some(a => a.id === id)) {
        return res.status(404).json({ erro: 'Agendamento não encontrado' });
    }

    dados.agendamentos = dados.agendamentos.filter(a => a.id !== id);
    salvarDados(dados);

    res.json({ mensagem: 'Agendamento excluído com sucesso' });
};
