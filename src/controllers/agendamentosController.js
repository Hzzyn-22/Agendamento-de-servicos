const { lerDados, salvarDados } = require('../data/database');

const statusPermitidos = [
    'pendente',
    'confirmado',
    'cancelado',
    'concluido'
];

exports.listar = (req, res) => {
    const dados = lerDados();
    let agendamentos = dados.agendamentos;

    const { status, clienteId, data } = req.query;

    if (status) {
        agendamentos = agendamentos.filter(
            a => a.status === status.toLowerCase()
        );
    }

    if (clienteId) {
        const id = Number(clienteId);

        if (!Number.isInteger(id) || id <= 0) {
            return res.status(400).json({ erro: 'clienteId inválido' });
        }

        agendamentos = agendamentos.filter(a => a.clienteId === id);
    }

    if (data) {
        agendamentos = agendamentos.filter(a => a.data === data);
    }

    res.status(200).json(agendamentos);
};

exports.buscar = (req, res) => {
    const dados = lerDados();
    const id = Number(req.params.id);

    const agendamento = dados.agendamentos.find(a => a.id === id);

    if (!agendamento) {
        return res.status(404).json({
            erro: 'Agendamento não encontrado'
        });
    }

    res.status(200).json(agendamento);
};

exports.criar = (req, res) => {
    const { clienteId, servico, data, horario } = req.body;

    if (
        !Number.isInteger(Number(clienteId)) ||
        Number(clienteId) <= 0 ||
        typeof servico !== 'string' || !servico.trim() ||
        typeof data !== 'string' || !/^\d{4}-\d{2}-\d{2}$/.test(data) ||
        typeof horario !== 'string' || !/^([01]\d|2[0-3]):[0-5]\d$/.test(horario)
    ) {
        return res.status(400).json({
            erro: 'Informe clienteId, serviço, data e horário válidos'
        });
    }

    const dados = lerDados();

    const cliente = dados.clientes.find(
        c => c.id === Number(clienteId)
    );

    if (!cliente) {
        return res.status(400).json({ erro: 'Cliente não cadastrado' });
    }

    const agendamento = {
        id: dados.agendamentos.length
            ? Math.max(...dados.agendamentos.map(a => a.id)) + 1
            : 1,
        clienteId: Number(clienteId),
        servico: servico.trim(),
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
    const id = Number(req.params.id);

    const agendamento = dados.agendamentos.find(a => a.id === id);

    if (!agendamento) {
        return res.status(404).json({
            erro: 'Agendamento não encontrado'
        });
    }

    const { clienteId, servico, data, horario, status } = req.body;

    if (
        clienteId === undefined &&
        servico === undefined &&
        data === undefined &&
        horario === undefined &&
        status === undefined
    ) {
        return res.status(400).json({
            erro: 'Informe algum campo para atualizar'
        });
    }

    if (clienteId !== undefined) {
        const cliente = dados.clientes.find(
            c => c.id === Number(clienteId)
        );

        if (!Number.isInteger(Number(clienteId)) || !cliente) {
            return res.status(400).json({ erro: 'Cliente não cadastrado' });
        }

        agendamento.clienteId = Number(clienteId);
    }

    if (servico !== undefined) {
        if (typeof servico !== 'string' || !servico.trim()) {
            return res.status(400).json({ erro: 'Serviço inválido' });
        }
        agendamento.servico = servico.trim();
    }

    if (data !== undefined) {
        if (typeof data !== 'string' || !/^\d{4}-\d{2}-\d{2}$/.test(data)) {
            return res.status(400).json({ erro: 'Data inválida' });
        }
        agendamento.data = data;
    }

    if (horario !== undefined) {
        if (typeof horario !== 'string' || !/^([01]\d|2[0-3]):[0-5]\d$/.test(horario)) {
            return res.status(400).json({ erro: 'Horário inválido' });
        }
        agendamento.horario = horario;
    }

    if (status !== undefined) {
        if (
            typeof status !== 'string' ||
            !statusPermitidos.includes(status.toLowerCase())
        ) {
            return res.status(400).json({ erro: 'Status inválido' });
        }
        agendamento.status = status.toLowerCase();
    }

    salvarDados(dados);
    res.status(200).json(agendamento);
};

exports.excluir = (req, res) => {
    const dados = lerDados();
    const id = Number(req.params.id);

    if (!dados.agendamentos.some(a => a.id === id)) {
        return res.status(404).json({
            erro: 'Agendamento não encontrado'
        });
    }

    dados.agendamentos = dados.agendamentos.filter(a => a.id !== id);
    salvarDados(dados);

    res.status(200).json({
        mensagem: 'Agendamento excluído com sucesso'
    });
};
