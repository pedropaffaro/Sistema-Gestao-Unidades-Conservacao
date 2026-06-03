from fastapi import APIRouter, Depends, HTTPException, Query, status
from typing import Optional
from datetime import date
import asyncpg

from database import get_env_pool
from schemas import UnidadeCreate, UnidadeResponse

router = APIRouter(prefix="/unidades", tags=["Unidades de Conservação"])


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
            (cnuc, nome, data_criacao, bioma, endereco, orgao_gestor, area_total)
        VALUES ($1, $2, $3, $4, $5, $6, $7)
        RETURNING *
    """
    try:
        async with pool.acquire() as conn:
            row = await conn.fetchrow(
                sql,
                payload.cnuc,
                payload.nome,
                payload.data_criacao,
                payload.bioma,
                payload.endereco,
                payload.orgao_gestor,
                payload.area_total,
            )
    except asyncpg.UniqueViolationError:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=f"Já existe uma unidade com cnuc '{payload.cnuc}'.",
        )

    return dict(row)


@router.get(
    "",
    response_model=list[UnidadeResponse],
    status_code=status.HTTP_200_OK,
    summary="Consultar unidades com filtros",
)
async def listar_unidades(
    nome: Optional[str] = Query(None, description="Busca parcial no nome"),
    bioma: Optional[str] = Query(None, description="Busca parcial no bioma"),
    orgao_gestor: Optional[str] = Query(None, description="Busca parcial no órgão gestor"),
    data_criacao: Optional[date] = Query(None, description="Data exata de criação (YYYY-MM-DD)"),
    pool: asyncpg.Pool = Depends(get_env_pool),
):
    conditions = []
    params = []
    i = 1

    if nome:
        conditions.append(f"nome ILIKE ${i}")
        params.append(f"%{nome}%")
        i += 1
    if bioma:
        conditions.append(f"bioma ILIKE ${i}")
        params.append(f"%{bioma}%")
        i += 1
    if orgao_gestor:
        conditions.append(f"orgao_gestor ILIKE ${i}")
        params.append(f"%{orgao_gestor}%")
        i += 1
    if data_criacao:
        conditions.append(f"data_criacao = ${i}")
        params.append(data_criacao)
        i += 1

    where = f"WHERE {' AND '.join(conditions)}" if conditions else ""
    sql = f"SELECT * FROM unidade_conservacao {where} ORDER BY cnuc"

    try:
        async with pool.acquire() as conn:
            rows = await conn.fetch(sql, *params)
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