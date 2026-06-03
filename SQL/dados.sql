-- Tem que colocar a area_total como soma das áreas zonas 
-- Isso provavelmente em aplicação ou criar um trigger

-- Unidades de Conservação
INSERT INTO unidade_conservacao (cnuc, nome, data_criacao, bioma, endereco, orgao_gestor, area_total)
VALUES 
    ('000000000001', 'Parque Nacional do Iguaçu', '1939-01-10', 'Mata Atlântica', 'BR 469, Km 18, Foz do Iguaçu - PR', 'ICMBio', NULL);

INSERT INTO unidade_conservacao (cnuc, nome, data_criacao, bioma, endereco, orgao_gestor, area_total)
VALUES 
    ('000000000002', 'Parque Nacional da Chapada dos Veadeiros', '1961-01-11', 'Cerrado', 'Rodovia GO 239, Km 36, Alto Paraíso de Goiás - GO', 'ICMBio', NULL);


-- Zonas
INSERT INTO zona (unidade_conservacao, nro_zona, nome, tipo, area)
VALUES 
    ('000000000001', 1, 'Zona Intangível (Proteção Estrita)', 'PRESERVACAO', 150000.00),
    ('000000000001', 2, 'Zona de Uso Público (Turismo)', 'USO SUSTENTAVEL', 35262.50);

INSERT INTO zona (unidade_conservacao, nro_zona, nome, tipo, area)
VALUES 
    ('000000000002', 1, 'Zona de Conservação Extrema', 'PRESERVACAO', 200000.00),
    ('000000000002', 2, 'Zona de Recuperação e Visitação', 'USO SUSTENTAVEL', 40611.00);

-- Comunidade Tradicional (só inserções corretas em zonas do tipo 'USO SUSTENTAVEL')
INSERT INTO comunidade_tradicional (unidade_conservacao, nro_zona, nome, tamanho, tipo_comunidade)
VALUES 
    ('000000000001', 2, 'Aldeia Guarani Tekoha', 120, 'Indígena');

INSERT INTO comunidade_tradicional (unidade_conservacao, nro_zona, nome, tamanho, tipo_comunidade)
VALUES 
    ('000000000002', 2, 'Comunidade Quilombola Kalunga', 350, 'Quilombola');

-- Costumes das Comunidades Tradicionais
INSERT INTO comunidade_costume (unidade_conservacao, nro_zona, nome_comunidade, costume)
VALUES 
    ('000000000001', 2, 'Aldeia Guarani Tekoha', 'Produção de artesanato tradicional com fibras naturais e sementes');

INSERT INTO comunidade_costume (unidade_conservacao, nro_zona, nome_comunidade, costume)
VALUES 
    ('000000000002', 2, 'Comunidade Quilombola Kalunga', 'Cultivo agrícola baseado no sistema tradicional de roça de toco');

-- Funcionários
INSERT INTO funcionario (nro_funcional, cpf, nome, data_contratacao, telefone, email, salario, unidade_conservacao)
VALUES 
    (1001, '12345678901', 'Carlos da Silva', '2020-05-15', '45987654321', 'carlos.silva@icmbio.gov.br', 4500.00, '000000000001');


INSERT INTO funcionario (nro_funcional, cpf, nome, data_contratacao, telefone, email, salario, unidade_conservacao)
VALUES    
    (1002, '45612378900', 'João Mendes', '2021-11-20', '45912345678', 'joao.mendes@icmbio.gov.br', 3800.00, '000000000001');

INSERT INTO funcionario (nro_funcional, cpf, nome, data_contratacao, telefone, email, salario, unidade_conservacao)
VALUES 
    (1003, '11122233344', 'Mariana Costa', '2022-03-01', '45988887777', 'mariana.costa@icmbio.gov.br', 4100.00, '000000000001');

INSERT INTO funcionario (nro_funcional, cpf, nome, data_contratacao, telefone, email, salario, unidade_conservacao)
VALUES    
    (2001, '98765432109', 'Ana Batista', '2019-02-10', '61999887766', 'ana.batista@icmbio.gov.br', 5200.50, '000000000002');

INSERT INTO funcionario (nro_funcional, cpf, nome, data_contratacao, telefone, email, salario, unidade_conservacao)
VALUES 
    (2002, '55566677788', 'Roberto Almeida', '2018-08-12', '61977776666', 'roberto.almeida@icmbio.gov.br', 6300.00, '000000000002');

-- Categorias de Funcionário
INSERT INTO funcionario_categoria (funcionario, categoria)
VALUES 
    (1001, 'FISCAL'),
    (1001, 'GESTOR');
    
INSERT INTO funcionario_categoria (funcionario, categoria)
VALUES
    (1002, 'GUIA');

INSERT INTO funcionario_categoria (funcionario, categoria)
VALUES
    (1003, 'BIOLOGO'),
    (1003, 'FISCAL'),
    (1003, 'BRIGADISTA');

INSERT INTO funcionario_categoria (funcionario, categoria)
VALUES 
    (2001, 'BIOLOGO'),
    (2001, 'PESQUISADOR');
    
INSERT INTO funcionario (nro_funcional, cpf, nome, data_contratacao, telefone, email, salario, unidade_conservacao)
VALUES 
    (2002, 'GUIA'),
    (2002, 'PESQUISADOR');

-- Visitantes
INSERT INTO visitante (cpf, nome, telefone, email)
VALUES 
    ('22233344455', 'Fernanda Lima', '11988887777', 'fernanda.lima@email.com');

INSERT INTO visitante (cpf, nome, telefone, email)
VALUES 
    ('66677788899', 'Rafael Souza', '21977776666', 'rafael.souza@email.com');

INSERT INTO visitante (cpf, nome, telefone, email)
VALUES 
    ('10120230344', 'Camila Barros', '31955554444', 'camila.barros@email.com');


INSERT INTO visitante (cpf, nome, telefone, email)
VALUES
    ('90980870766', 'Diego Martins', '41944443333', 'diego.martins@email.com');
    
INSERT INTO visitante (cpf, nome, telefone, email)
VALUES
    ('50540430322', 'Juliana Peixoto', '81933332222', 'juliana.peixoto@email.com');

-- Visitas
-- Visitas para o Parque Nacional do Iguaçu (UC: '000000000001')
INSERT INTO visita (unidade_conservacao, nro_zona, nro_visita, data_hora, tipo, nro_visitantes, guia)
VALUES
    ('000000000001', 2, 101, '2026-06-15 09:00:00', 'TURISTICA', 0, 1002);

INSERT INTO visita (unidade_conservacao, nro_zona, nro_visita, data_hora, tipo, nro_visitantes, guia)
VALUES
    ('000000000001', 2, 102, '2026-06-15 14:00:00', 'EDUCATIVA', 0, 1002);

INSERT INTO visita (unidade_conservacao, nro_zona, nro_visita, data_hora, tipo, nro_visitantes, guia)
VALUES
    ('000000000001', 2, 103, '2026-06-16 08:30:00', 'CIENTIFICA', 0, NULL);

-- Visitas para a Chapada dos Veadeiros (UC: '000000000002')
INSERT INTO visita (unidade_conservacao, nro_zona, nro_visita, data_hora, tipo, nro_visitantes, guia)
VALUES 
    ('000000000002', 2, 201, '2026-06-20 10:00:00', 'TURISTICA', 0, 2002);

INSERT INTO visita (unidade_conservacao, nro_zona, nro_visita, data_hora, tipo, nro_visitantes, guia)
VALUES
    ('000000000002', 2, 202, '2026-06-21 09:00:00', 'EDUCATIVA', 0, NULL);

INSERT INTO visita (unidade_conservacao, nro_zona, nro_visita, data_hora, tipo, nro_visitantes, guia)
VALUES
    ('000000000002', 2, 203, '2026-06-22 13:00:00', 'CIENTIFICA', 0, 2002);

-- Visitas e Visitantes
-- Agendando a Visita 1 (Parque do Iguaçu - Turística) como um GRUPO de 3 pessoas
INSERT INTO visita_visitante (visita, visitante) 
VALUES
    (1, '22233344455'); -- Fernanda

INSERT INTO visita_visitante (visita, visitante) 
VALUES 
    (1, '66677788899'); -- Rafael

INSERT INTO visita_visitante (visita, visitante) 
VALUES 
    (1, '10120230344'); -- Camila

-- Agendando a Visita 2 (Parque do Iguaçu - Educativa) para 1 pessoa individual
INSERT INTO visita_visitante (visita, visitante) 
VALUES 
    (2, '90980870766'); -- Diego

-- Agendando a Visita 4 (Chapada dos Veadeiros - Turística) para 1 pessoa individual
INSERT INTO visita_visitante (visita, visitante) 
VALUES 
    (4, '50540430322'); -- Juliana

-- Agendando a Visita 5 (Chapada dos Veadeiros - Educativa) para 1 pessoa individual
INSERT INTO visita_visitante (visita, visitante) 
VALUES 
    (5, '22233344455'); -- Fernanda (viajando para outra UC)