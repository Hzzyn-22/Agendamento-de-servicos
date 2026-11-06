const fs = require('fs');
const path = require('path');

const arquivo = path.join(__dirname, 'database.json');

function lerDados() {
    if (!fs.existsSync(arquivo)) {
        salvarDados({ clientes: [], agendamentos: [] });
    }

    return JSON.parse(fs.readFileSync(arquivo, 'utf8'));
}

function salvarDados(dados) {
    fs.writeFileSync(arquivo, JSON.stringify(dados, null, 2));
}

module.exports = { lerDados, salvarDados };
