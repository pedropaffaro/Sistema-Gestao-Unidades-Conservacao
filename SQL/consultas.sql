-- Selecionar o número de espécies em extinção que foram observadas por um biologo, existem pesquias que pesquisam essa especie e a pesquisa possui no mínimo 2 pesquisadores e foi observada pelo método de 'CAMERA'
SELECT O.biologo, COUNT(DISTINCT E.nome_cientifico) AS nro_especies_observadas
FROM observacao O
JOIN ser_vivo S ON S.chip = O.ser_vivo
JOIN especie E ON E.nome_cientifico = S.especie
JOIN pesquisa_especie PE ON PE.especie = E.nome_cientifico
JOIN (
    SELECT pesquisa
    FROM pesquisa_pesquisador
    GROUP BY pesquisa
    HAVING COUNT(pesquisador) >= 2
) AS pesquisas_validas ON pesquisas_validas.pesquisa = PE.pesquisa
WHERE O.metodo = 'CAMERA' AND E.status_conservacao IN ('CR', 'EN', 'VU')
GROUP BY O.biologo;

-- Selecionar a quantidade de funcionários que possuem mais de uma categoria agrupados por unidade de conservação.
SELECT F.unidade_conservacao, COUNT(*) AS nro_funcionarios_multicategoricos
FROM funcionario F
JOIN (
    SELECT funcionario
    FROM funcionario_categoria
    GROUP BY funcionario
    HAVING COUNT(*) > 1
) AS funcionarios_validos ON funcionarios_validos.funcionario = F.nro_funcional
GROUP BY F.unidade_conservacao;

-- Selecionar todos os biólogos que nunca fizeram uma observação por câmera a noite.
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

-- Consultar por comunidade tradicional, o numero de ocorrências agrupadas por tipo e nível de gravidade e retornar quantidade de ocorrências e a média de área afetada.


-- Selecionar todas as visitas que tiveram um guia monitorando ela, com o guia sendo biólogo ou um pesquisador que faz uma pesquisa (visitas educacionais)
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


-- Identificar espécies que constam na literatura/cadastros teóricos, mas que estão "sumidas" na prática.
-- Liste apenas as espécies que nunca tiveram nenhum ser vivo registrado no sistema.
SELECT E.nome_cientifico, E.status_conservacao, COUNT(PE.pesquisa) AS qte_pesquisas
FROM especie E
LEFT JOIN ser_vivo S ON E.nome_cientifico = S.especie
LEFT JOIN pesquisa_especie PE ON E.nome_cientifico = PE.especie
WHERE S.chip IS NULL 
GROUP BY E.nome_cientifico, E.status_conservacao;


-- Essa é a mais otimizada
SELECT E.nome_cientifico, E.status_conservacao, COUNT(PE.pesquisa) AS qte_pesquisas
FROM especie E
LEFT JOIN pesquisa_especie PE ON E.nome_cientifico = PE.especie
WHERE NOT EXISTS (
    SELECT *
    FROM ser_vivo S
    WHERE S.especie = E.nome_cientifico
)
GROUP BY E.nome_cientifico, E.status_conservacao;

-- Selecione o título das pesquisas que estão estudando todas as espécies que possuem o status de conservação 'CR'
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
