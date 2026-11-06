const { lerDados, salvarDados } = require('../data/database');

exports.listar = (req, res) => {
    const dados = lerDados();
    let clientes = dados.clientes;

    const { nome, email } = req.query;

    if (nome) {
        clientes = clientes.filter(c =>
            c.nome.toLowerCase().includes(nome.toLowerCase())
        );
    }

    if (email) {
        clientes = clientes.filter(c =>
            c.email.toLowerCase().includes(email.toLowerCase())
        );
    }

    res.status(200).json(clientes);
};

exports.buscar = (req, res) => {
    const dados = lerDados();
    const id = Number(req.params.id);

    const cliente = dados.clientes.find(c => c.id === id);

    if (!cliente) {
        return res.status(404).json({ erro: 'Cliente não encontrado' });
    }

    res.status(200).json(cliente);
};

exports.criar = (req, res) => {
    const { nome, email, telefone } = req.body;

    if (
        typeof nome !== 'string' || !nome.trim() ||
        typeof email !== 'string' || !email.trim()
    ) {
        return res.status(400).json({
            erro: 'Nome e email são obrigatórios'
        });
    }

    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
        return res.status(400).json({ erro: 'Email inválido' });
    }

    const dados = lerDados();

    const emailExiste = dados.clientes.some(
        c => c.email.toLowerCase() === email.trim().toLowerCase()
    );

    if (emailExiste) {
        return res.status(400).json({ erro: 'Email já cadastrado' });
    }

    const cliente = {
        id: dados.clientes.length
            ? Math.max(...dados.clientes.map(c => c.id)) + 1
            : 1,
        nome: nome.trim(),
        email: email.trim(),
        telefone: typeof telefone === 'string' ? telefone.trim() : ''
    };

    dados.clientes.push(cliente);
    salvarDados(dados);

    res.status(201).json(cliente);
};

exports.atualizar = (req, res) => {
    const dados = lerDados();
    const id = Number(req.params.id);

    const cliente = dados.clientes.find(c => c.id === id);

    if (!cliente) {
        return res.status(404).json({ erro: 'Cliente não encontrado' });
    }

    const { nome, email, telefone } = req.body;

    if (nome !== undefined) {
        if (typeof nome !== 'string' || !nome.trim()) {
            return res.status(400).json({ erro: 'Nome inválido' });
        }
        cliente.nome = nome.trim();
    }

    if (email !== undefined) {
        if (
            typeof email !== 'string' ||
            !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email.trim())
        ) {
            return res.status(400).json({ erro: 'Email inválido' });
        }

        const existe = dados.clientes.some(
            c => c.id !== id &&
            c.email.toLowerCase() === email.trim().toLowerCase()
        );

        if (existe) {
            return res.status(400).json({ erro: 'Email já cadastrado' });
        }

        cliente.email = email.trim();
    }

    if (telefone !== undefined) {
        if (typeof telefone !== 'string') {
            return res.status(400).json({ erro: 'Telefone inválido' });
        }
        cliente.telefone = telefone.trim();
    }

    if (
        nome === undefined &&
        email === undefined &&
        telefone === undefined
    ) {
        return res.status(400).json({ erro: 'Informe algum campo para atualizar' });
    }

    salvarDados(dados);
    res.status(200).json(cliente);
};

exports.excluir = (req, res) => {
    const dados = lerDados();
    const id = Number(req.params.id);

    const cliente = dados.clientes.find(c => c.id === id);

    if (!cliente) {
        return res.status(404).json({ erro: 'Cliente não encontrado' });
    }

    const possuiAgendamento = dados.agendamentos.some(
        a => a.clienteId === id
    );

    if (possuiAgendamento) {
        return res.status(400).json({
            erro: 'Não é possível excluir um cliente que possui agendamentos'
        });
    }

    dados.clientes = dados.clientes.filter(c => c.id !== id);
    salvarDados(dados);

    res.status(200).json({ mensagem: 'Cliente excluído com sucesso' });
};
