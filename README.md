# Sistema de Gestão de Unidades de Conservação (UC)

Este projeto foi desenvolvido no contexto da disciplina SCC0240 - Bases de Dados, ministrada pela Profª. Drª. Elaine Parros Machado de Sousa e acompanhada pelo monitor PAE Anderson Henrique Giacomini.

## Autoria

| Discente | NUSP |
| -- | -- |
| João Gabriel Pieroli da Silva | 15678578 |
| Luysa de Souza Gonçalves | 15474077 |
| Pedro Augusto Ferraro Paffaro | 15483380 |
| Pedro Lunkes Villela | 1548428 |


## Dependências

* **Linguagem Principal:** Python (v3.11+)
* **Framework Web:** [FastAPI](https://fastapi.tiangolo.com/) (Desenvolvimento de APIs rápidas e assíncronas)
* **Driver de Banco de Dados:** [asyncpg](https://github.com/MagicStack/asyncpg) (Cliente PostgreSQL assíncrono de alta performance)
* **Validação de Dados:** [Pydantic](https://docs.pydantic.dev/) (Modelagem e tipagem de dados)
* **Banco de Dados:** [PostgreSQL](https://www.postgresql.org/) (v15)
* **Ambiente:** [Docker](https://www.docker.com/) & [Docker Compose](https://docs.docker.com/compose/) (Orquestração de contêineres)

## Estrutura 

```text
Trabalho-BD/
├── backend/
│   ├── src/
│   │   ├── routers/          # Definição das rotas/endpoints da API
|   │   │   └── unidades.py  
│   │   ├── schemas.py        # Modelos Pydantic para validação de entrada/saída
│   │   ├── database.py       # Configuração e gerenciamento do pool de conexão com o banco
│   │   └── main.py           # 
│   ├── .env.example          # Modelo de configuração das variáveis de ambiente
│   ├── Dockerfile            # Configuração da imagem Docker do backend
│   └── requirements.txt      # Dependências Python do projeto
├── SQL/
|   ├── consultas.sql         # Arquivo com as 5 consultas
|   ├── dados.sql             # Ingestão de dados
│   └── esquema.sql           # Script DDL com a criação das tabelas com suas respectivas constraints
├── interface/
| ...
├── .dockerignore             # Arquivo para evitar o envio de lixo local para o Docker
├── docker-compose.yml        # Conecta os contêineres da aplicação
└── Makefile                  # Diretivas de comandos
```

## Como Inicializar o Projeto

### 1. Configurar as Variáveis de Ambiente

Antes de subir os serviços, cria um arquivo `.env` dentro do diretório `./backend` e insira as credenciais de acesso conforme o exemplo `.env.example`:

```env
DB_HOST=db
DB_PORT=5432
DB_NAME=trabalho_bd
DB_USER=pessoa
DB_PASSWORD=bdehdaora
```

### 2. Executar o Ambiente pela Primeira Vez

Para construir a imagem do backend e inicializar as tabelas automaticamente (caso necessário) por meio do `esquema.sql`, basta executar na raiz do projeto:

```bash
docker compose -p trabalho_bd --env-file ./backend/.env up -d --build
```

> É preferível utilizar o comando `make build` caso o `Makefile` esteja instalado.

Caso queira derrubar os containeres, utilize:

```bash
	docker compose -p trabalho_bd down
```

> É preferível utilizar o comando `make down` caso o `Makefile` esteja instalado.

Você também pode reinicilizar a aplicação (quando fizer mudanças no código, por exemplo), a partir de:

```bash
	docker compose -p trabalho_bd down
	docker compose -p trabalho_bd --env-file ./backend/.env up -d --build
```

> É preferível utilizar o comando `make restart` caso o `Makefile` esteja instalado.

### 3. Validar a Inicialização e Logs

Para garantir que a base de dados aplicou o script de estrutura sem falhar e que a API iniciou com sucesso, é interessante verificar os logs:

```bash
# Acompanhar a inicialização do banco de dados e as operações realizadas
docker compose -p trabalho_bd logs -f db
```

> É preferível utilizar o comando `make logs-db`, que executa esse trecho mais facilmente.

```bash
# Acompanhar as requisições recebidas pela API
docker compose -p trabalho_bd logs -f backend
```

> É preferível utilizar o comando `make logs-backend`, que executa esse trecho mais facilmente.

### 4. Acessar o banco

Para acessar o banco, você pode dar o comando:

```bash
make psql
```

## Como Usar a API

### Documentação Interativa (Swagger UI)

A API dispõe de uma interface gráfica nativa para a simulação de rotas e validações.

👉 **http://localhost:8000/docs**

Lá podes testar os endpoints clicando em **"Try it out"**, preenchendo os corpos das requisições e carregando em **"Execute"**.

---

### 2. Endpoints Principais — Módulo: Unidades de Conservação

#### A. Criar Nova Unidade

Submete uma nova UC para validação e armazenamento.

| Campo | Valor |
|-------|-------|
| **Método** | `POST` |
| **Rota** | `/unidades` |

**Exemplo de corpo da requisição:**

```json
{
  "cnuc": "123456789012",
  "nome": "Parque Nacional da Serra do Cipó",
  "data_criacao": "1984-09-25",
  "bioma": "Cerrado",
  "endereco": "Minas Gerais, Brasil",
  "orgao_gestor": "ICMBio",
  "area_total": 33800.00
}
```

**Retornos mapeados:**

| Código | Descrição |
|--------|-----------|
| `201 Created` | Sucesso. Retorna o JSON do registo inserido. |
| `409 Conflict` | O código `cnuc` fornecido já existe no sistema. |
| `422 Unprocessable Entity` | Falha na validação de dados. |

---

#### B. Listar Unidades com Filtros Dinâmicos

Pesquisa por unidades de conservação com filtros parametrizados a partir do operador lógico `AND`, ou seja, deve atender a todos os critérios, quando existirem.

| Campo | Valor |
|-------|-------|
| **Método** | `GET` |
| **Rota** | `/unidades` |

**Parâmetros de busca:**

| Parâmetro | Tipo | Formato |
|-----------|------|---------|
| `nome` | string | — |
| `bioma` | string | — |
| `orgao_gestor` | string | — |
| `data_criacao` | date | `YYYY-MM-DD` |

> Vale destacar que esses parâmetros são opcionais, ou seja, caso nenhum deles seja colocado na consulta, será realizada a consulta de todas as unidades cadastradas

**Retornos mapeados:**

| Código | Descrição |
|--------|-----------|
| `200 OK` | Retorna uma lista com todas as unidades correspondentes aos critérios. |
| `404 Not Found` | Nenhum registo atende aos filtros aplicados. |