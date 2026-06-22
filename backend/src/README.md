# Backend — `backend/src/`

API FastAPI (assíncrona) que expõe o CRUD de Unidades de Conservação sobre
PostgreSQL, usando **asyncpg** como driver.

## Arquivos

| Arquivo | Papel |
|---------|-------|
| `main.py` | Cria o `FastAPI`, registra o router e gerencia o ciclo de vida (abre/fecha o pool no `lifespan`). |
| `database.py` | Cria e guarda o pool de conexões asyncpg; expõe `get_env_pool` (injeção de dependência). |
| `schemas.py` | Modelos Pydantic (`UnidadeCreate`/`UnidadeResponse`): validação de entrada/saída e formato de data. |
| `routers/unidades.py` | Endpoints `/unidades` (POST/GET/PUT/DELETE) e tradução de erros do banco para HTTP. |

## Como o asyncpg é usado

### 1. Pool de conexões (`database.py`)
Um único pool global, criado uma vez e reutilizado entre requisições:

```python
_pool = await asyncpg.create_pool(host=..., port=..., database=..., user=..., password=...)
```

`main.py` abre o pool na subida (`lifespan`) e chama `await _pool.close()` no
shutdown. `get_env_pool` é entregue via `Depends(...)` aos endpoints.

### 2. Aquisição de conexão e transação (`routers/unidades.py`)
Cada escrita pega uma conexão do pool e controla a transação manualmente:

```python
async with pool.acquire() as conn:        # conexão emprestada do pool
    await conn.execute("BEGIN")
    try:
        row = await conn.fetchrow(sql, ...)   # executa e retorna 1 linha
        await conn.execute("COMMIT")
    except asyncpg.PostgresError as e:
        await conn.execute("ROLLBACK")        # desfaz em qualquer erro do banco
        raise _db_error_to_http(e, cnuc=...)
```

### 3. Consultas e parâmetros
Sempre com **placeholders posicionais `$1, $2, ...`** (não f-string de valores)
— o asyncpg envia os parâmetros separados, evitando SQL injection:

- `conn.fetchrow(sql, *args)` → POST/PUT/DELETE com `RETURNING *` (1 linha).
- `conn.fetch(sql, *params)` → GET (lista de linhas).
- Em `listar_unidades`, o `WHERE` é montado dinamicamente: só os **nomes de
  coluna/operador** entram na string; os **valores** vão sempre como `$i`.

O retorno é um `asyncpg.Record`, convertido para `dict(row)` antes de devolver.

### 4. Erros tipados → HTTP (`_db_error_to_http`)
asyncpg levanta exceções específicas por constraint violada; o código mapeia
cada uma para status + mensagem em português, lendo atributos da exceção:

| Exceção asyncpg | HTTP | Atributo usado |
|-----------------|------|----------------|
| `UniqueViolationError` | 409 | `constraint_name` |
| `CheckViolationError` | 422 | `constraint_name` |
| `NotNullViolationError` | 422 | `column_name` |
| `StringDataRightTruncationError` | 422 | — |
| `ForeignKeyViolationError` | 422 | `detail` (detecta `still referenced`) |
| `DataError` | 422 | — |
| `PostgresError` (base) | 500 | — |

`constraint_name` é casado contra `_CONSTRAINT_MSGS` (ex.: `ck_uf`, `ck_km_valido`)
para devolver a mensagem amigável correspondente.
