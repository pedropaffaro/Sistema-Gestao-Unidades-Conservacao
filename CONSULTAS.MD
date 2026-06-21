# Consultas Implementadas

Neste texto destacamos para cada uma das cinco buscas desenvolvidas quais seus objetivos, utilidades e implementação.

---

## 1° Consulta:
__Descrição da Consulta:__ Identifica e quantifica os funcionários que possuem mais de uma atribuição funcional ativa no sistema. O resultado entrega o número absoluto dos colaboradores com mais de uma função, distribuindo e agrupando as contagens de acordo com a Unidade de Conservação onde estão alocados.

__Utilidade:__ Serve como um indicador de flexibilidade no gerenciamento de recursos humanos. Para a administração central, mapear quais Unidades de Conservação concentram profissionais capazes de transitar por múltiplas funções facilita o planejamento estratégico de escalas permitindo cobrir ausências ou picos de demanda interna sem a necessidade de novas contratações emergenciais.

```Sql
SELECT F.unidade_conservacao, COUNT(*) AS nro_funcionarios_multicategoricos
FROM funcionario F
JOIN (
    SELECT funcionario
    FROM funcionario_categoria
    GROUP BY funcionario
    HAVING COUNT(*) > 1
) AS funcionarios_validos ON funcionarios_validos.funcionario = F.nro_funcional
GROUP BY F.unidade_conservacao;
```

---

## 2° Consulta:
__Descrição da Consulta:__ Mapeia e lista o identificador funcional e o nome de todos os biólogos do quadro que nunca realizaram um registro de observação faunística utilizando uma câmera durante o período noturno, compreendido entre as 18 horas de um dia e as 5 horas da manhã do dia seguinte.

__Utilidade:__ Atua como ferramenta estratégica e operacional para o controle de lacunas no monitoramento ecológico. Animais de hábitos estritamente noturnos dependem quase inteiramente de capturas por fotos operadas no escuro. Identificar quais profissionais ainda não possuem registros nesse intervalo específico permite à gestão do parque redistribuir as escalas de campo de forma eficiente e planejar treinamentos focados no manuseio e posicionamento de equipamentos de visão noturna.

```Sql
SELECT FC.funcionario, F.nome
FROM funcionario_categoria FC
JOIN funcionario F ON F.nro_funcional = FC.funcionario
WHERE FC.categoria = 'BIOLOGO'
  AND NOT EXISTS (
      SELECT 1
      FROM observacao O
      WHERE 
        O.biologo = FC.funcionario 
        AND O.metodo = 'CAMERA' 
        AND (EXTRACT(HOUR FROM O.data_hora) >= 18 OR EXTRACT(HOUR FROM O.data_hora) <= 5)
    );
```

---

## 3° Consulta:
__Descrição da Consulta:__ Recupera todos os registros de visitas classificadas como educativas (tipo = 'EDUCATIVA') que possuem um guia alocado, impondo a condição de que esse profissional seja um biólogo ou pesquisador.

__Utilidade:__ Atua como um controle de qualidade para as atividades de ecoturismo pedagógico. A consulta permite assegurar que as visitas de instituições escolares ou acadêmicas agendadas nas Unidades de Conservação sejam mediadas exclusivamente por profissionais com sólida bagagem técnica.

```Sql
SELECT *
FROM visita V
WHERE
    V.guia IS NOT NULL 
    AND V.tipo = 'EDUCATIVA'
    AND (
        EXISTS (
          SELECT *
          FROM funcionario_categoria FC
          WHERE FC.funcionario = V.guia 
            AND UPPER(FC.categoria) = 'BIOLOGO'
        )

        OR

        EXISTS (
            SELECT * 
            FROM pesquisa_pesquisador PP
            WHERE PP.pesquisador = V.guia 
        )
    );

```

---

## 4° Consulta:
__Descrição da Consulta:__ Identifica as espécies catalogadas na literatura do sistema que estão "desaparecidas" na prática, ou seja, que nunca tiveram nenhum indivíduo real capturado e identificado com chip no registro de seres vivos. A listagem exibe o nome científico, o status de conservação e o volume de projetos de pesquisa que se pautam em estudar essas espécies.

__Utilidade:__ Funciona como um indicador de eficiência amostral e direcionamento científico. Se uma espécie possui um status de extinção grave e atrai o interesse de diversas pesquisas, mas nenhum espécime real foi chipado pelo parque, há um forte indício de que ou os métodos de busca estão falhando ou que aquela espécie já não é mais presente na Unidade de Conservação. Isso fornece aos gestores uma visão mais ampla quanto a quais segmentos de pesquisas de espécimes podem ser frutíferas no longo prazo.

```Sql
SELECT E.nome_cientifico, E.status_conservacao, COUNT(PE.pesquisa) AS qte_pesquisas
FROM especie E
LEFT JOIN pesquisa_especie PE ON E.nome_cientifico = PE.especie
WHERE NOT EXISTS (
    SELECT *
    FROM ser_vivo S
    WHERE S.especie = E.nome_cientifico
)
GROUP BY E.nome_cientifico, E.status_conservacao;
```

---

## 5° Consulta:
__Descrição da Consulta:__ Identifica e lista o título das pesquisas científicas que alcançaram cobertura total de amostragem para as espécies mais vulneráveis do ecossistema. O filtro seleciona apenas os projetos que estão estudando, simultaneamente, todas as espécies catalogadas sob o status de conservação 'CR' (Criticamente em Perigo).

__Utilidade:__ Funciona como uma ferramenta capaz de identificar e centralizar todos os projetos de pesquisa de uma Unidade que se pautam na proteção de suas espécies sob risco iminente de desaparecimento em sua determinada Unidade de Conservação. Mapear essas iniciativas permite que a administração da Unidade priorize o repasse de verbas de custeio, direcione bolsas científicas e otimize a articulação com fundos de preservação.

```Sql
SELECT P.titulo
FROM pesquisa P
WHERE NOT EXISTS (
    SELECT E.nome_cientifico
    FROM especie E
    WHERE E.status_conservacao = 'CR'

    EXCEPT

    SELECT PE.especie
    FROM pesquisa_especie PE
    WHERE PE.pesquisa = P.titulo
);
```