from fastapi import APIRouter, Depends, HTTPException, Query, status
from typing import Optional
from datetime import date, datetime
import asyncpg

from database import get_env_pool
from schemas import UnidadeCreate, UnidadeResponse

router = APIRouter(prefix="/unidades", tags=["Unidades de Conservação"])


# Sentinela: o literal "null" nos filtros busca registros com a coluna NULL.
def _is_null_search(value: Optional[str]) -> bool:
    return value is not None and value.strip().lower() == "null"


# Acumula uma condição WHERE parametrizada ($i) e retorna o próximo índice.
# exact=True compara por igualdade; caso contrário usa ILIKE (busca parcial).
def _add_condition(
    field: str,
    value: Optional[str],
    conditions: list,
    params: list,
    i: int,
    *,
    exact: bool = False,
) -> int:
    if value is None:
        return i
    if _is_null_search(value):
        conditions.append(f"{field} IS NULL")
    elif exact:
        conditions.append(f"{field} = ${i}")
        params.append(value)
        i += 1
    else:
        conditions.append(f"{field} ILIKE ${i}")
        params.append(f"%{value}%")
        i += 1
    return i


# Mapeia o nome da constraint do PostgreSQL para uma mensagem amigável.
_CONSTRAINT_MSGS: dict[str, str] = {
    "pk_unidade_conservacao": "Já existe uma unidade com este CNUC.",
    "ck_cnuc_formato": "CNUC deve conter exatamente 12 dígitos numéricos.",
    "ck_area_total": "Área total deve ser maior ou igual a zero.",
    "ck_km_valido": "KM deve ser um valor entre 0 e 9999.",
    "ck_uf": "UF inválida. Use uma sigla de estado brasileiro (ex: SP).",
}


# Converte erros do asyncpg em HTTPException com status e mensagem adequados.
def _db_error_to_http(e: Exception, cnuc: str = "") -> HTTPException:
    if isinstance(e, asyncpg.UniqueViolationError):
        constraint = getattr(e, "constraint_name", "")
        detail = _CONSTRAINT_MSGS.get(constraint)
        if detail is None:
            detail = (
                f"Já existe uma unidade com CNUC '{cnuc}'."
                if cnuc
                else "Registro duplicado."
            )
        return HTTPException(status_code=status.HTTP_409_CONFLICT, detail=detail)

    if isinstance(e, asyncpg.CheckViolationError):
        constraint = getattr(e, "constraint_name", "")
        detail = _CONSTRAINT_MSGS.get(
            constraint, f"Valor inválido: restrição '{constraint}' violada."
        )
        return HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, detail=detail
        )

    if isinstance(e, asyncpg.NotNullViolationError):
        col = getattr(e, "column_name", "desconhecido")
        return HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=f"O campo '{col}' é obrigatório e não pode ser nulo.",
        )

    if isinstance(e, asyncpg.StringDataRightTruncationError):
        return HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="Valor muito longo para um dos campos. Verifique os tamanhos máximos.",
        )

    if isinstance(e, asyncpg.ForeignKeyViolationError):
        pg_detail = getattr(e, "detail", "") or ""
        if "still referenced" in pg_detail:
            detail = "Não é possível excluir: existem registros vinculados a esta unidade em outras tabelas."
        else:
            detail = "Referência inválida: registro relacionado não encontrado."
        return HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, detail=detail
        )

    if isinstance(e, asyncpg.DataError):
        return HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="Valor inválido para um dos campos.",
        )

    return HTTPException(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        detail=f"Erro interno no banco de dados: {e}",
    )


@router.post(
    "",
    response_model=UnidadeResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Cadastrar unidade de conservação",
)
async def criar_unidade(
    payload: UnidadeCreate,
    pool: asyncpg.Pool = Depends(get_env_pool),
):
    sql = """
        INSERT INTO unidade_conservacao
            (cnuc, nome, data_criacao, bioma, rodovia, km, cidade, uf, descricao_acesso, orgao_gestor, area_total)
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
        RETURNING *
    """
    async with pool.acquire() as conn:
        await conn.execute("BEGIN")
        try:
            row = await conn.fetchrow(
                sql,
                payload.cnuc,
                payload.nome,
                payload.data_criacao,
                payload.bioma,
                payload.rodovia,
                payload.km,
                payload.cidade,
                payload.uf,
                payload.descricao_acesso,
                payload.orgao_gestor,
                payload.area_total,
            )
            await conn.execute("COMMIT")
        except asyncpg.PostgresError as e:
            await conn.execute("ROLLBACK")
            raise _db_error_to_http(e, cnuc=payload.cnuc)

    return dict(row)


@router.get(
    "",
    response_model=list[UnidadeResponse],
    status_code=status.HTTP_200_OK,
    summary="Consultar unidades com filtros",
)
async def listar_unidades(
    cnuc: Optional[str] = Query(None, description="Busca exata pelo CNUC"),
    nome: Optional[str] = Query(
        None, description="Busca parcial no nome (use 'null' para campos vazios)"
    ),
    bioma: Optional[str] = Query(
        None, description="Busca parcial no bioma (use 'null' para campos vazios)"
    ),
    orgao_gestor: Optional[str] = Query(
        None,
        description="Busca parcial no órgão gestor (use 'null' para campos vazios)",
    ),
    data_criacao: Optional[str] = Query(
        None, description="Data exata AAAA-MM-DD (use 'null' para campos vazios)"
    ),
    rodovia: Optional[str] = Query(
        None, description="Busca parcial na rodovia (use 'null' para campos vazios)"
    ),
    cidade: Optional[str] = Query(
        None, description="Busca parcial na cidade (use 'null' para campos vazios)"
    ),
    uf: Optional[str] = Query(
        None, description="Busca exata no UF (use 'null' para campos vazios)"
    ),
    km: Optional[str] = Query(
        None, description="KM exato (use 'null' para campos vazios)"
    ),
    pool: asyncpg.Pool = Depends(get_env_pool),
):
    conditions = []
    params = []
    i = 1

    if cnuc:
        conditions.append(f"cnuc = ${i}")
        params.append(cnuc)
        i += 1

    i = _add_condition("nome", nome, conditions, params, i)
    i = _add_condition("bioma", bioma, conditions, params, i)
    i = _add_condition("orgao_gestor", orgao_gestor, conditions, params, i)
    i = _add_condition("rodovia", rodovia, conditions, params, i)
    i = _add_condition("cidade", cidade, conditions, params, i)
    i = _add_condition("uf", uf, conditions, params, i, exact=True)

    if data_criacao:
        if _is_null_search(data_criacao):
            conditions.append("data_criacao IS NULL")
        else:
            dc = None
            for fmt in ("%d-%m-%Y", "%d/%m/%Y", "%Y-%m-%d", "%Y/%m/%d"):
                try:
                    dc = datetime.strptime(data_criacao, fmt).date()
                    break
                except ValueError:
                    pass
            if dc is None:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="data_criacao deve estar no formato DD-MM-AAAA (ex: 31-12-2026) ou 'null'",
                )
            conditions.append(f"data_criacao = ${i}")
            params.append(dc)
            i += 1

    if km:
        if _is_null_search(km):
            conditions.append("km IS NULL")
        else:
            try:
                conditions.append(f"km = ${i}")
                params.append(int(km))
                i += 1
            except ValueError:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="km deve ser um número inteiro ou 'null'",
                )

    where = f"WHERE {' AND '.join(conditions)}" if conditions else ""
    sql = f"SELECT * FROM unidade_conservacao {where} ORDER BY cnuc"

    try:
        async with pool.acquire() as conn:
            rows = await conn.fetch(sql, *params)
    except asyncpg.PostgresError as e:
        raise _db_error_to_http(e)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Erro ao consultar unidades: {str(e)}",
        )
    if not rows:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Nenhuma unidade de conservação encontrada com os filtros fornecidos.",
        )

    return [dict(r) for r in rows]


@router.delete(
    "/{cnuc}",
    response_model=UnidadeResponse,
    status_code=status.HTTP_200_OK,
    summary="Deletar unidade de conservação por CNUC",
)
async def deletar_unidade(
    cnuc: str,
    pool: asyncpg.Pool = Depends(get_env_pool),
):
    sql = "DELETE FROM unidade_conservacao WHERE cnuc = $1 RETURNING *"
    async with pool.acquire() as conn:
        await conn.execute("BEGIN")
        try:
            row = await conn.fetchrow(sql, cnuc)
            await conn.execute("COMMIT")
        except asyncpg.PostgresError as e:
            await conn.execute("ROLLBACK")
            raise _db_error_to_http(e, cnuc=cnuc)
    if not row:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Unidade de conservação com cnuc '{cnuc}' não encontrada.",
        )
    return dict(row)


@router.put(
    "/{cnuc}",
    response_model=UnidadeResponse,
    status_code=status.HTTP_200_OK,
    summary="Atualizar unidade de conservação por CNUC",
)
async def atualizar_unidade(
    cnuc: str,
    payload: UnidadeCreate,
    pool: asyncpg.Pool = Depends(get_env_pool),
):
    # O CNUC é a PK: atualizá-lo é permitido e propaga via ON UPDATE CASCADE.
    # $1 = novo CNUC (payload); $12 = CNUC atual (rota), usado no WHERE.
    sql = """
        UPDATE unidade_conservacao
        SET cnuc = $1, nome = $2, data_criacao = $3, bioma = $4, rodovia = $5, km = $6,
            cidade = $7, uf = $8, descricao_acesso = $9, orgao_gestor = $10, area_total = $11
        WHERE cnuc = $12
        RETURNING *
    """
    async with pool.acquire() as conn:
        await conn.execute("BEGIN")
        try:
            row = await conn.fetchrow(
                sql,
                payload.cnuc,
                payload.nome,
                payload.data_criacao,
                payload.bioma,
                payload.rodovia,
                payload.km,
                payload.cidade,
                payload.uf,
                payload.descricao_acesso,
                payload.orgao_gestor,
                payload.area_total,
                cnuc,
            )
            await conn.execute("COMMIT")
        except asyncpg.PostgresError as e:
            await conn.execute("ROLLBACK")
            raise _db_error_to_http(e, cnuc=cnuc)
    if not row:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Unidade de conservação com cnuc '{cnuc}' não encontrada.",
        )
    return dict(row)
