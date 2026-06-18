PROJECT=trabalho_bd

.PHONY: help up build down restart logs logs-front bash-front logs-backoffice bash-backoffice logs-backend bash-backend psql logs-db ps

restart: ## Reinicia o projeto
	docker compose -p $(PROJECT) down
	docker compose -p $(PROJECT) --env-file ./backend/.env up -d --build

help: ## Mostra este menu de ajuda com os comandos disponíveis
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-16s\033[0m %s\n", $$1, $$2}'

up: ## Sobe todos os contêineres do projeto em segundo plano
	docker compose -p $(PROJECT) --env-file ./backend/.env up -d

build: ## Reconstrói as imagens e sobe os contêineres
	docker compose -p $(PROJECT) --env-file ./backend/.env up -d --build

down: ## Derruba todos os contêineres 
	docker compose -p $(PROJECT) down

logs: ## Mostra os logs de TODOS os serviços em tempo real
	docker compose -p $(PROJECT) logs -f

logs-front: ## Mostra os logs apenas do contêiner interface
	docker compose -p $(PROJECT) logs -f interface

bash-front: ## Abre o terminal interativo dentro do interface
	docker compose -p $(PROJECT) exec interface sh

logs-backend: ## Mostra os logs apenas do contêiner backend
	docker compose -p $(PROJECT) logs -f backend

bash-backend: ## Abre o terminal (bash) interativo dentro do backend
	docker compose -p $(PROJECT) exec backend sh

psql: ## Acessa o banco de dados PostgreSQL via CLI usando as variáveis do .env
	docker compose -p $(PROJECT) exec db sh -c 'psql -U $$DB_USER -d $$DB_NAME'

reset: ## Além de derrubar os contêineres, remove os volumes para resetar o banco de dados
	docker compose -p $(PROJECT) down -v

ingest: ## Executa o arquivo SQL de ingestão de dados no banco em execução.
	docker compose -p $(PROJECT) exec -T db sh -c 'psql -U $$DB_USER -d $$DB_NAME' < SQL/dados.sql

logs-db: ## Mostra os logs apenas do banco de dados
	docker compose -p $(PROJECT) logs -f db

ps: ## Lista o status e as portas de todos os contêineres ativos do projeto
	docker compose -p $(PROJECT) ps