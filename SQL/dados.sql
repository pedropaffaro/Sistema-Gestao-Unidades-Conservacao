-- ==========================
-- Unidades de Conservação
-- ==========================
INSERT INTO unidade_conservacao ( cnuc, nome, data_criacao, bioma, rodovia, km, cidade, uf, descricao_acesso, orgao_gestor, area_total) VALUES
(
  '000000000001', 'Parque Nacional do Iguaçu', '1939-01-10', 'Mata Atlântica', 'BR 469', 18, 'Foz do Iguaçu', 'PR', 'BR 469, Km 18, Foz do Iguaçu - PR', 'ICMBio', 185262.50
),
(
  '000000000002', 'Parque Nacional da Chapada dos Veadeiros', '1961-01-11', 'Cerrado', 'GO 239', 36, 'Alto Paraíso de Goiás', 'GO', 'Rodovia GO 239, Km 36, Alto Paraíso de Goiás - GO', 'ICMBio', 240611.00
),
(
  '000000000003', 'Parque Nacional da Serra da Capivara', '1979-06-05', 'Caatinga', NULL, 0, 'São Raimundo Nonato', 'PI', 'São Raimundo Nonato - PI', 'ICMBio', 135000.00
),
(
  '000000000004', 'Reserva Extrativista Chico Mendes', '1990-03-12', 'Amazônia', NULL, 0, 'Xapuri', 'AC', 'Xapuri - AC', 'ICMBio', 970000.00
),
(
  '000000000005', 'Parque Nacional do Pantanal Matogrossense', '1981-11-24', 'Pantanal', NULL, 0, 'Corumbá', 'MS', 'Corumbá - MS', 'ICMBio', 1350000.00
),
(
  '000000000006', 'Parque Nacional do Caparaó', '1961-09-24', 'Mata Atlântica', NULL, 0, 'Dores do Rio Preto', 'ES', 'Dores do Rio Preto - ES', 'ICMBio', 310000.00
),
(
  '000000000007', 'Parque Nacional da Serra dos Órgãos', '1939-11-30', 'Mata Atlântica', NULL, 0, 'Teresópolis', 'RJ', 'Teresópolis - RJ', 'ICMBio', 200000.00
),
(
  '000000000008', 'Parque Nacional de Jericoacoara', '1984-06-02', 'Caatinga', NULL, 0, 'Jericoacoara', 'CE', 'Jericoacoara - CE', 'ICMBio', 90000.00
),
(
  '000000000009', 'Parque Nacional do Itatiaia', '1937-06-14', 'Mata Atlântica', NULL, 0, 'Itatiaia', 'RJ', 'Itatiaia - RJ', 'ICMBio', 300000.00
),
(
  '000000000010', 'Parque Nacional da Serra da Bocaina', '1971-04-13', 'Mata Atlântica', NULL, 0, 'Cunha', 'SP', 'Cunha - SP', 'ICMBio', 150000.00
),
(
  '000000000011', 'Parque Nacional do Pampa', '2020-04-02', 'Pampa', NULL, 0, 'Alegrete', 'RS', 'Alegrete - RS', 'ICMBio', 84000.00
),
(
  '000000000012', 'Parque Nacional Marinho de Fernando de Noronha', '1988-09-14', 'Marinho-Costeiro', NULL, 0, 'Fernando de Noronha', 'PE', 'Fernando de Noronha - PE', 'ICMBio', 11270.00
);

INSERT INTO unidade_conservacao ( cnuc, nome, bioma, rodovia, km, cidade, uf, descricao_acesso, orgao_gestor) VALUES (
  '000000000013', 'Floresta Nacional de Brasília', 'Cerrado', NULL, 0, 'Brasília', 'DF', 'Brasília - DF', 'ICMBio'
);

-- ==========================
-- Zonas
-- ==========================
INSERT INTO zona (unidade_conservacao, nro_zona, nome, tipo, area) VALUES
('000000000001', 1, 'Zona Intangível (Proteção Estrita)', 'PRESERVACAO', 150000.00),
('000000000001', 2, 'Zona de Uso Público (Turismo)', 'USO SUSTENTAVEL', 35262.50),
('000000000002', 1, 'Zona de Conservação Extrema', 'PRESERVACAO', 200000.00),
('000000000002', 2, 'Zona de Recuperação e Visitação', 'USO SUSTENTAVEL', 40611.00),
('000000000003', 1, 'Zona de Preservação Integral', 'PRESERVACAO', 120000.00),
('000000000003', 2, 'Zona de Uso Controlado', 'USO SUSTENTAVEL', 15000.00),
('000000000004', 1, 'Zona de Floresta Primária', 'PRESERVACAO', 750000.00),
('000000000004', 2, 'Zona Extrativista', 'USO SUSTENTAVEL', 220000.00),
('000000000005', 1, 'Zona de Preservação Integral', 'PRESERVACAO', 1000000.00),
('000000000005', 2, 'Zona de Uso Público', 'USO SUSTENTAVEL', 350000.00),
('000000000006', 1, 'Zona de Preservação Integral', 'PRESERVACAO', 250000.00),
('000000000006', 2, 'Zona de Uso Público', 'USO SUSTENTAVEL', 60000.00),
('000000000007', 1, 'Zona de Preservação Integral', 'PRESERVACAO', 150000.00),
('000000000007', 2, 'Zona de Uso Público', 'USO SUSTENTAVEL', 50000.00),
('000000000008', 1, 'Zona de Preservação Integral', 'PRESERVACAO', 70000.00),
('000000000008', 2, 'Zona de Uso Público', 'USO SUSTENTAVEL', 20000.00),
('000000000009', 1, 'Zona de Preservação Integral', 'PRESERVACAO', 250000.00),
('000000000009', 2, 'Zona de Uso Público', 'USO SUSTENTAVEL', 50000.00),
('000000000010', 1, 'Zona de Preservação Integral', 'PRESERVACAO', 120000.00),
('000000000010', 2, 'Zona de Uso Público (Trilhas)', 'USO SUSTENTAVEL', 30000.00),
('000000000011', 1, 'Zona de Proteção do Campo Nativo', 'PRESERVACAO', 64000.00),
('000000000011', 2, 'Zona de Manejo Agropastoril Tradicional', 'USO SUSTENTAVEL', 20000.00),
('000000000012', 1, 'Zona de Reserva Marinha Estrita', 'PRESERVACAO', 8000.00),
('000000000012', 2, 'Zona de Turismo Náutico e Mergulho', 'USO SUSTENTAVEL', 3270.00);

-- Zona com todos os campos opcionais NULL (perímetro ainda não delimitado)
INSERT INTO zona (unidade_conservacao, nro_zona) VALUES ('000000000013', 1);

-- Zona com area NULL (levantamento pendente)
INSERT INTO zona (unidade_conservacao, nro_zona, nome, tipo, area)
VALUES ('000000000001', 3, 'Zona de Amortecimento Externo', 'USO SUSTENTAVEL', NULL);


-- ==========================
-- Comunidade Tradicional
-- ==========================
INSERT INTO comunidade_tradicional (unidade_conservacao, nro_zona, nome, tamanho, tipo_comunidade) VALUES
('000000000001', 2, 'Aldeia Guarani Tekoha', 120, 'POVOS INDÍGENAS'),
('000000000002', 2, 'Comunidade Quilombola Kalunga', 350, 'QUILOMBOLAS'),
('000000000003', 2, 'Comunidade Sítio do Mocó', 180, 'CABOCLOS'),
('000000000004', 2, 'Comunidade Chico Mendes', 500, 'EXTRATIVISTAS'),
('000000000004', 2, 'Comunidade Rio Branco', 320, 'RIBEIRINHOS'),
('000000000005', 2, 'Comunidade Pantaneira', 400, 'PANTANEIROS'),
('000000000006', 2, 'Comunidade do Caparaó', 150, 'CABOCLOS'),
('000000000007', 2, 'Comunidade da Serra dos Órgãos', 200, 'CABOCLOS'),
('000000000008', 2, 'Comunidade de Jericoacoara', 250, 'PESCADORES ARTESANAIS'),
('000000000009', 2, 'Comunidade de Itatiaia', 300, 'CABOCLOS'),
('000000000010', 2, 'Comunidade da Serra da Bocaina', 180, 'CABOCLOS'),
('000000000011', 2, 'Povoadores do Campo Seco', NULL, 'PANTANEIROS'),
('000000000012', 2, 'Pescadores de Baía Sueste', 85, 'PESCADORES ARTESANAIS');

-- ==========================
-- Costumes das Comunidades Tradicionais
-- ==========================
INSERT INTO comunidade_costume (unidade_conservacao, nro_zona, nome_comunidade, costume) VALUES
('000000000001', 2, 'Aldeia Guarani Tekoha', 'Produção de artesanato tradicional com fibras naturais e sementes'),
('000000000002', 2, 'Comunidade Quilombola Kalunga', 'Cultivo agrícola baseado no sistema tradicional de roça de toco'),
('000000000003', 2, 'Comunidade Sítio do Mocó', 'Produção artesanal de cerâmica'),
('000000000004', 2, 'Comunidade Chico Mendes', 'Extração sustentável de látex'),
('000000000004', 2, 'Comunidade Rio Branco', 'Pesca artesanal sazonal'),
('000000000005', 2, 'Comunidade Pantaneira', 'Criação de gado de corte em sistema de pastoreio tradicional'),
('000000000006', 2, 'Comunidade do Caparaó', 'Produção de mel artesanal a partir de colmeias naturais'),
('000000000007', 2, 'Comunidade da Serra dos Órgãos', 'Cultivo de hortaliças em pequenos lotes utilizando técnicas tradicionais de permacultura'),
('000000000008', 2, 'Comunidade de Jericoacoara', 'Pesca artesanal com uso de redes e canoas tradicionais'),
('000000000009', 2, 'Comunidade de Itatiaia', 'Produção de artesanato em madeira utilizando técnicas tradicionais de entalhe'),
('000000000010', 2, 'Comunidade da Serra da Bocaina', 'Cultivo de café orgânico em sistema agroflorestal'),
('000000000011', 2, 'Povoadores do Campo Seco', 'Pastoreio rotativo de inverno nos campos nativos'),
('000000000012', 2, 'Pescadores de Baía Sueste', 'Captura de peixes pelágicos com linha de mão e restrição à época de desova');

-- ==========================
-- Funcionários
-- ==========================
INSERT INTO funcionario (nro_funcional, cpf, nome, data_contratacao, telefone, email, salario, unidade_conservacao) VALUES
(1001, '12345678901', 'Carlos da Silva', '2020-05-15', '45987654321', 'carlos.silva@icmbio.gov.br', 4500.00, '000000000001'),
(1002, '45612378900', 'João Mendes', '2021-11-20', '45912345678', 'joao.mendes@icmbio.gov.br', 3800.00, '000000000001'),
(1003, '11122233344', 'Mariana Costa', '2022-03-01', '45988887777', 'mariana.costa@icmbio.gov.br', 4100.00, '000000000001'),
(2001, '98765432109', 'Ana Batista', '2019-02-10', '61999887766', 'ana.batista@icmbio.gov.br', 5200.50, '000000000002'),
(2002, '55566677788', 'Roberto Almeida', '2018-08-12', '61977776666', 'roberto.almeida@icmbio.gov.br', 6300.00, '000000000002'),
(3001, '33344455566', 'Paulo Nascimento', '2017-04-11', '86999990001', 'paulo@icmbio.gov.br', 5600.00, '000000000003'),
(3002, '33344455567', 'Luciana Alves', '2021-07-20', '86999990002', 'luciana@icmbio.gov.br', 4700.00, '000000000003'),
(4001, '33344455568', 'José Ribeiro', '2015-02-10', '68999990001', 'jose@icmbio.gov.br', 6800.00, '000000000004'),
(4002, '33344455569', 'Patricia Lima', '2020-08-01', '68999990002', 'patricia@icmbio.gov.br', 5300.00, '000000000004'),
(5001, '33344455570', 'Ricardo Santos', '2016-11-15', '78999990001', 'ricardo@icmbio.gov.br', 5800.00, '000000000005'),
(5002, '33344455571', 'Fernanda Oliveira', '2019-03-20', '78999990002', 'fernanda@icmbio.gov.br', 4900.00, '000000000005'),
(6001, '33344455572', 'Marcos Pereira', '2018-05-10', '58999990001', 'marcos@icmbio.gov.br', 5100.00, '000000000006'),
(6002, '33344455573', 'Aline Costa', '2021-09-01', '58999990002', 'aline@icmbio.gov.br', 4600.00, '000000000007'),
(7001, '33344455574', 'Sérgio Fernandes', '2017-12-01', '48999990001', 'sergio@icmbio.gov.br', 5400.00, '000000000008'),
(7002, '33344455575', 'Vanessa Rodrigues', '2020-06-15', '48999990002', 'vanessa@icmbio.gov.br', 4800.00, '000000000008'),
(8001, '33344455576', 'Eduardo Lima', '2019-01-10', '38999990001', 'eduardo@icmbio.gov.br', 5200.00, '000000000009'),
(8002, '33344455577', 'Carla Mendes', '2021-04-20', '38999990002', 'carla@icmbio.gov.br', 4500.00, '000000000009'),
(9001, '33344455578', 'Bruno Souza', '2018-07-01', '28999990001', 'bruno@icmbio.gov.br', 4800.00, '000000000010'),
(9002, '22211133399', 'Alice Winter', '2025-01-10', NULL, 'alice.winter@icmbio.gov.br', 0.00, '000000000011'),
(9003, '55544466611', 'Douglas Silva', '2023-05-12', '81988112233', 'douglas@icmbio.gov.br', 6200.00, '000000000012');

-- Funcionário com nome, data_contratacao, telefone, email e salario todos NULL (voluntário ainda não cadastrado completamente)
INSERT INTO funcionario (nro_funcional, cpf, unidade_conservacao)
VALUES (10001, '00011122233', '000000000013');

-- ==========================
-- Categorias de Funcionário
-- ==========================
INSERT INTO funcionario_categoria (funcionario, categoria) VALUES
(1001, 'FISCAL'), (1001, 'GESTOR'),
(1002, 'GUIA'),
(1003, 'BIOLOGO'), (1003, 'FISCAL'), (1003, 'BRIGADISTA'),
(2001, 'BIOLOGO'), (2001, 'PESQUISADOR'), (2001, 'FISCAL'),
(2002, 'GUIA'), (2002, 'PESQUISADOR'), (2002, 'FISCAL'),
(3001, 'FISCAL'), (3001, 'GESTOR'),
(3002, 'BIOLOGO'), (3002, 'PESQUISADOR'),
(4001, 'FISCAL'), (4001, 'BRIGADISTA'),
(4002, 'BIOLOGO'), (4002, 'PESQUISADOR'), (4002, 'GUIA'),
(5001, 'FISCAL'), 
(5002, 'BIOLOGO'),
(6001, 'GESTOR'), 
(6002, 'GUIA'),
(7001, 'FISCAL'), 
(7002, 'BIOLOGO'),
(8001, 'BRIGADISTA'), 
(8002, 'GESTOR'),
(9001, 'FISCAL'),
(9002, 'PESQUISADOR'),
(9003, 'BIOLOGO'), (9003, 'GUIA');

-- ==========================
-- Visitantes
-- ==========================
INSERT INTO visitante (cpf, nome, telefone, email) VALUES
('22233344455', 'Fernanda Lima', '11988887777', 'fernanda.lima@email.com'),
('66677788899', 'Rafael Souza', '21977776666', 'rafael.souza@email.com'),
('10120230344', 'Camila Barros', '31955554444', 'camila.barros@email.com'),
('90980870766', 'Diego Martins', '41944443333', 'diego.martins@email.com'),
('50540430322', 'Juliana Peixoto', '81933332222', 'juliana.peixoto@email.com'),
('11144477788', 'Arthur Dent', NULL, 'arthur.dent@galaxy.com'),
-- Visitante sem nome e sem email (apenas CPF e telefone fornecidos no balcão)
('33344499900', NULL, '11955550001', NULL),
-- Visitante sem telefone e sem email (cadastro mínimo)
('99988877766', 'Marcelo Fagundes', NULL, NULL);

-- ==========================
-- Visitas
-- ==========================
INSERT INTO visita (unidade_conservacao, nro_zona, nro_visita, data_hora, tipo, nro_visitantes, guia) VALUES
('000000000001', 2, 101, '2026-06-15 09:00:00', 'TURISTICA', 3, 1002),
('000000000001', 2, 102, '2026-06-15 14:00:00', 'EDUCATIVA', 1, 1002),
('000000000001', 2, 103, '2026-06-16 08:30:00', 'CIENTIFICA', 0, NULL),
('000000000002', 2, 201, '2026-06-20 10:00:00', 'TURISTICA', 1, 2002),
('000000000002', 2, 202, '2026-06-21 09:00:00', 'EDUCATIVA', 1, NULL),
('000000000002', 2, 203, '2026-06-22 13:00:00', 'CIENTIFICA', 0, 2002),
('000000000012', 2, 901, '2026-06-17 10:00:00', 'TURISTICA', 1, 9003);

-- Visita científica sem data_hora (DEFAULT CURRENT_TIMESTAMP) e sem guia (NULL)
INSERT INTO visita (unidade_conservacao, nro_zona, nro_visita, tipo, nro_visitantes)
VALUES ('000000000003', 2, 301, 'CIENTIFICA', 2);

-- Visita com tipo (DEFAULT 'TURISTICA') e nro_visitantes (DEFAULT 0) omitidos
INSERT INTO visita (unidade_conservacao, nro_zona, nro_visita, data_hora, guia)
VALUES ('000000000004', 2, 401, '2026-06-18 09:30:00', 4002);

-- Visita com tipo, nro_visitantes e data_hora todos omitidos (todos usam DEFAULT)
INSERT INTO visita (unidade_conservacao, nro_zona, nro_visita, guia)
VALUES ('000000000006', 2, 601, 6001);

-- ==========================
-- Vínculo de Visitantes em Visitas
-- ==========================
INSERT INTO visita_visitante (visita, visitante) VALUES
(1, '22233344455'),
(1, '66677788899'),
(1, '10120230344'),
(2, '90980870766'),
(4, '50540430322'),
(5, '22233344455'),
(7, '11144477788'),
(8, '33344499900'),
(8, '99988877766');

-- ==========================
-- Espécies
-- ==========================
INSERT INTO especie (nome_cientifico, nome_popular, familia, reino, ordem, classe, filo, status_conservacao, descricao) VALUES
('Panthera onca', 'Onça-pintada', 'Felidae', 'ANIMALIA', 'Carnivora', 'Mammalia', 'Chordata', 'NT', NULL),
('Tapirus terrestris', 'Anta', 'Tapiridae', 'ANIMALIA', 'Perissodactyla', 'Mammalia', 'Chordata', 'VU', NULL),
('Myrmecophaga tridactyla', 'Tamanduá-bandeira', 'Myrmecophagidae', 'ANIMALIA', 'Pilosa', 'Mammalia', 'Chordata', 'VU', NULL),
('Ara chloropterus', 'Arara-vermelha', 'Psittacidae', 'ANIMALIA', 'Psittaciformes', 'Aves', 'Chordata', 'LC', NULL),
('Caryocar brasiliense', 'Pequi', 'Caryocaraceae', 'PLANTAE', 'Malpighiales', 'Magnoliopsida', 'Tracheophyta', 'LC', NULL),
('Hevea brasiliensis', 'Seringueira', 'Euphorbiaceae', 'PLANTAE', 'Malpighiales', 'Magnoliopsida', 'Tracheophyta', 'LC', NULL),
('Anodorhynchus hyacinthinus', 'Arara-azul', 'Psittacidae', 'ANIMALIA', 'Psittaciformes', 'Aves', 'Chordata', 'NT', 'Grande ave de plumagem azul-cobalto com detalhes amarelos ao redor dos olhos e mandíbula.'),
('Handroanthus albus', 'Ipê-amarelo', 'Bignoniaceae', 'PLANTAE', 'Lamiales', 'Magnoliopsida', 'Tracheophyta', 'LC', 'Árvore nativa do Brasil conhecida por sua florada amarela espetacular durante o inverno e primavera.'),
('Agaricus blazei', 'Cogumelo-do-sol', 'Agaricaceae', 'FUNGI', 'Agaricales', 'Agaricomycetes', 'Basidiomycota', 'DD', 'Cogumelo nativo do Brasil, amplamente estudado por suas propriedades medicinais e imunoestimulantes.'),
('Stenocraniops pampa', 'Gafanhoto-do-pampa', 'Acrididae', 'ANIMALIA', 'Orthoptera', 'Insecta', 'Arthropoda', 'EN', 'Inseto bioindicador endêmico do bioma Pampa.'),
('Trichechus manatus', 'Peixe-boi-marinho', 'Trichechidae', 'ANIMALIA', 'Sirenia', 'Mammalia', 'Chordata', 'CR', 'Mamífero aquático criticamente ameaçado no litoral brasileiro.'),
('Araucaria angustifolia', 'Pinheiro-do-paraná', 'Araucariaceae', 'PLANTAE', 'Pinales', 'Pinopsida', 'Tracheophyta', 'CR', 'Árvore símbolo da floresta ombrófila mista.');

-- ==========================
-- Espécies por Unidade de Conservação
-- ==========================
INSERT INTO unidade_conservacao_especie (unidade_conservacao, especie) VALUES
('000000000001', 'Panthera onca'),
('000000000001', 'Ara chloropterus'),
('000000000001', 'Tapirus terrestris'),
('000000000001', 'Handroanthus albus'),
('000000000001', 'Araucaria angustifolia'),
('000000000002', 'Caryocar brasiliense'),
('000000000002', 'Panthera onca'),
('000000000002', 'Anodorhynchus hyacinthinus'),
('000000000002', 'Tapirus terrestris'),
('000000000002', 'Agaricus blazei'),
('000000000002', 'Myrmecophaga tridactyla'),
('000000000004', 'Hevea brasiliensis'),
('000000000011', 'Stenocraniops pampa'),
('000000000012', 'Trichechus manatus');

-- ==========================
-- Pesquisas
-- ==========================
INSERT INTO pesquisa (titulo, data_inicio, data_termino, objetivo, inst_responsavel) VALUES
('Monitoramento da Onça-Pintada', '2024-01-10', NULL, 'Estudo populacional da espécie', 'UFPR'),
('Conservação do Cerrado', '2023-08-01', NULL, 'Mapeamento da biodiversidade', 'UFG'),
('Uso Sustentável do Látex', '2025-02-15', NULL, 'Avaliar impacto do extrativismo', 'UFAC'),
('Monitoramento Populacional de Grandes Felinos', '2021-01-10', '2025-12-20', 'Avaliar a densidade populacional e a saúde genética das onças-pintadas na Mata Atlântica.', 'Instituto Chico Mendes de Conservação da Biodiversidade (ICMBio)'),
('Impacto do Turismo na Avifauna Local', '2024-03-15', NULL, 'Analisar se o fluxo de visitantes nas trilhas altera o comportamento de nidificação de aves nativas.', 'UFPR'),
('Mapeamento de Fungos Medicinais do Cerrado', '2028-06-01', NULL, 'Identificar novas propriedades bioativas no Agaricus blazei e outros fungos locais.', 'Universidade de São Paulo (USP)'),
('Inventário Rápido da Flora Arbórea - Primavera 2025', '2025-10-10', '2025-10-10', 'Catalogar a floração simultânea de ipês-amarelos durante um evento específico.', 'Instituto Botânico de São Paulo'),
('Ecofisiologia do Campo Sulino', '2026-01-05', NULL, 'Avaliar adaptação do Gafanhoto-do-pampa à queima controlada.', 'UFRGS');

-- Pesquisa com data_inicio omitida (DEFAULT CURRENT_DATE), objetivo e inst_responsavel NULL (levantamento preliminar sem equipe definida)
INSERT INTO pesquisa (titulo) VALUES ('Levantamento Preliminar da Ictiofauna do Pantanal');

-- ==========================
-- Áreas Temáticas de Pesquisa
-- ==========================
INSERT INTO pesquisa_area_tematica (pesquisa, area_tematica) VALUES
('Monitoramento da Onça-Pintada', 'Mamíferos'),
('Monitoramento da Onça-Pintada', 'Conservação'),
('Conservação do Cerrado', 'Botânica'),
('Conservação do Cerrado', 'Ecologia'),
('Uso Sustentável do Látex', 'Extrativismo'),
('Monitoramento Populacional de Grandes Felinos', 'Zoologia'),
('Monitoramento Populacional de Grandes Felinos', 'Genética de Populações'),
('Impacto do Turismo na Avifauna Local', 'Ecologia'),
('Impacto do Turismo na Avifauna Local', 'Uso Público'),
('Mapeamento de Fungos Medicinais do Cerrado', 'Micologia'),
('Inventário Rápido da Flora Arbórea - Primavera 2025', 'Botânica'),
('Ecofisiologia do Campo Sulino', 'Entomologia');

-- ==========================
-- Pesquisadores por Pesquisa
-- ==========================
INSERT INTO pesquisa_pesquisador (pesquisa, pesquisador) VALUES
('Monitoramento da Onça-Pintada', 2001),
('Monitoramento da Onça-Pintada', 4002),
('Conservação do Cerrado', 3002),
('Uso Sustentável do Látex', 4002),
('Monitoramento Populacional de Grandes Felinos', 2001),
('Monitoramento Populacional de Grandes Felinos', 2002),
('Impacto do Turismo na Avifauna Local', 2001),
('Mapeamento de Fungos Medicinais do Cerrado', 2002),
('Ecofisiologia do Campo Sulino', 9002);

-- ==========================
-- Espécies por Pesquisa
-- ==========================
INSERT INTO pesquisa_especie (pesquisa, especie) VALUES
('Monitoramento da Onça-Pintada', 'Panthera onca'),
('Conservação do Cerrado', 'Caryocar brasiliense'),
('Uso Sustentável do Látex', 'Hevea brasiliensis'),
('Ecofisiologia do Campo Sulino', 'Stenocraniops pampa');

-- ==========================
-- Comunidades Tradicionais por Pesquisa
-- ==========================
INSERT INTO pesquisa_comunidade_tradicional (unidade_conservacao, nro_zona, nome_comunidade, pesquisa) VALUES
('000000000004', 2, 'Comunidade Chico Mendes', 'Uso Sustentável do Látex'),
('000000000002', 2, 'Comunidade Quilombola Kalunga', 'Conservação do Cerrado');

-- ==========================
-- Seres Vivos
-- ==========================
INSERT INTO ser_vivo (chip, apelido, situacao, especie) VALUES
(20003, 'Tainá', 'VIVO', 'Panthera onca'),
(40021, 'Bidu', 'VIVO', 'Tapirus terrestris'),
(40022, 'Vermelha', 'VIVO', 'Ara chloropterus'),
(50007, 'Tamy', 'EM REABILITACAO', 'Myrmecophaga tridactyla'),
(10001, 'Trovão', 'VIVO', 'Panthera onca'),
(10002, 'Juma', 'VIVO', 'Panthera onca'),
(20001, 'Amiga', 'EM REABILITACAO', 'Tapirus terrestris'),
(30001, 'Blue', 'DESAPARECIDO', 'Anodorhynchus hyacinthinus'),
(10003, 'Gatão', 'VIVO', 'Panthera onca'),
(30002, 'Rachel', 'VIVO', 'Anodorhynchus hyacinthinus'),
(20002, 'Valente', 'LIBERADO', 'Tapirus terrestris'),
(10004, 'Sombra', 'CAPTURADO', 'Panthera onca'),
(10005, 'Velho', 'MORTO', 'Panthera onca'),
(30003, 'Sky', 'VIVO', 'Anodorhynchus hyacinthinus'),
(90001, 'Saltador', 'VIVO', 'Stenocraniops pampa'),
(90002, 'Netuno', 'VIVO', 'Trichechus manatus');

-- Ser vivo com situacao omitida (DEFAULT 'VIVO') — apelido será NULL implicitamente
INSERT INTO ser_vivo (chip, especie) VALUES (11001, 'Anodorhynchus hyacinthinus');

-- Ser vivo com apelido explicitamente NULL
INSERT INTO ser_vivo (chip, apelido, situacao, especie) VALUES (11002, NULL, 'CAPTURADO', 'Tapirus terrestris');

-- ==========================
-- Observações de Seres Vivos
-- ==========================
INSERT INTO observacao (biologo, ser_vivo, data_hora, metodo, descricao, unidade_conservacao, nro_zona) VALUES
(2001, 40021, '2026-05-01 08:30:00', 'CAMERA', 'Animal registrado próximo ao rio', '000000000002', 1),
(3002, 40022, '2026-05-04 17:00:00', 'VISUAL', 'Animal alimentando-se', '000000000003', 1),
(4002, 20003, '2026-05-09 11:15:00', 'BINOCULO', 'Deslocamento em área preservada', '000000000004', 1),
(1003, 10001, '2026-06-10 23:15:00', 'CAMERA', 'Registro noturno através de armadilha fotográfica.', '000000000001', 2),
(1003, 10001, '2026-06-12 08:30:00', 'SINAIS BIOLOGICOS', 'Identificadas pegadas frescas do espécime.', '000000000001', 2),
(2001, 30002, '2026-06-15 07:45:00', 'BINOCULO', 'Avistamento do indivíduo em atividade de forrageamento.', '000000000002', 2),
(2001, 10002, '2026-06-16 16:20:00', 'VISUAL', 'Avistamento direto durante patrulha preventiva.', '000000000002', 2),
(2001, 50007, '2026-06-17 09:00:00', 'CAMERA', 'Registro de um tamanduá-bandeira em processo de reabilitação.', '000000000002', 2),
(9003, 90002, '2026-06-17 11:30:00', 'VISUAL', 'Peixe-boi avistado na Baía Sueste respirando calmamente.', '000000000012', 2);

-- Observação com metodo e descricao NULL (pesquisadora em campo sem equipamento disponível no momento)
INSERT INTO observacao (biologo, ser_vivo, data_hora, unidade_conservacao, nro_zona)
VALUES (5002, 90001, '2026-06-16 07:00:00', '000000000011', 2);

-- ==========================
-- Ocorrências
-- ==========================
INSERT INTO ocorrencia (unidade_conservacao, nro_zona, data_horario, fiscal, tipo_ocorrencia, nivel_gravidade, area_afetada, descricao) VALUES
('000000000001', 1, '2026-04-10 14:00:00', 1001, 'CACA', 'MEDIO', 12.50, 'Vestígios de caça ilegal'),
('000000000004', 2, '2026-05-22 09:30:00', 4001, 'INVASAO DE ZONA', 'ALTO', 25.00, 'Entrada irregular de veículos'),
('000000000003', 1, '2026-05-30 15:45:00', 3001, 'INCENDIO NATURAL', 'BAIXO', 5.00, 'Foco controlado rapidamente'),
('000000000001', 2, '2026-06-15 10:00:00', 1001, 'INCENDIO CRIMINOSO', 'ALTISSIMO', 15.50, 'Foco de incêndio detectado em área de vegetação nativa.'),
('000000000001', 2, '2026-06-16 14:30:00', 1003, 'DESMATAMENTO', 'ALTO', 2.00, 'Supressão ilegal de vegetação para abertura de trilha.'),
('000000000001', 2, '2026-06-17 09:15:00', 1001, 'INVASAO DE ZONA', 'BAIXO', 0.00, 'Turistas identificados fora da trilha demarcada.'),
('000000000001', 2, '2026-06-17 17:45:00', 1003, 'CACA', 'MEDIO', 0.00, 'Apreensão de armadilhas de caça tipo alçapão.'),
('000000000002', 2, '2026-06-20 11:00:00', 2001, 'DESMATAMENTO', 'ALTO', 3.00, 'Identificada supressão de vegetação para expansão de área agrícola.'),
('000000000002', 2, '2026-06-21 15:30:00', 2002, 'CACA', 'MEDIO', 10.00, 'Apreensão de armadilhas de caça tipo laço.'),
('000000000003', 1, '2026-06-25 08:45:00', 3001, 'INCENDIO CRIMINOSO', 'ALTISSIMO', 20.00, 'Foco de incêndio detectado em área arqueológica.'),
('000000000004', 1, '2026-06-30 14:20:00', 4001, 'INVASAO DE ZONA', 'ALTO', 0.00, 'Entrada irregular de visitantes na zona de floresta primária.'),
('000000000011', 2, '2026-06-17 14:00:00', 9001, 'GARIMPO', 'ALTISSIMO', 50.00, 'Tentativa de abertura de cava de garimpo ilegal detectada por satélite.');

-- Ocorrência com area_afetada omitida (usa DEFAULT 0.00)
INSERT INTO ocorrencia (unidade_conservacao, nro_zona, data_horario, fiscal, tipo_ocorrencia, nivel_gravidade, descricao)
VALUES ('000000000005', 2, '2026-06-25 11:00:00', 5001, 'OCUPACAO IRREGULAR', 'MEDIO', 'Camping irregular identificado em área de uso restrito.');

-- Ocorrência com tipo_ocorrencia, nivel_gravidade e descricao NULL, area_afetada omitida (DEFAULT 0.00)
INSERT INTO ocorrencia (unidade_conservacao, nro_zona, data_horario, fiscal)
VALUES ('000000000003', 2, '2026-06-19 14:30:00', 3001);

