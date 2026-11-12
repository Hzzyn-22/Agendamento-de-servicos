# 📅 Sistema de Agendamento de Serviços — API RESTful

![Node.js](https://img.shields.io/badge/Node.js-18%2B-339933?style=for-the-badge&logo=node.js&logoColor=white)
![Express](https://img.shields.io/badge/Express-5.1.0-000000?style=for-the-badge&logo=express&logoColor=white)
![Persistência](https://img.shields.io/badge/Persistência-JSON%20Storage-F7DF1E?style=for-the-badge&logo=json&logoColor=black)
![Shell Script](https://img.shields.io/badge/Testes%20%26%20CLI-Bash%20%7C%20cURL%20%7C%20jq-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white)
![Instituição](https://img.shields.io/badge/SENAI%20Mauá-Jairo%20Cândido-E30613?style=for-the-badge)

API RESTful desenvolvida em **Node.js** com **Express 5** para o gerenciamento integrado de clientes e agendamentos de serviços, acompanhada de **painel interativo no terminal**, **menu de validação de códigos HTTP** e **suíte automatizada de testes em Shell Script**.

Projeto Integrador desenvolvido para a disciplina de **Programação Back-End 1** do curso Técnico em Desenvolvimento de Sistemas — **SENAI Mauá - Jairo Cândido**.

---

## 📑 Sumário

- [Visão Geral](#-visão-geral)
- [Recursos Principais](#-recursos-principais)
- [Tecnologias Utilizadas](#-tecnologias-utilizadas)
- [Estrutura do Projeto](#-estrutura-do-projeto)
- [Instalação e Execução](#-instalação-e-execução)
- [Aba de Testes, Validação de Erros HTTP e Painel Interativo](#-aba-de-testes-validação-de-erros-http-e-painel-interativo)
  - [Painel Interativo (`testar`)](#1-painel-interativo-de-gestão-testar)
  - [Validação de Status e Erros HTTP (`erros`)](#2-menu-de-validação-de-status-e-erros-http-erros)
  - [Suíte Automatizada e Auditoria](#3-suíte-de-testes-automatizados-e-auditoria)
  - [Relatório Formatado de Agendamentos](#4-consulta-formatada-de-agendamentos)
  - [Configuração dos Atalhos `testar` e `erros`](#5-como-ativar-os-atalhos-testar-e-erros-no-terminal)
- [Documentação da API](#-documentação-da-api)
  - [Health Check (`/`)](#health-check-)
  - [Endpoints de Clientes (`/clientes`)](#endpoints-de-clientes-clientes)
  - [Endpoints de Agendamentos (`/agendamentos`)](#endpoints-de-agendamentos-agendamentos)
  - [Filtros por Query Parameters](#filtros-por-query-parameters)
  - [Códigos de Status HTTP](#códigos-de-status-http)
- [Gerenciamento de Processos no Linux](#-gerenciamento-de-processos-no-linux)
- [Autores e Créditos](#-autores-e-créditos)

---

## 🎯 Visão Geral

O sistema oferece uma solução back-end completa para cadastro de clientes, controle de agendamentos, atualização de status e consultas filtradas. A aplicação segue os princípios da arquitetura **RESTful**, opera por padrão na porta `3016` e utiliza **persistência local em arquivo JSON** (`src/data/database.json`), mantendo os registros salvos entre reinicializações do servidor.

---

## ✨ Recursos Principais

- **CRUD Completo (`GET`, `POST`, `PUT`, `PATCH`, `DELETE`):** Operações completas e parciais para `Clientes` e `Agendamentos`.
- **Persistência em Arquivo JSON:** Leitura e gravação automática em `src/data/database.json` via módulo nativo `fs`.
- **Validação Rigorosa e Integridade Referencial:**
  - Obrigatoriedade e formato válido de e-mail, além de bloqueio de e-mails duplicados.
  - Validação de datas no padrão `AAAA-MM-DD` e horários no formato `HH:mm` (24h).
  - Bloqueio de agendamentos para clientes inexistentes e impedimento de exclusão de clientes que possuam agendamentos ativos.
  - Controle de status permitidos: `pendente`, `confirmado`, `concluido` e `cancelado`.
- **Filtros Dinâmicos via Query Parameters:** Consultas combinadas ou individuais por `nome`, `email`, `status`, `data` e `clienteId`.
- **Painel Interativo CLI (`testar`):** Interface amigável no terminal para operar toda a API sem precisar digitar comandos `cURL` manualmente.
- **Menu de Testes de Status e Erros HTTP (`erros`):** Ferramenta interativa para demonstrar respostas `200 OK`, `201 Created`, `400 Bad Request` e `404 Not Found` em tempo real.
- **Automação Completa em Bash:** Scripts para iniciar/parar a API em segundo plano (`daemon`), executar bateria de testes e gerar logs de auditoria.

---

## 🛠 Tecnologias Utilizadas

- **Ambiente de Execução:** Node.js (v18+)
- **Framework Web:** Express (`^5.1.0`)
- **Persistência de Dados:** Arquivo JSON local (`fs` / `database.json`)
- **Automação, CLI e Testes:** Shell Script (Bash), `cURL` e `jq`
- **Ambiente Operacional de Referência:** Linux Debian
- **Controle de Versão:** Git & GitHub

---

## 📂 Estrutura do Projeto

```plaintext
Agendamento-de-servicos/
├── scripts/
│   ├── automacao.sh                # Controle da API em segundo plano (start | stop | status)
│   ├── consultar_agendamentos.sh   # Relatório formatado de agendamentos no terminal
│   ├── painel.sh                   # Painel interativo completo (atalho: testar)
│   ├── testar-menu.sh              # Menu interativo de códigos HTTP e erros (atalho: erros)
│   ├── testes.sh                   # Script de testes de integração
│   └── testes_automacao.sh         # Suíte completa de testes (inclui PUT e PATCH) com log
├── src/
│   ├── controllers/
│   │   ├── agendamentosController.js  # Regras de negócio e validações de Agendamentos
│   │   └── clientesController.js      # Regras de negócio e validações de Clientes
│   ├── data/
│   │   ├── database.js                # Módulo de leitura e escrita no arquivo JSON
│   │   └── database.json              # Banco de dados local persistente
│   └── routes/
│       ├── agendamentos.js            # Rotas REST de /agendamentos
│       └── clientes.js                # Rotas REST de /clientes
├── .gitignore
├── api.log                            # Log de saída do servidor em segundo plano
├── api.pid                            # PID do processo ativo da API
├── package.json
├── package-lock.json
├── README.md
├── resultado_execucao.log             # Relatório de auditoria gerado pelos testes
└── server.js                          # Configuração do Express e inicialização (Porta 3016)
```

---

## 🚀 Instalação e Execução

### Pré-requisitos

- **Node.js** (versão 18.x ou superior) e **NPM**
- **Bash Terminal** (Linux, macOS ou Git Bash)
- **`curl` e `jq`** (necessários para o painel interativo e scripts de teste)

Para instalar `curl` e `jq` no Linux Debian/Ubuntu:
```bash
sudo apt update && sudo apt install -y curl jq
```

### Passo a Passo

1. **Clonar o repositório:**
   ```bash
   git clone [https://github.com/Hzzyn-22/Agendamento-de-servicos.git](https://github.com/Hzzyn-22/Agendamento-de-servicos.git)
   cd Agendamento-de-servicos
   ```

2. **Instalar as dependências:**
   ```bash
   npm install
   ```

3. **Conceder permissão de execução aos scripts:**
   ```bash
   chmod +x scripts/*.sh
   ```

4. **Iniciar o servidor:**
   ```bash
   npm start
   ```
   *(Ou iniciar em segundo plano com `./scripts/automacao.sh start`)*

> **Nota:** A API ficará disponível em `http://localhost:3016`.

---

## 🧪 Aba de Testes, Validação de Erros HTTP e Painel Interativo

O projeto conta com ferramentas dedicadas no terminal para demonstração, operação visual e validação automatizada de respostas e erros da API.

### 1. Painel Interativo de Gestão (`testar`)

Executa um painel visual completo no terminal (`scripts/painel.sh`) que **inicia a API automaticamente** caso esteja desligada e permite gerenciar clientes e agendamentos por meio de um menu numérico:

```bash
# Executando pelo atalho configurado
testar

# Ou executando diretamente pelo script
./scripts/painel.sh
```

**Funcionalidades disponíveis no painel:**
```text
===============================
   GESTÃO DE AGENDAMENTOS
===============================
1) Listar agendamentos
2) Novo agendamento
3) Editar agendamento
4) Mudar status
5) Excluir agendamento
6) Listar clientes
7) Cadastrar cliente
8) Excluir cliente
0) Sair
===============================
```

---

### 2. Menu de Validação de Status e Erros HTTP (`erros`)

Executa um menu interativo (`scripts/testar-menu.sh`) projetado para testar individualmente ou em lote os principais retornos de sucesso e erro da API (`201 Created`, `200 OK`, `400 Bad Request` e `404 Not Found`), exibindo o comando `cURL`, o cabeçalho HTTP e o JSON formatado:

```bash
# Executando pelo atalho configurado
erros

# Ou executando diretamente pelo script
./scripts/testar-menu.sh
```

**Cenários testados no menu:**
```text
====================================================
       TESTE DOS REQUISITOS DO ITEM 1 (API)
====================================================
 1) [201 Created]     Cadastrar (POST)
 2) [200 OK]          Query Params (?status=pendente)
 3) [200 OK]          Atualizar e Excluir (PATCH/DELETE)
 4) [400 Bad Request] Erro de validação de payload
 5) [404 Not Found]   Erro de ID não encontrado
 6) [TODOS]           Executar os 5 testes acima
 0) Sair
====================================================
```

---

### 3. Suíte de Testes Automatizados e Auditoria

Roda todos os fluxos de CRUD, filtros e validações de erro de ponta a ponta, salvando o relatório detalhado (`APROVADO` / `REPROVADO`) em `resultado_execucao.log`:

```bash
./scripts/testes_automacao.sh
```

Para consultar o log gerado após a execução:
```bash
cat resultado_execucao.log
```

---

### 4. Consulta Formatada de Agendamentos

Exibe no terminal um relatório consolidado cruzando os dados de clientes e agendamentos ativos:

```bash
./scripts/consultar_agendamentos.sh
```

---

### 5. Como ativar os atalhos `testar` e `erros` no terminal

Caso clone o repositório em um novo ambiente Linux e queira utilizar os comandos curtos `testar` e `erros` diretamente no terminal, adicione os aliases ao seu `~/.bashrc`:

```bash
echo "alias testar='$(pwd)/scripts/painel.sh'" >> ~/.bashrc
echo "alias erros='$(pwd)/scripts/testar-menu.sh'" >> ~/.bashrc
source ~/.bashrc
```

---

## 📡 Documentação da API

### Health Check (`/`)

| Método | Endpoint | Descrição | Resposta HTTP |
| :--- | :--- | :--- | :--- |
| `GET` | `/` | Verifica se a API está online e retorna a versão | `200 OK` |

---

### Endpoints de Clientes (`/clientes`)

| Método | Endpoint | Descrição | Resposta HTTP |
| :--- | :--- | :--- | :--- |
| `GET` | `/clientes` | Lista todos os clientes (suporta `?nome=` e `?email=`) | `200 OK` |
| `GET` | `/clientes/:id` | Busca um cliente específico pelo ID | `200 OK` / `404 Not Found` |
| `POST` | `/clientes` | Cadastra um novo cliente (valida e-mail único) | `201 Created` / `400 Bad Request` |
| `PUT` | `/clientes/:id` | Atualiza os dados de um cliente | `200 OK` / `400` / `404` |
| `PATCH` | `/clientes/:id` | Atualiza parcialmente os dados de um cliente | `200 OK` / `400` / `404` |
| `DELETE` | `/clientes/:id` | Remove um cliente (bloqueado se houver agendamentos) | `200 OK` / `400` / `404` |

#### Exemplo de Payload — Cadastro de Cliente (`POST /clientes`)
```json
{
  "nome": "João Silva",
  "email": "joao.silva@email.com",
  "telefone": "(11) 98765-4321"
}
```

---

### Endpoints de Agendamentos (`/agendamentos`)

| Método | Endpoint | Descrição | Resposta HTTP |
| :--- | :--- | :--- | :--- |
| `GET` | `/agendamentos` | Lista agendamentos (suporta filtros por query params) | `200 OK` / `400 Bad Request` |
| `GET` | `/agendamentos/:id` | Busca um agendamento específico pelo ID | `200 OK` / `404 Not Found` |
| `POST` | `/agendamentos` | Cria um novo agendamento (status inicial: `pendente`) | `201 Created` / `400 Bad Request` |
| `PUT` | `/agendamentos/:id` | Atualiza os dados ou status de um agendamento | `200 OK` / `400` / `404` |
| `PATCH` | `/agendamentos/:id` | Atualiza parcialmente um agendamento (ex.: status/horário) | `200 OK` / `400` / `404` |
| `DELETE` | `/agendamentos/:id` | Exclui um agendamento do sistema | `200 OK` / `404 Not Found` |

#### Exemplo de Payload — Cadastro de Agendamento (`POST /agendamentos`)
```json
{
  "clienteId": 1,
  "servico": "Corte de cabelo",
  "data": "2026-11-10",
  "horario": "14:30"
}
```

#### Exemplo de Payload — Atualização de Status (`PATCH /agendamentos/:id`)
```json
{
  "status": "confirmado"
}
```

---

### Filtros por Query Parameters

- **Clientes por Nome:** `GET /clientes?nome=Luis`
- **Clientes por E-mail:** `GET /clientes?email=luis.teste@email.com`
- **Agendamentos por Status:** `GET /agendamentos?status=pendente`
- **Agendamentos por Data:** `GET /agendamentos?data=2026-11-10`
- **Agendamentos por Cliente:** `GET /agendamentos?clienteId=1`
- **Filtro Combinado:** `GET /agendamentos?status=pendente&data=2026-11-10`

---

### Códigos de Status HTTP

| Código | Status | Significado na API |
| :--- | :--- | :--- |
| `200` | **OK** | Consulta, atualização (`PUT`/`PATCH`) ou exclusão (`DELETE`) concluída com sucesso |
| `201` | **Created** | Novo cliente ou agendamento cadastrado com sucesso (`POST`) |
| `204` | **No Content** | Requisição processada com sucesso sem corpo de resposta (padrão REST) |
| `400` | **Bad Request** | Campos obrigatórios ausentes, formato inválido, JSON malformado, e-mail duplicado ou cliente com agendamentos vinculados |
| `404` | **Not Found** | Cliente, agendamento ou rota não encontrada |
| `500` | **Internal Server Error** | Falha inesperada no servidor |

---

## ⚙️ Gerenciamento de Processos no Linux

O projeto possui um script dedicado para controlar a execução da API em segundo plano no Linux Debian, gerenciando automaticamente os arquivos `api.pid` e `api.log`:

- **Iniciar a API em segundo plano:**
  ```bash
  ./scripts/automacao.sh start
  ```

- **Verificar o status e o PID do processo:**
  ```bash
  ./scripts/automacao.sh status
  ```

- **Encerrar a API de forma graciosa:**
  ```bash
  ./scripts/automacao.sh stop
  ```

- **Comandos manuais alternativos:**
  ```bash
  ps aux | grep node   # Localizar o PID manualmente
  kill <PID>           # Encerramento gracioso
  kill -9 <PID>        # Encerramento forçado
  ```

---

## 👥 Autores e Créditos

Desenvolvido por:
- **Henzo Marcos Caetano Lopes**
- **Jean Lucas Martins Silva**
- **Luis Henrique de Souza Torres**

**Orientador:** Prof. Irineu Moura Caldeira  
**Instituição:** SENAI Mauá - Jairo Cândido  
**Curso:** Técnico em Desenvolvimento de Sistemas — Programação Back-End 1  
**Ano:** 2026
