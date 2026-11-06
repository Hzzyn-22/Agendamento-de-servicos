const { lerDados, salvarDados } = require('../data/database');

exports.listar = (req, res) => {
    res.json(lerDados().clientes);
};

exports.buscar = (req, res) => {
    const dados = lerDados();
    const cliente = dados.clientes.find(c => c.id === Number(req.params.id));

    if (!cliente) {
        return res.status(404).json({ erro: 'Cliente não encontrado' });
    }

    res.json(cliente);
};

exports.criar = (req, res) => {
    const { nome, email, telefone } = req.body;

    if (!nome || !email) {
        return res.status(400).json({ erro: 'Nome e email são obrigatórios' });
    }

    const dados = lerDados();

    const cliente = {
        id: dados.clientes.length
            ? Math.max(...dados.clientes.map(c => c.id)) + 1
            : 1,
        nome,
        email,
        telefone: telefone || ''
    };

    dados.clientes.push(cliente);
    salvarDados(dados);

    res.status(201).json(cliente);
};

exports.atualizar = (req, res) => {
    const dados = lerDados();
    const cliente = dados.clientes.find(c => c.id === Number(req.params.id));

    if (!cliente) {
        return res.status(404).json({ erro: 'Cliente não encontrado' });
    }

    Object.assign(cliente, req.body, { id: cliente.id });
    salvarDados(dados);

    res.json(cliente);
};

exports.excluir = (req, res) => {
    const dados = lerDados();
    const id = Number(req.params.id);

    if (!dados.clientes.some(c => c.id === id)) {
        return res.status(404).json({ erro: 'Cliente não encontrado' });
    }

    dados.clientes = dados.clientes.filter(c => c.id !== id);
    salvarDados(dados);

    res.json({ mensagem: 'Cliente excluído com sucesso' });
};
