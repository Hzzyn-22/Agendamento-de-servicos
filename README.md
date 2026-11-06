# Sistema de Agendamento de Serviços - API RESTful

API RESTful desenvolvida em **Node.js** com **Express** para a gestão integrada de clientes e agendamentos de serviços. Projeto desenvolvido como Projeto Integrador para a disciplina de **Programação Back-End 1** do **SENAI Mauá - Jairo Cândido**.

---

## Sumário

- [Visão Geral](#visão-geral)
- [Recursos Principais](#recursos-principais)
- [Tecnologias Utilizadas](#tecnologias-utilizadas)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Instalação e Execução](#instalação-e-execução)
- [Documentação da API](#documentação-da-api)
  - [Endpoints de Clientes](#endpoints-de-clientes-clientes)
  - [Endpoints de Agendamentos](#endpoints-de-agendamentos-agendamentos)
- [Filtros por Query Parameters](#filtros-por-query-parameters)
- [Automação de Testes e Auditoria](#automação-de-testes-e-auditoria)
- [Gerenciamento de Processos no Linux](#gerenciamento-de-processos-no-linux)
- [Autores e Créditos](#autores-e-créditos)

---

## Visão Geral

O sistema provê uma solução completa para cadastramento de clientes e agendamento de atendimentos. A aplicação segue o padrão arquitetural RESTful, operando na porta `3016` com persistência em memória e validação completa de dados de entrada.

---

## Recursos Principais

- **CRUD Completo:** Operações de criação, leitura, atualização (total e parcial) e exclusão para as entidades `Clientes` e `Agendamentos`.
- **Validação Estrutural de Dados:** Verificação rigorosa de campos obrigatórios, datas no formato `AAAA-MM-DD`, horários `HH:mm` e status (`PENDENTE`, `CONFIRMADO`, `CONCLUIDO`, `CANCELADO`).
- **Filtros Flexíveis:** Suporte a filtros combinados ou individuais via *Query Parameters*.
- **Padronização HTTP:** Devolução dos códigos de estado HTTP padronizados (`200 OK`, `201 Created`, `204 No Content`, `400 Bad Request`, `404 Not Found`, `409 Conflict`, `500 Internal Server Error`).
- **Automação de Testes:** Script executável em Shell Script com `cURL` e `jq` para testes funcionais e geração de arquivo de log de auditoria.

---

## Tecnologias Utilizadas

- **Ambiente de Execução:** Node.js
- **Framework Web:** Express
- **Persistência de Dados:** Armazenamento em memória (In-memory storage)
- **Automação e Testes:** Shell Script (Bash), cURL, jq
- **Ambiente Operacional de Referência:** Linux Debian
- **Controle de Versão:** Git & GitHub

---

## Estrutura do Projeto

```plaintext
Agendamento-de-servicos/
├── scripts/
│   └── testes.sh             # Script em Bash para testes de integração
├── src/
│   ├── controllers/
│   │   ├── agendamentosController.js  # Lógica de negócio da entidade Agendamentos
│   │   └── clientesController.js      # Lógica de negócio da entidade Clientes
│   ├── data/
│   │   └── database.js               # Camada de persistência temporária em memória
│   └── routes/
│       ├── agendamentos.js           # Roteamento dos endpoints de agendamentos
│       └── clientes.js               # Roteamento dos endpoints de clientes
├── .gitignore
├── package.json
├── package-lock.json
├── README.md
├── resultado_execucao.log            # Log gerado pelo script de testes
└── server.js                         # Inicialização do servidor HTTP (Porta 3016)
```

---

## Instalação e Execução

### Pré-requisitos

- **Node.js** (versão 16.x ou superior)
- **NPM** (Gerenciador de pacotes do Node)
- **Bash Terminal** (Linux, macOS ou Git Bash no Windows)

### Passo a Passo

1. **Clonar o repositório:**
   ```bash
   git clone https://github.com/seu-usuario/Agendamento-de-servicos.git
   cd Agendamento-de-servicos
   ```

2. **Instalar as dependências:**
   ```bash
   npm install
   ```

3. **Iniciar o servidor:**
   ```bash
   npm start
   ```

> **Nota:** O servidor estará disponível no endereço `http://localhost:3016`.

---

## Documentação da API

### Endpoints de Clientes (`/clientes`)

| Método | Endpoint | Descrição | Resposta HTTP |
| :--- | :--- | :--- | :--- |
| `GET` | `/clientes` | Retorna a lista de todos os clientes | `200 OK` |
| `GET` | `/clientes/:id` | Retorna os dados de um cliente específico pelo ID | `200 OK` / `404 Not Found` |
| `POST` | `/clientes` | Cadastra um novo cliente | `201 Created` / `400 Bad Request` |
| `PUT` | `/clientes/:id` | Atualização completa dos dados de um cliente | `200 OK` / `400` / `404` |
| `PATCH` | `/clientes/:id` | Atualização parcial dos dados de um cliente | `200 OK` / `400` / `404` |
| `DELETE` | `/clientes/:id` | Remove um cliente do sistema | `200 OK` / `204` / `404` |

#### Exemplo de Payload - Cadastro de Cliente (`POST /clientes`)
```json
{
  "nome": "João Silva",
  "telefone": "(11) 98765-4321",
  "email": "joao.silva@email.com"
}
```

---

### Endpoints de Agendamentos (`/agendamentos`)

| Método | Endpoint | Descrição | Resposta HTTP |
| :--- | :--- | :--- | :--- |
| `GET` | `/agendamentos` | Retorna a lista de agendamentos (suporta filtros) | `200 OK` |
| `GET` | `/agendamentos/:id` | Retorna um agendamento específico pelo ID | `200 OK` / `404 Not Found` |
| `POST` | `/agendamentos` | Cadastra um novo agendamento | `201 Created` / `400` / `404` |
| `PUT` | `/agendamentos/:id` | Atualização completa de um agendamento | `200 OK` / `400` / `404` |
| `PATCH` | `/agendamentos/:id` | Atualização parcial de um agendamento | `200 OK` / `400` / `404` |
| `DELETE` | `/agendamentos/:id` | Remove/Cancela um agendamento | `200 OK` / `204` / `404` |

#### Exemplo de Payload - Cadastro de Agendamento (`POST /agendamentos`)
```json
{
  "clienteId": 1,
  "servico": "Manutenção Preventiva",
  "data": "2026-11-10",
  "horario": "14:30",
  "status": "PENDENTE"
}
```

---

## Filtros por Query Parameters

O endpoint `GET /agendamentos` permite filtrar registros dinamicamente:

- **Por Status:** `GET /agendamentos?status=CONFIRMADO`
- **Por Data:** `GET /agendamentos?data=2026-11-10`
- **Por Cliente:** `GET /agendamentos?clienteId=1`
- **Filtro Combinado:** `GET /agendamentos?status=PENDENTE&data=2026-11-10`

---

## Automação de Testes e Auditoria

O projeto conta com um script automatizado que realiza testes de integração em todos os endpoints e grava o resultado num arquivo de log.

1. **Conceder permissão de execução ao script:**
   ```bash
   chmod +x scripts/testes.sh
   ```

2. **Executar a suíte de testes e gerar log:**
   ```bash
   ./scripts/testes.sh > resultado_execucao.log 2>&1
   ```

3. **Visualizar o resultado:**
   ```bash
   cat resultado_execucao.log
   ```

---

## Gerenciamento de Processos no Linux

Comandos úteis para gerenciamento da aplicação em ambiente Linux Debian:

- **Localizar o PID do processo em execução:**
  ```bash
  ps aux | grep node
  ```

- **Encerrar o processo de forma graciosa:**
  ```bash
  kill <PID>
  ```

- **Forçar encerramento do processo:**
  ```bash
  kill -9 <PID>
  ```

---

## Autores e Créditos

Desenvolvido por:
- **Henzo Marcos Caetano Lopes**
- **Jean Lucas Martins Silva**
- **Luis Henrique de Souza Torres**

**Orientador:** Prof. Irineu Moura Caldeira  
**Instituição:** SENAI Mauá - Jairo Cândido  
**Curso:** Técnico em Desenvolvimento de Sistemas — Programação Back-End 1  
**Ano:** 2026
