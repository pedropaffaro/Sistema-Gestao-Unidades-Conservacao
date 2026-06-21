-- ============================================================================
-- Consulta 1
-- Quantidade de funcionários que pertencem a mais de uma categoria,
-- agrupada por unidade de conservação.
-- ============================================================================
SELECT
    F.UNIDADE_CONSERVACAO,                                       -- unidade de conservação do funcionário
    COUNT(*) AS NRO_FUNCIONARIOS_MULTICATEGORICOS                -- nº de funcionários multicategoria na UC
FROM FUNCIONARIO F
    JOIN (
        SELECT FUNCIONARIO                                              -- funcionários com mais de uma categoria
        FROM FUNCIONARIO_CATEGORIA
        GROUP BY FUNCIONARIO
        HAVING COUNT(*) > 1
    ) AS FUNCIONARIOS_VALIDOS
        ON FUNCIONARIOS_VALIDOS.FUNCIONARIO = F.NRO_FUNCIONAL
GROUP BY F.UNIDADE_CONSERVACAO;                                     -- agrega por unidade de conservação

-- ============================================================================
-- Consulta 2
-- Biólogos que nunca realizaram uma observação por câmera no período noturno
-- (das 18h às 5h59).
-- ============================================================================
SELECT
    FC.FUNCIONARIO,                                              -- nº funcional do biólogo
    F.NOME                                                       -- nome do biólogo
FROM FUNCIONARIO_CATEGORIA FC
    JOIN FUNCIONARIO F
        ON F.NRO_FUNCIONAL = FC.FUNCIONARIO              -- traz o nome do funcionário
WHERE
    FC.CATEGORIA = 'BIOLOGO'                                      -- restringe à categoria BIOLOGO
    AND NOT EXISTS (                                                  -- exclui quem tem observação noturna por câmera
        SELECT 1
        FROM OBSERVACAO O
        WHERE
            O.BIOLOGO = FC.FUNCIONARIO                             -- observação do próprio biólogo
            AND O.METODO = 'CAMERA'                                     -- feita por câmera
            AND (
                EXTRACT(HOUR FROM O.DATA_HORA) >= 18                   -- a partir das 18h, ou...
                OR EXTRACT(HOUR FROM O.DATA_HORA) <= 5
            )                -- ...até as 5h (período noturno)
    );

-- ============================================================================
-- Consulta 3
-- Visitas educativas que tiveram um guia, sendo esse guia um biólogo OU um
-- pesquisador vinculado a alguma pesquisa.
-- ============================================================================
SELECT *                                                            -- todos os dados da visita
FROM visita V
WHERE V.guia IS NOT NULL                                            -- a visita teve um guia atribuído
  AND V.tipo = 'EDUCATIVA'                                          -- apenas visitas educativas
  AND (
      EXISTS (                                                      -- o guia é um biólogo...
          SELECT 1
          FROM funcionario_categoria FC
          WHERE FC.funcionario = V.guia
            AND UPPER(FC.categoria) = 'BIOLOGO'
      )
      OR EXISTS (                                                   -- ...ou é pesquisador de alguma pesquisa
          SELECT 1
          FROM pesquisa_pesquisador PP
          WHERE PP.pesquisador = V.guia
      )
  );


-- ============================================================================
-- Consulta 4
-- Espécies que constam no cadastro teórico mas nunca tiveram nenhum ser vivo
-- registrado no sistema (espécies "sumidas" na prática), com a contagem de
-- pesquisas associadas a cada uma.
-- ============================================================================
SELECT E.nome_cientifico,                                           -- identificação da espécie
       E.status_conservacao,                                        -- status de conservação da espécie
       COUNT(PE.pesquisa) AS qte_pesquisas                          -- nº de pesquisas que a estudam
FROM especie E
LEFT JOIN pesquisa_especie PE ON E.nome_cientifico = PE.especie     -- traz as pesquisas (se houver)
WHERE NOT EXISTS (                                                  -- mantém só espécies sem ser vivo registrado
    SELECT 1
    FROM ser_vivo S
    WHERE S.especie = E.nome_cientifico
)
GROUP BY E.nome_cientifico, E.status_conservacao;                   -- agrega por espécie


-- ============================================================================
-- Consulta 5 
-- Títulos das pesquisas que estudam TODAS as espécies com status de
-- conservação 'CR' (divisão relacional).
-- ============================================================================
SELECT P.titulo                                                     -- título da pesquisa
FROM pesquisa P
WHERE NOT EXISTS (                                                  -- não pode sobrar nenhuma espécie CR
    SELECT E.nome_cientifico                                        -- todas as espécies com status CR...
    FROM especie E
    WHERE E.status_conservacao = 'CR'

    EXCEPT

    SELECT PE.especie                                              -- ...menos as estudadas por esta pesquisa
    FROM pesquisa_especie PE
    WHERE PE.pesquisa = P.titulo
);     


--- ============================================================================
-- Consulta 6
-- Por comunidade tradicional: número de ocorrências agrupadas por tipo e nível
-- de gravidade, retornando a quantidade de ocorrências e a média de área
-- afetada. A ligação é feita pela zona em comum (unidade_conservacao, nro_zona)
-- entre a comunidade e as ocorrências.
-- ============================================================================
-- SELECT CT.unidade_conservacao,                                      -- UC da comunidade tradicional
--        CT.nro_zona,                                                 -- zona da comunidade
--        CT.nome           AS comunidade,                             -- nome da comunidade tradicional
--        O.tipo_ocorrencia,                                           -- tipo da ocorrência
--        O.nivel_gravidade,                                           -- nível de gravidade da ocorrência
--        COUNT(*)              AS qte_ocorrencias,                     -- quantidade de ocorrências no grupo
--        AVG(O.area_afetada)   AS media_area_afetada                  -- média de área afetada no grupo
-- FROM comunidade_tradicional CT
-- JOIN ocorrencia O
--   ON O.unidade_conservacao = CT.unidade_conservacao                 -- mesma unidade de conservação...
--  AND O.nro_zona            = CT.nro_zona                            -- ...e mesma zona da comunidade
-- GROUP BY CT.unidade_conservacao, CT.nro_zona, CT.nome,              -- agrupa por comunidade...
--          O.tipo_ocorrencia, O.nivel_gravidade;                      -- ...tipo e nível de gravidade
-- diferença vazia => estuda todas as CR
