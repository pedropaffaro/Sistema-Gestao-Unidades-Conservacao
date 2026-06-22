# Resultados Esperados das Consultas

Dataset completo = `dados.sql` (já inclui os casos de borda no final do arquivo).
A numeração segue a versão atual de `consultas.sql` (Consultas 1 a 5).

---

## Consulta 1 — Funcionários com mais de uma categoria por unidade de conservação

```sql
SELECT F.unidade_conservacao, COUNT(*) AS nro_funcionarios_multicategoricos
FROM funcionario F
JOIN (
    SELECT funcionario FROM funcionario_categoria
    GROUP BY funcionario HAVING COUNT(*) > 1
) AS funcionarios_validos ON funcionarios_validos.funcionario = F.nro_funcional
GROUP BY F.unidade_conservacao;
```

### Resultado esperado (desconsiderando ordenação)

| unidade_conservacao | nro_funcionarios_multicategoricos |
|---|---|
| 0000.00.0001 | 2 |
| 0000.00.0002 | 2 |
| 0000.00.0003 | 2 |
| 0000.00.0004 | 2 |
| 0000.00.0012 | 1 |

---

## Consulta 2 — Biólogos que nunca fizeram observação por câmera à noite

```sql
SELECT FC.funcionario, F.nome
FROM funcionario_categoria FC
JOIN funcionario F ON F.nro_funcional = FC.funcionario
WHERE FC.categoria = 'BIOLOGO'
  AND NOT EXISTS (
      SELECT 1 FROM observacao O
      WHERE O.biologo = FC.funcionario
        AND O.metodo = 'CAMERA'
        AND (EXTRACT(HOUR FROM O.data_hora) >= 18 OR EXTRACT(HOUR FROM O.data_hora) <= 5)
  );
```

### Resultado esperado (desconsiderando ordenação)

| funcionario | nome |
|---|---|
| 2001 | Ana Batista |
| 3002 | Luciana Alves |
| 4002 | Patricia Lima |
| 9003 | Douglas Silva |

> Casos de borda (em `dados.sql`): biólogos 5002 (câmera às 18:00) e 7002
> (câmera às 05:00) ficam de fora pelos limites inclusivos; 4002 (câmera às
> 17:59, diurno) permanece na lista.

---

## Consulta 3 — Visitas educativas com guia qualificado (biólogo ou pesquisador)

```sql
SELECT * FROM visita V
WHERE V.guia IS NOT NULL
  AND V.tipo = 'EDUCATIVA'
  AND (
      EXISTS (SELECT 1 FROM funcionario_categoria FC
              WHERE FC.funcionario = V.guia AND UPPER(FC.categoria) = 'BIOLOGO')
      OR
      EXISTS (SELECT 1 FROM pesquisa_pesquisador PP
              WHERE PP.pesquisador = V.guia)
  );
```

### Resultado esperado (desconsiderando ordenação)

| cod_visita | unidade_conservacao | nro_zona | nro_visita | data_hora | tipo | nro_visitantes | guia |
|---|---|---|---|---|---|---|---|
| 11 | 0000.00.0001 | 2 | 104 | 2026-06-18 10:00:00 | EDUCATIVA | 2 | 1003 |
| 13 | 0000.00.0002 | 2 | 204 | 2026-06-22 09:00:00 | EDUCATIVA | 3 | 2002 |

> `cod_visita` depende da ordem de inserção (coluna IDENTITY); os valores acima
> assumem a carga padrão de `dados.sql`.

---

## Consulta 4 — Espécies sem nenhum ser vivo registrado

```sql
SELECT E.nome_cientifico, E.status_conservacao, COUNT(PE.pesquisa) AS qte_pesquisas
FROM especie E
LEFT JOIN pesquisa_especie PE ON E.nome_cientifico = PE.especie
WHERE NOT EXISTS (
    SELECT 1 FROM ser_vivo S WHERE S.especie = E.nome_cientifico
)
GROUP BY E.nome_cientifico, E.status_conservacao;
```

### Resultado esperado (desconsiderando ordenação)

| nome_cientifico | status_conservacao | qte_pesquisas |
|---|---|---|
| Agaricus blazei | DD | 0 |
| Araucaria angustifolia | CR | 1 |
| Caryocar brasiliense | LC | 1 |
| Handroanthus albus | LC | 0 |
| Hevea brasiliensis | LC | 1 |

---

## Consulta 5 — Pesquisas que estudam TODAS as espécies CR

```sql
SELECT P.titulo
FROM pesquisa P
WHERE NOT EXISTS (
    SELECT E.nome_cientifico FROM especie E
    WHERE E.status_conservacao = 'CR'
    EXCEPT
    SELECT PE.especie FROM pesquisa_especie PE
    WHERE PE.pesquisa = P.titulo
);
```

### Resultado esperado

| titulo |
|---|
| Conservação de Espécies Criticamente Ameaçadas do Brasil |
| DICIONARIO DE RISCOS - Uma pesquisa sobre todas as especies em extinção no Brasil |
| Revisão sisetmática de todas as espécies que eu consegui lembrar |

> Espécies CR no dataset: Trichechus manatus e Araucaria angustifolia.
> Casos de teste da divisão (no final de `dados.sql`): cobrir as 2 CR (com ou
> sem espécie extra) faz a pesquisa aparecer; cobrir só o peixe-boi ou nenhuma
> espécie a deixa de fora.

---
