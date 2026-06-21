-- ============================================================================
-- Consulta 1
-- Número de espécies ameaçadas de extinção observadas por cada biólogo via
-- método 'CAMERA', contando apenas espécies estudadas por ao menos uma
-- pesquisa que possua 2 ou mais pesquisadores.
-- ============================================================================
SELECT O.biologo,                                                   -- biólogo que registrou a observação
       COUNT(DISTINCT E.nome_cientifico) AS nro_especies_observadas -- espécies distintas observadas por ele
FROM observacao O
JOIN ser_vivo S          ON S.chip = O.ser_vivo                     -- liga a observação ao indivíduo observado
JOIN especie E           ON E.nome_cientifico = S.especie           -- liga o indivíduo à sua espécie
JOIN pesquisa_especie PE ON PE.especie = E.nome_cientifico          -- espécie deve ser alvo de alguma pesquisa
JOIN (
    SELECT pesquisa                                                 -- pesquisas com 2+ pesquisadores
    FROM pesquisa_pesquisador
    GROUP BY pesquisa
    HAVING COUNT(pesquisador) >= 2
) AS pesquisas_validas ON pesquisas_validas.pesquisa = PE.pesquisa  -- mantém só espécies de pesquisas válidas
WHERE O.metodo = 'CAMERA'                                           -- observação feita por câmera
  AND E.status_conservacao IN ('CR', 'EN', 'VU')                    -- status ameaçado: CR / EN / VU
GROUP BY O.biologo;                                                 -- agrega o resultado por biólogo


-- ============================================================================
-- Consulta 2
-- Quantidade de funcionários que pertencem a mais de uma categoria,
-- agrupada por unidade de conservação.
-- ============================================================================
SELECT F.unidade_conservacao,                                       -- unidade de conservação do funcionário
       COUNT(*) AS nro_funcionarios_multicategoricos                -- nº de funcionários multicategoria na UC
FROM funcionario F
JOIN (
    SELECT funcionario                                              -- funcionários com mais de uma categoria
    FROM funcionario_categoria
    GROUP BY funcionario
    HAVING COUNT(*) > 1
) AS funcionarios_validos ON funcionarios_validos.funcionario = F.nro_funcional
GROUP BY F.unidade_conservacao;                                     -- agrega por unidade de conservação


-- ============================================================================
-- Consulta 3
-- Biólogos que nunca realizaram uma observação por câmera no período noturno
-- (das 18h às 5h59).
-- ============================================================================
SELECT FC.funcionario,                                              -- nº funcional do biólogo
       F.nome                                                       -- nome do biólogo
FROM funcionario_categoria FC
JOIN funcionario F ON F.nro_funcional = FC.funcionario              -- traz o nome do funcionário
WHERE FC.categoria = 'BIOLOGO'                                      -- restringe à categoria BIOLOGO
  AND NOT EXISTS (                                                  -- exclui quem tem observação noturna por câmera
      SELECT 1
      FROM observacao O
      WHERE O.biologo = FC.funcionario                             -- observação do próprio biólogo
        AND O.metodo = 'CAMERA'                                     -- feita por câmera
        AND (EXTRACT(HOUR FROM O.data_hora) >= 18                   -- a partir das 18h, ou...
             OR EXTRACT(HOUR FROM O.data_hora) <= 5)                -- ...até as 5h (período noturno)
  );


-- ============================================================================
-- Consulta 4
-- Por comunidade tradicional: número de ocorrências agrupadas por tipo e nível
-- de gravidade, retornando a quantidade de ocorrências e a média de área
-- afetada. A ligação é feita pela zona em comum (unidade_conservacao, nro_zona)
-- entre a comunidade e as ocorrências.
-- ============================================================================
SELECT CT.unidade_conservacao,                                      -- UC da comunidade tradicional
       CT.nro_zona,                                                 -- zona da comunidade
       CT.nome           AS comunidade,                             -- nome da comunidade tradicional
       O.tipo_ocorrencia,                                           -- tipo da ocorrência
       O.nivel_gravidade,                                           -- nível de gravidade da ocorrência
       COUNT(*)              AS qte_ocorrencias,                     -- quantidade de ocorrências no grupo
       AVG(O.area_afetada)   AS media_area_afetada                  -- média de área afetada no grupo
FROM comunidade_tradicional CT
JOIN ocorrencia O
  ON O.unidade_conservacao = CT.unidade_conservacao                 -- mesma unidade de conservação...
 AND O.nro_zona            = CT.nro_zona                            -- ...e mesma zona da comunidade
GROUP BY CT.unidade_conservacao, CT.nro_zona, CT.nome,              -- agrupa por comunidade...
         O.tipo_ocorrencia, O.nivel_gravidade;                      -- ...tipo e nível de gravidade


-- ============================================================================
-- Consulta 5
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
-- Consulta 6
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
-- Consulta 7
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
);                                                                  -- diferença vazia => estuda todas as CR
