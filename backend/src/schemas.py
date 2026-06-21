from pydantic import BaseModel, Field, field_validator, field_serializer
from typing import Optional
from datetime import date, datetime
from decimal import Decimal


class UnidadeCreate(BaseModel):
    # Sem min/max_length: a validação é feita no validator abaixo para garantir
    # mensagem de erro em português (o constraint do Pydantic emitiria em inglês).
    cnuc: str = Field(..., examples=["000123456789"])
    nome: Optional[str] = Field(
        None, max_length=100, example="Parque Nacional do Iguaçu"
    )
    data_criacao: Optional[date] = Field(None, example="31-12-2026")
    bioma: Optional[str] = Field(None, max_length=30, example="Mata Atlântica")

    @field_validator("cnuc")
    @classmethod
    def valida_cnuc(cls, v):
        if not (v.isdigit() and len(v) == 12):
            raise ValueError("CNUC deve conter exatamente 12 dígitos numéricos.")
        return v

    @field_validator("data_criacao", mode="before")
    @classmethod
    def parse_data(cls, v):
        if v is None or isinstance(v, date):
            return v
        if isinstance(v, str):
            for fmt in ("%d-%m-%Y", "%d/%m/%Y", "%Y-%m-%d", "%Y/%m/%d"):
                try:
                    return datetime.strptime(v, fmt).date()
                except ValueError:
                    pass
            raise ValueError("Data deve estar no formato DD-MM-AAAA (ex: 31-12-2026)")
        return v

    rodovia: Optional[str] = Field(None, max_length=100, example="BR 469")
    km: Optional[int] = Field(None, ge=0, example=18)
    cidade: Optional[str] = Field(None, max_length=100, example="Foz do Iguaçu")
    # Sem max_length: validado abaixo para emitir mensagem em português.
    uf: Optional[str] = Field(None, example="PR")

    @field_validator("uf")
    @classmethod
    def valida_uf(cls, v):
        if v is None:
            return v
        if len(v) != 2 or not v.isalpha():
            raise ValueError("UF deve conter exatamente 2 letras (ex: SP).")
        return v.upper()
    descricao_acesso: Optional[str] = Field(
        None, max_length=255, example="Acesso pela marginal da rodovia"
    )
    orgao_gestor: Optional[str] = Field(None, max_length=100, example="ICMBio")
    area_total: Optional[Decimal] = Field(
        default=Decimal("0.00"), ge=0, example="12345.67"
    )


class UnidadeResponse(BaseModel):
    cnuc: str
    nome: Optional[str] = None
    data_criacao: Optional[date] = None
    bioma: Optional[str] = None
    rodovia: Optional[str] = None
    km: Optional[int] = None
    cidade: Optional[str] = None
    uf: Optional[str] = None
    descricao_acesso: Optional[str] = None
    orgao_gestor: Optional[str] = None
    area_total: Optional[Decimal] = None

    @field_serializer("data_criacao")
    def format_data(self, v: Optional[date]) -> Optional[str]:
        return v.strftime("%d-%m-%Y") if v else None

