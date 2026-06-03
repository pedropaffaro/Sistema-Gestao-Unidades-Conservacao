from pydantic import BaseModel, Field
from typing import Optional
from datetime import date
from decimal import Decimal


class UnidadeCreate(BaseModel):
    cnuc: str = Field(..., min_length=12, max_length=12, examples=["000123456789"])
    nome: Optional[str] = Field(None, max_length=100, example="Parque Nacional do Iguaçu")
    data_criacao: Optional[date] = Field(None, example="2026-12-31")
    bioma: Optional[str] = Field(None, max_length=30, example="Mata Atlântica")
    endereco: Optional[str] = Field(None, max_length=255, example="Rua X, 123, Cidade, Estado")
    orgao_gestor: Optional[str] = Field(None, max_length=100, example="ICMBio")
    area_total: Optional[Decimal] = Field(default=Decimal("0.00"), ge=0, example="12345.67")


class UnidadeResponse(BaseModel):
    cnuc: str
    nome: Optional[str]
    data_criacao: Optional[date]
    bioma: Optional[str]
    endereco: Optional[str]
    orgao_gestor: Optional[str]
    area_total: Optional[Decimal]