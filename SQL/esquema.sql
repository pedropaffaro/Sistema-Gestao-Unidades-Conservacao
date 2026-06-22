-- ============================================================================
-- unidade_conservacao
-- Entidade central: cada Unidade de Conservação (UC) do sistema.
-- Identificada pelo CNUC (chave). É referenciada por zonas, funcionários
-- e pelo cadastro de espécies presentes na UC.
-- ============================================================================
CREATE TABLE unidade_conservacao (
    cnuc             char(12) NOT NULL,           -- PK: código CNUC (formato XXXX.XX.XXXX)
    nome             varchar(100),
    data_criacao     date DEFAULT CURRENT_DATE,   -- default: data do cadastro
    bioma            varchar(30),
    rodovia          char(6),                      -- dados de acesso (rodovia/km/cidade/uf)
    km               smallint,
    cidade           varchar(50),
    uf               char(2),
    descricao_acesso varchar(255),
    orgao_gestor     varchar(100),
    area_total       numeric(10, 2) DEFAULT 0.00,  -- atributo DERIVADO: soma das áreas das zonas da UC
    -- TODO: criar um trigger para fazer o calculo automático

    CONSTRAINT pk_unidade_conservacao 
        PRIMARY KEY (cnuc),

    -- CNUC oficial: 10 dígitos no formato XXXX.XX.XXXX (12 caracteres com os pontos)
    CONSTRAINT ck_cnuc_formato
        CHECK (cnuc ~ '^[0-9]{4}\.[0-9]{2}\.[0-9]{4}$'),

    CONSTRAINT ck_area_total 
        CHECK (area_total >= 0),

    -- Domínio: apenas siglas válidas das 27 unidades federativas do Brasil
    CONSTRAINT ck_uf
        CHECK (UPPER(uf) IN ('AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA', 'MT', 'MS', 'MG', 'PA', 'PB', 'PR', 'PE', 'PI', 'RJ', 'RN', 'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO')),

    -- Domínio: km de acesso entre 0 e 9999
    CONSTRAINT ck_km_valido
        CHECK (km >= 0 AND km < 10000)
);


-- ============================================================================
-- zona
-- Subdivisões internas de uma UC (entidade fraca: identificada pela UC + número
-- sequencial). A soma das áreas das zonas alimenta o area_total da UC.
-- ============================================================================
CREATE TABLE zona (
    unidade_conservacao char(12) NOT NULL,        -- parte da PK + FK para a UC
    nro_zona            smallint NOT NULL,         -- nº sequencial da zona dentro da UC
    nome                varchar(100),
    tipo                varchar(15),
    area                numeric(10, 2),

    CONSTRAINT pk_zona
        PRIMARY KEY (unidade_conservacao, nro_zona),

    CONSTRAINT fk_zona_unidade_conservacao
        FOREIGN KEY (unidade_conservacao) REFERENCES unidade_conservacao (cnuc)
        ON DELETE CASCADE ON UPDATE CASCADE,

    -- Domínio: tipo de manejo da zona
    CONSTRAINT ck_zona_tipo
        CHECK (UPPER(tipo) IN ('PRESERVACAO','USO SUSTENTAVEL')),

    CONSTRAINT ck_zona_area
        CHECK (area >= 0)
);

-- ============================================================================
-- comunidade_tradicional
-- Comunidades tradicionais que habitam uma zona da UC (ribeirinhos, quilombolas,
-- povos indígenas, etc.). Identificada pela zona + nome da comunidade.
-- ============================================================================
CREATE TABLE comunidade_tradicional (
    unidade_conservacao char(12)        NOT NULL,  -- parte da PK + FK (zona)
    nro_zona            smallint        NOT NULL,  -- parte da PK + FK (zona)
    nome                varchar(100)    NOT NULL,  -- parte da PK: nome da comunidade
    tamanho             smallint,                   -- nº de pessoas (opcional)
    tipo_comunidade     varchar(100),

    CONSTRAINT pk_comunidade_tradicional
        PRIMARY KEY (unidade_conservacao, nro_zona, nome),

    CONSTRAINT fk_comunidade_tradicional_zona
        FOREIGN KEY (unidade_conservacao, nro_zona) REFERENCES zona (unidade_conservacao, nro_zona)
        ON DELETE RESTRICT ON UPDATE CASCADE,

    -- Domínio: se informado, o tamanho deve ser positivo
    CONSTRAINT ck_comunidade_tradicional_tamanho
        CHECK (tamanho IS NULL OR tamanho > 0),

    -- Esses dados estão condizentes com a lista de comunidades tradicionais do Ministério do Meio Ambiente:
    -- https://www.gov.br/mma/pt-br/assuntos/povos-e-comunidades-tradicionais
    CONSTRAINT ck_comunidade_tradicional_tipo 
        CHECK (UPPER(tipo_comunidade) IN (
            'ANDIROBEIROS',
            'APANHADORES DE FLORES SEMPRE-VIVAS',
            'BENZENDEIROS',
            'CABOCLOS',
            'CAIÇARAS',
            'CATADORES DE MANGABA',
            'CATINGUEIROS',
            'CIPOZEIROS',
            'FUNDO E FECHO DE PASTO',
            'QUILOMBOLAS',
            'EXTRATIVISTAS',
            'EXTRATIVISTAS COSTEIROS E MARINHOS',
            'FAXINALENSES',
            'GERAISZEIROS',
            'ILHÉUS',
            'MORROQUIANOS',
            'PANTANEIROS',
            'PESCADORES ARTESANAIS',
            'POVO POMERANO',
            'POVOS CIGANOS',
            'COMUNIDADES DE TERREIRO/POVOS E COMUNIDADES DE MATRIZ AFRICANA',
            'POVOS INDÍGENAS',
            'QUEBRADEIRAS DE COCO BABAÇU',
            'RAIZEIROS',
            'RETIREIROS DO ARAGUAIA',
            'RIBEIRINHOS',
            'VAZANTEIROS',
            'VEREDEIROS'
        ))
);

-- ============================================================================
-- comunidade_costume
-- Atributo multivalorado de comunidade_tradicional: os costumes/práticas de cada
-- comunidade (1 linha por costume). O próprio costume compõe a PK.
-- ============================================================================
CREATE TABLE comunidade_costume (
    unidade_conservacao char(12)        NOT NULL,  -- parte da PK + FK (comunidade)
    nro_zona            smallint        NOT NULL,  -- parte da PK + FK (comunidade)
    nome_comunidade     varchar(100)    NOT NULL,  -- parte da PK + FK (comunidade)
    costume             varchar(255)    NOT NULL,  -- parte da PK: o costume em si

    CONSTRAINT pk_comunidade_costume
        PRIMARY KEY (unidade_conservacao, nro_zona, nome_comunidade, costume),

    CONSTRAINT fk_comunidade_costume_comunidade_tradicional
        FOREIGN KEY (unidade_conservacao, nro_zona, nome_comunidade) REFERENCES comunidade_tradicional (unidade_conservacao, nro_zona, nome)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- ============================================================================
-- funcionario
-- Funcionários lotados em uma UC. Centraliza a especialização de papéis
-- (guia, biólogo, pesquisador, fiscal), detalhada em funcionario_categoria.
-- ============================================================================
CREATE TABLE funcionario (
    nro_funcional       smallint        NOT NULL,  -- PK: número funcional
    cpf                 char(11)        NOT NULL,  -- chave única alternativa
    nome                varchar(70),
    data_contratacao    date,
    telefone            char(11),
    email               varchar(100),
    salario             numeric(8, 2),
    unidade_conservacao char(12)        NOT NULL,  -- FK: UC onde trabalha

    CONSTRAINT pk_funcionario
        PRIMARY KEY (nro_funcional),

    CONSTRAINT uc_funcionario
        UNIQUE (cpf),

    CONSTRAINT fk_funcionario_unidade_conservacao
        FOREIGN KEY (unidade_conservacao) REFERENCES unidade_conservacao (cnuc)
        ON DELETE RESTRICT ON UPDATE CASCADE, -- Impede que a unidade seja apagada se houver funcionários
    

    CONSTRAINT ck_funcionario_salario
        CHECK (salario >= 0), -- O salário não pode ser negativo, mas pode ser zero para voluntários
    
    CONSTRAINT ck_email_funcionario
        CHECK (email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') -- Verifica se o email está em um formato válido
);

-- ============================================================================
-- funcionario_categoria
-- Papéis (categorias) de cada funcionário. Implementa a especialização N:N:
-- um funcionário pode acumular vários papéis (ex.: biólogo E fiscal).
-- ============================================================================
CREATE TABLE funcionario_categoria (
    funcionario smallint    NOT NULL,  -- parte da PK + FK (funcionario)
    categoria   varchar(30) NOT NULL,  -- parte da PK: papel (GUIA, BIOLOGO, PESQUISADOR, FISCAL, ...)

    CONSTRAINT pk_funcionario_categoria
        PRIMARY KEY (funcionario, categoria),

    CONSTRAINT fk_funcionario_categoria_funcionario
        FOREIGN KEY (funcionario) REFERENCES funcionario (nro_funcional)
        ON DELETE CASCADE ON UPDATE CASCADE

    -- TODO: Aqui teria que ter um trigger para que a categoria do funcionário sempre estivesse maiúsculo, a fim de otimizar a busca pelo índice e não precisar usar UPPER() nas consultas.
);

-- ============================================================================
-- visitante
-- Pessoas do público que visitam as UCs. Identificadas pelo CPF.
-- ============================================================================
CREATE TABLE visitante (
    cpf         char(11) NOT NULL,  -- PK: CPF do visitante
    nome        varchar(70),
    telefone    char(11),
    email       varchar(100),

    CONSTRAINT pk_visitante
        PRIMARY KEY (cpf),

    CONSTRAINT ck_email_visitante
        CHECK (email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') -- Verifica se o email está em um formato válido
);

-- ============================================================================
-- visita
-- Visitas públicas realizadas a uma zona da UC, opcionalmente conduzidas por um
-- guia (funcionário). Usa CHAVE ARTIFICIAL (cod_visita IDENTITY) no lugar da
-- chave composta natural (UC + zona + nro_visita) para otimizar a indexação.
-- ============================================================================
CREATE TABLE visita (
    cod_visita          integer     NOT NULL GENERATED ALWAYS AS IDENTITY,  -- PK artificial (auto-incremento)
    unidade_conservacao char(12)    NOT NULL,                                -- FK (zona) + chave alternativa
    nro_zona            smallint    NOT NULL,
    nro_visita          integer     NOT NULL,                                -- nº da visita dentro da zona
    data_hora           timestamp   DEFAULT CURRENT_TIMESTAMP,
    tipo                varchar(15) DEFAULT 'TURISTICA',
    nro_visitantes      smallint    DEFAULT 0,                               -- atributo DERIVADO: nº de visitantes vinculados
    guia                smallint,                                            -- FK opcional: funcionário que guiou a visita

    CONSTRAINT pk_visita
        PRIMARY KEY (cod_visita),
    
    CONSTRAINT uc_visita
        UNIQUE (unidade_conservacao, nro_zona, nro_visita),

    CONSTRAINT fk_visita_zona
        FOREIGN KEY (unidade_conservacao, nro_zona) REFERENCES zona (unidade_conservacao, nro_zona)
        ON DELETE CASCADE ON UPDATE CASCADE,
    
    CONSTRAINT fk_visita_guia
        FOREIGN KEY (guia) REFERENCES funcionario (nro_funcional)
        ON DELETE SET NULL ON UPDATE CASCADE, -- Se o guia for deletado, o campo guia da visita é setado para NULL, mas a visita não é deletada. Se o guia tiver seu número funcional atualizado, a atualização é propagada para a visita.

    CONSTRAINT ck_visita_nro_visitantes
        CHECK (nro_visitantes >= 0),

    -- Domínio: natureza da visita (Educativa, Científica ou Turística)
    CONSTRAINT ck_visita_tipo
        CHECK (UPPER(tipo) IN ('EDUCATIVA', 'CIENTIFICA', 'TURISTICA'))

    -- TODO: trigger para incrementar automaticamente nro_visitantes 
    -- O guia deve trabalhar na UC onde ocorre a visita
);

-- ============================================================================
-- visita_visitante
-- Associação N:N entre visitas e visitantes (quem participou de cada visita).
-- ============================================================================
CREATE TABLE visita_visitante (
    visita      integer     NOT NULL,  -- parte da PK + FK (visita)
    visitante   char(11)    NOT NULL,  -- parte da PK + FK (visitante)

    CONSTRAINT pk_visita_visitante
        PRIMARY KEY (visita, visitante),

    CONSTRAINT fk_visita_visitante_visita
        FOREIGN KEY (visita) REFERENCES visita (cod_visita)
        ON DELETE CASCADE ON UPDATE CASCADE,
    
    CONSTRAINT fk_visita_visitante_visitante
        FOREIGN KEY (visitante) REFERENCES visitante (cpf)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- ============================================================================
-- especie
-- Catálogo taxonômico das espécies de interesse. Identificada pelo nome
-- científico. Cada espécie pode ter vários indivíduos (ser_vivo) monitorados.
-- ============================================================================
CREATE TABLE especie (
    nome_cientifico     varchar(255) NOT NULL,  -- PK (formato "Genus species")
    nome_popular        varchar(255),
    familia             varchar(100),
    reino               varchar(100),           -- classificação taxonômica
    ordem               varchar(100),
    classe              varchar(100),
    filo                varchar(100),
    status_conservacao  char(2),                -- domínio: categorias da Lista Vermelha da IUCN
    descricao           text,

    CONSTRAINT pk_especie
        PRIMARY KEY (nome_cientifico),
    
    CONSTRAINT ck_especie_status_conservacao
        -- Valores baseados na lista da IUCN https://oeco.org.br/dicionario-ambiental/27904-entenda-a-classificacao-da-lista-vermelha-da-iucn/
        CHECK (UPPER(status_conservacao) IN ('DD', 'LC', 'NT', 'VU', 'EN', 'CR', 'EW', 'EX', 'NE')),

    CONSTRAINT ck_especie_nome_cientifico
        CHECK (nome_cientifico ~ '^[A-Z][a-z]+ [a-z]+$'), -- Verifica se o nome científico está no formato "Genus species"

    CONSTRAINT ck_reino_especie
        CHECK (UPPER(reino) IN ('ANIMALIA', 'PLANTAE', 'FUNGI', 'PROTISTA', 'MONERA')) -- Verifica se o reino está em um dos 5 reinos tradicionais da biologia
);

-- ============================================================================
-- unidade_conservacao_especie
-- Associação N:N: quais espécies ocorrem em quais UCs (cadastro teórico).
-- ============================================================================
CREATE TABLE unidade_conservacao_especie (
    unidade_conservacao char(12)        NOT NULL,  -- parte da PK + FK (UC)
    especie             varchar(255)    NOT NULL,  -- parte da PK + FK (espécie)

    CONSTRAINT pk_unidade_conservacao_especie
        PRIMARY KEY (unidade_conservacao, especie),

    CONSTRAINT fk_unidade_conservacao_especie_unidade_conservacao
        FOREIGN KEY (unidade_conservacao) REFERENCES unidade_conservacao (cnuc)
        ON DELETE CASCADE ON UPDATE CASCADE,

    CONSTRAINT fk_unidade_conservacao_especie_especie
        FOREIGN KEY (especie) REFERENCES especie (nome_cientifico)
        ON DELETE CASCADE
        ON UPDATE CASCADE -- Como o nome científico pode ser atualizado, é válido colocar o ON UPDATE CASCADE aqui
);

-- ============================================================================
-- pesquisa
-- Projetos de pesquisa científica. Identificados pelo título. Relacionam-se a
-- pesquisadores, áreas temáticas, espécies e comunidades tradicionais.
-- ============================================================================
CREATE TABLE pesquisa (
    titulo              varchar(255) NOT NULL,                  -- PK: título da pesquisa
    data_inicio         date NOT NULL DEFAULT CURRENT_DATE,
    data_termino        date,                                    -- NULL enquanto em andamento
    objetivo            text,
    inst_responsavel    varchar(255),

    CONSTRAINT pk_pesquisa
        PRIMARY KEY (titulo),

    -- Regra: término não pode ser anterior ao início
    CONSTRAINT ck_pesquisa_data
        CHECK (data_termino >= data_inicio)
);

-- ============================================================================
-- pesquisa_area_tematica
-- Atributo multivalorado de pesquisa: as áreas temáticas de cada projeto.
-- ============================================================================
CREATE TABLE pesquisa_area_tematica (
    pesquisa        varchar(255) NOT NULL,  -- parte da PK + FK (pesquisa)
    area_tematica   varchar(255) NOT NULL,  -- parte da PK: área temática

    CONSTRAINT pk_pesquisa_area_tematica
        PRIMARY KEY (pesquisa, area_tematica),
    
    CONSTRAINT fk_pesquisa_area_tematica_pesquisa
        FOREIGN KEY (pesquisa) REFERENCES pesquisa (titulo)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- ============================================================================
-- pesquisa_pesquisador
-- Associação N:N: quais funcionários (pesquisadores) atuam em cada pesquisa.
-- ============================================================================
CREATE TABLE pesquisa_pesquisador (
    pesquisa    varchar(255)    NOT NULL,  -- parte da PK + FK (pesquisa)
    pesquisador smallint        NOT NULL,  -- parte da PK + FK (funcionario)

    CONSTRAINT pk_pesquisa_pesquisador
        PRIMARY KEY (pesquisa, pesquisador),

    CONSTRAINT fk_pesquisa_pesquisador_pesquisa
        FOREIGN KEY (pesquisa) REFERENCES pesquisa (titulo)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    
    CONSTRAINT fk_pesquisa_pesquisador_pesquisador
        FOREIGN KEY (pesquisador) REFERENCES funcionario (nro_funcional)
        ON DELETE RESTRICT ON UPDATE CASCADE -- RESTRICT protege o vínculo; ON UPDATE propaga troca de nro_funcional

    -- TODO: trigger para verificar que o funcionário é do tipo 'PESQUISADOR'
);

-- ============================================================================
-- pesquisa_especie
-- Associação N:N: quais espécies são objeto de estudo de cada pesquisa.
-- ============================================================================
CREATE TABLE pesquisa_especie (
    pesquisa    varchar(255) NOT NULL,  -- parte da PK + FK (pesquisa)
    especie     varchar(255) NOT NULL,  -- parte da PK + FK (espécie)

    CONSTRAINT pk_pesquisa_especie
        PRIMARY KEY (pesquisa, especie),

    CONSTRAINT fk_pesquisa_especie_pesquisa
        FOREIGN KEY (pesquisa) REFERENCES pesquisa (titulo)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    
    CONSTRAINT fk_pesquisa_especie_especie
        FOREIGN KEY (especie) REFERENCES especie (nome_cientifico)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- ============================================================================
-- pesquisa_comunidade_tradicional
-- Associação N:N: quais comunidades tradicionais participam de cada pesquisa.
-- ============================================================================
CREATE TABLE pesquisa_comunidade_tradicional (
    unidade_conservacao char(12)        NOT NULL,  -- parte da PK + FK (comunidade)
    nro_zona            smallint        NOT NULL,  -- parte da PK + FK (comunidade)
    nome_comunidade     varchar(100)    NOT NULL,  -- parte da PK + FK (comunidade)
    pesquisa            varchar(255)    NOT NULL,  -- parte da PK + FK (pesquisa)

    CONSTRAINT pk_pesquisa_comunidade_tradicional
        PRIMARY KEY (unidade_conservacao, nro_zona, nome_comunidade, pesquisa),

    CONSTRAINT fk_pesquisa_comunidade_tradicional_comunidade_tradicional
        FOREIGN KEY (unidade_conservacao, nro_zona, nome_comunidade) REFERENCES comunidade_tradicional (unidade_conservacao, nro_zona, nome)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_pesquisa_comunidade_tradicional_pesquisa
        FOREIGN KEY (pesquisa) REFERENCES pesquisa (titulo)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- ============================================================================
-- ser_vivo
-- Indivíduo (animal) monitorado, identificado pelo chip de rastreamento.
-- Pertence a uma espécie e pode ser alvo de várias observações.
-- ============================================================================
CREATE TABLE ser_vivo (
    chip        integer         NOT NULL,             -- PK: nº do chip de rastreamento
    apelido     varchar(100),
    situacao    varchar(20)     NOT NULL DEFAULT 'VIVO',  -- domínio: estado atual do indivíduo
    especie     varchar(255)    NOT NULL,             -- FK: espécie do indivíduo

    CONSTRAINT pk_ser_vivo 
        PRIMARY KEY (chip),
    
    CONSTRAINT fk_ser_vivo_especie 
        FOREIGN KEY (especie) REFERENCES especie (nome_cientifico)
        ON DELETE RESTRICT -- Bloqueia a remoção de uma espécie se existir um ser vivo associado a espécie
        ON UPDATE CASCADE, -- Como o nome científico pode ser atualizado, é válido colocar o ON UPDATE CASCADE aqui

    -- TODO: Verificar se isso é necessário tendo em vista que não havia anteriormente
    CONSTRAINT ck_ser_vivo_situacao
        CHECK (UPPER(situacao) IN ('VIVO', 'MORTO', 'CAPTURADO','DESAPARECIDO', 'EM REABILITACAO', 'LIBERADO'))
);

-- ============================================================================
-- observacao
-- Registro de avistamento/monitoramento de um ser vivo por um biólogo.
-- Identificada pela combinação (biólogo + ser vivo + data/hora).
-- ============================================================================
CREATE TABLE observacao (
    biologo             smallint        NOT NULL,  -- parte da PK + FK (funcionario biólogo)
    ser_vivo            integer         NOT NULL,  -- parte da PK + FK (ser_vivo)
    data_hora           timestamp       NOT NULL,  -- parte da PK: momento da observação
    metodo              varchar(18),                -- domínio: método de observação
    descricao           text,
    unidade_conservacao char(12)        NOT NULL,  -- FK (zona): onde ocorreu
    nro_zona            smallint        NOT NULL,

    CONSTRAINT pk_observacao
        PRIMARY KEY (biologo, ser_vivo, data_hora),

    CONSTRAINT fk_observacao_biologo
        FOREIGN KEY (biologo) REFERENCES funcionario (nro_funcional)
        ON DELETE RESTRICT ON UPDATE CASCADE, -- RESTRICT protege o histórico; ON UPDATE propaga troca de nro_funcional

    CONSTRAINT fk_observacao_ser_vivo
        FOREIGN KEY (ser_vivo) REFERENCES ser_vivo (chip)
        ON DELETE CASCADE ON UPDATE CASCADE,

    CONSTRAINT fk_observacao_zona
        FOREIGN KEY (unidade_conservacao, nro_zona) REFERENCES zona (unidade_conservacao, nro_zona)
        ON DELETE CASCADE ON UPDATE CASCADE, -- ON UPDATE propaga a troca do CNUC (PK) da unidade via zona

    -- Domínio: Câmera, Visual, Binóculo, Gravação de áudio, Sinais biológicos
    CONSTRAINT ck_observacao_metodo
        CHECK (UPPER(metodo) IN ('CAMERA', 'VISUAL', 'BINOCULO', 'GRAVACAO DE AUDIO', 'SINAIS BIOLOGICOS')),

    -- Regra: não se registra observação no futuro
    CONSTRAINT ck_observacao_data_hora
        CHECK (data_hora <= CURRENT_TIMESTAMP)

    -- TODO: fazer um trigger para verificar que o funcionário é do tipo 'BIOLOGO'
);

-- ============================================================================
-- ocorrencia
-- Ocorrência/incidente ambiental registrado por um fiscal em uma zona da UC.
-- Usa CHAVE ARTIFICIAL (protocolo IDENTITY) no lugar da chave composta natural,
-- para otimizar a indexação.
-- ============================================================================
CREATE TABLE ocorrencia (
    protocolo           integer     NOT NULL GENERATED ALWAYS AS IDENTITY,  -- PK artificial (auto-incremento)
    unidade_conservacao char(12)    NOT NULL,   -- FK (zona) onde ocorreu
    nro_zona            smallint    NOT NULL,
    data_horario        timestamp   NOT NULL,
    fiscal              smallint    NOT NULL,    -- FK: funcionário fiscal que registrou
    tipo_ocorrencia     varchar(25),             -- domínio: tipo do incidente
    nivel_gravidade     varchar(11),             -- domínio: nível de gravidade
    area_afetada        numeric(10, 2) DEFAULT 0.00,  -- área impactada (ha)
    descricao           text,

    CONSTRAINT pk_ocorrencia
        PRIMARY KEY (protocolo),

    -- Chave alternativa: uma ocorrência por zona em um dado instante
    CONSTRAINT uc_ocorrencia
        UNIQUE (unidade_conservacao, nro_zona, data_horario),

    CONSTRAINT fk_ocorrencia_zona
        FOREIGN KEY (unidade_conservacao, nro_zona) REFERENCES zona (unidade_conservacao, nro_zona)
        ON DELETE CASCADE ON UPDATE CASCADE, -- ON UPDATE propaga a troca do CNUC (PK) da unidade via zona
    
    CONSTRAINT fk_ocorrencia_fiscal
        FOREIGN KEY (fiscal) REFERENCES funcionario (nro_funcional)
        ON DELETE RESTRICT ON UPDATE CASCADE, -- RESTRICT protege o histórico; ON UPDATE propaga troca de nro_funcional

    -- Domínio: Desmatamento, Garimpo, Caça, Incêndio criminoso/natural,
    -- Deslizamento de encosta, Ocupação irregular, Tráfico biológico, Invasão de zona
    CONSTRAINT ck_ocorrencia_tipo
        CHECK (UPPER(tipo_ocorrencia) IN ('DESMATAMENTO', 'GARIMPO', 'CACA', 'INCENDIO CRIMINOSO', 'INCENDIO NATURAL', 'DESLIZAMENTO DE ENCOSTA', 'OCUPACAO IRREGULAR',  'TRAFICO BIOLOGICO', 'INVASAO DE ZONA')),

    -- Domínio: baixíssimo, baixo, médio, alto, altíssimo
    CONSTRAINT ck_ocorrencia_nivel_gravidade
        CHECK (UPPER(nivel_gravidade) IN ('BAIXISSIMO', 'BAIXO', 'MEDIO', 'ALTO', 'ALTISSIMO')),

    CONSTRAINT ck_ocorrencia_area_afetada
        CHECK (area_afetada >= 0)

    -- TODO: fazer um trigger para verificar que o funcionário é do tipo 'FISCAL'
);
