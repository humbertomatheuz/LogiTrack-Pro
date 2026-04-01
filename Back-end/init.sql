-- ============================================================
-- LogiTrack-Pro — Script de Inicialização do Banco de Dados
-- 15 veículos | 10+ viagens por veículo | manutenções variadas
-- ============================================================

-- 1. Criação da Tabela de Veículos
CREATE TABLE veiculos (
    id BIGSERIAL PRIMARY KEY,
    placa VARCHAR(10) UNIQUE NOT NULL,
    modelo VARCHAR(50) NOT NULL,
    tipo VARCHAR(20) CHECK (tipo IN ('LEVE', 'PESADO')),
    ano INTEGER
);

-- 2. Criação da Tabela de Viagens
CREATE TABLE viagens (
    id BIGSERIAL PRIMARY KEY,
    veiculo_id BIGINT REFERENCES veiculos(id) ON DELETE CASCADE,
    data_saida TIMESTAMP NOT NULL,
    data_chegada TIMESTAMP,
    origem VARCHAR(100),
    destino VARCHAR(100),
    km_percorrida DECIMAL(10,2)
);

-- 3. Criação da Tabela de Manutenções
CREATE TABLE manutencoes (
    id BIGSERIAL PRIMARY KEY,
    veiculo_id BIGINT REFERENCES veiculos(id) ON DELETE CASCADE,
    data_inicio DATE NOT NULL,
    data_finalizacao DATE,
    tipo_servico VARCHAR(100),
    custo_estimado DECIMAL(10,2),
    status VARCHAR(20) DEFAULT 'PENDENTE'
);

-- 4. Criação da tabela de usuários para a HU01
CREATE TABLE usuarios (
    id BIGSERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    matricula VARCHAR(20) UNIQUE NOT NULL,
    login VARCHAR(50) UNIQUE NOT NULL,
    senha VARCHAR(255) NOT NULL,
    perfil VARCHAR(20) NOT NULL
);

-- ============================================================
-- VEÍCULOS (15 ao total: mix de LEVE e PESADO)
-- ============================================================
INSERT INTO veiculos (placa, modelo, tipo, ano) VALUES
('ABC-1234', 'Fiat Fiorino',           'LEVE',   2022),
('XYZ-9876', 'Volvo FH 460',           'PESADO',  2021),
('KJG-1122', 'Mercedes Sprinter',      'LEVE',   2020),
('LMN-4455', 'Scania R500',            'PESADO',  2023),
('PQR-7788', 'Volkswagen Delivery',    'LEVE',   2021),
('STU-3344', 'Ford Cargo 1723',        'PESADO',  2019),
('VWX-5566', 'Renault Master',         'LEVE',   2022),
('YZA-8899', 'DAF XF 480',             'PESADO',  2022),
('BCD-2233', 'Iveco Daily 35S14',      'LEVE',   2023),
('EFG-6677', 'Mercedes Actros 2651',   'PESADO',  2020),
('HIJ-0011', 'Fiat Ducato',            'LEVE',   2021),
('KLM-3456', 'Scania P360',            'PESADO',  2018),
('NOP-7890', 'Volkswagen Virtus Cargo','LEVE',   2023),
('QRS-1357', 'MAN TGX 28.440',         'PESADO',  2022),
('TUV-2468', 'Toyota Hilux Cabine',    'LEVE',   2020);

-- ============================================================
-- VIAGENS — 10 a 12 por veículo, datas espalhadas em 2024-2025
-- ============================================================

-- Veículo 1 — Fiat Fiorino (ABC-1234)
INSERT INTO viagens (veiculo_id, data_saida, data_chegada, origem, destino, km_percorrida) VALUES
(1, '2024-01-08 07:30:00', '2024-01-08 13:00:00', 'São Paulo',       'Campinas',          95.50),
(1, '2024-02-14 06:00:00', '2024-02-14 10:30:00', 'Campinas',        'Ribeirão Preto',   238.70),
(1, '2024-03-05 08:00:00', '2024-03-05 14:00:00', 'São Paulo',       'Santos',             78.20),
(1, '2024-04-18 07:00:00', '2024-04-18 11:30:00', 'Santos',          'São Paulo',          78.20),
(1, '2024-05-22 09:00:00', '2024-05-22 15:00:00', 'São Paulo',       'Sorocaba',          99.30),
(1, '2024-06-10 08:00:00', '2024-06-10 12:00:00', 'Sorocaba',        'Jundiaí',           64.80),
(1, '2024-07-03 07:30:00', '2024-07-03 13:30:00', 'São Paulo',       'São José dos Campos',84.50),
(1, '2024-08-19 06:00:00', '2024-08-19 10:00:00', 'São José dos Campos','Taubaté',        44.10),
(1, '2024-09-25 09:00:00', '2024-09-25 15:30:00', 'São Paulo',       'Bauru',            320.40),
(1, '2024-11-07 07:00:00', '2024-11-07 11:30:00', 'Bauru',           'Marília',          102.60),
(1, '2025-01-14 08:00:00', '2025-01-14 14:00:00', 'São Paulo',       'Campinas',          95.50),
(1, '2025-03-02 06:30:00', '2025-03-02 12:00:00', 'Campinas',        'São Paulo',          95.50);

-- Veículo 2 — Volvo FH 460 (XYZ-9876)
INSERT INTO viagens (veiculo_id, data_saida, data_chegada, origem, destino, km_percorrida) VALUES
(2, '2024-01-10 05:00:00', '2024-01-11 20:00:00', 'Curitiba',        'Belo Horizonte',   1025.80),
(2, '2024-02-20 04:00:00', '2024-02-21 22:00:00', 'Belo Horizonte',  'Fortaleza',        2182.50),
(2, '2024-03-12 05:00:00', '2024-03-13 18:00:00', 'Fortaleza',       'Recife',            800.30),
(2, '2024-04-02 04:30:00', '2024-04-03 20:00:00', 'Recife',          'Salvador',          839.60),
(2, '2024-05-15 05:00:00', '2024-05-16 22:00:00', 'Salvador',        'Rio de Janeiro',   1654.20),
(2, '2024-06-28 04:00:00', '2024-06-29 18:00:00', 'Rio de Janeiro',  'São Paulo',          430.40),
(2, '2024-07-20 05:00:00', '2024-07-22 10:00:00', 'São Paulo',       'Porto Alegre',     1109.70),
(2, '2024-08-05 04:30:00', '2024-08-06 15:00:00', 'Porto Alegre',    'Florianópolis',    476.80),
(2, '2024-09-18 05:00:00', '2024-09-19 20:00:00', 'Florianópolis',   'Curitiba',         298.40),
(2, '2024-10-30 04:00:00', '2024-10-31 22:00:00', 'Curitiba',        'São Paulo',         408.70),
(2, '2025-01-06 05:00:00', '2025-01-07 20:00:00', 'São Paulo',       'Belo Horizonte',   586.00),
(2, '2025-02-18 04:30:00', '2025-02-20 10:00:00', 'Belo Horizonte',  'Manaus',           4100.20);

-- Veículo 3 — Mercedes Sprinter (KJG-1122)
INSERT INTO viagens (veiculo_id, data_saida, data_chegada, origem, destino, km_percorrida) VALUES
(3, '2024-01-15 08:00:00', '2024-01-15 14:00:00', 'São Paulo',       'Guarulhos',         22.80),
(3, '2024-02-08 07:30:00', '2024-02-08 13:30:00', 'Guarulhos',       'Osasco',            28.50),
(3, '2024-03-20 09:00:00', '2024-03-20 16:00:00', 'São Paulo',       'ABC Paulista',       27.30),
(3, '2024-04-11 08:00:00', '2024-04-11 15:00:00', 'ABC Paulista',    'Santos',             85.20),
(3, '2024-05-29 07:00:00', '2024-05-29 12:30:00', 'Santos',          'São Vicente',         9.40),
(3, '2024-06-14 08:30:00', '2024-06-14 15:30:00', 'São Paulo',       'Mogi das Cruzes',   60.10),
(3, '2024-07-07 07:00:00', '2024-07-07 14:00:00', 'Mogi das Cruzes', 'Suzano',            15.70),
(3, '2024-08-22 08:00:00', '2024-08-22 15:00:00', 'São Paulo',       'Itaquaquecetuba',   48.90),
(3, '2024-09-10 07:30:00', '2024-09-10 13:30:00', 'São Paulo',       'Guarulhos',         22.80),
(3, '2024-10-24 08:00:00', '2024-10-24 15:00:00', 'Guarulhos',       'Campinas',         100.60),
(3, '2025-01-20 07:00:00', '2025-01-20 14:00:00', 'Campinas',        'São Paulo',         95.50),
(3, '2025-03-10 08:00:00', '2025-03-10 15:30:00', 'São Paulo',       'Santos',            78.20);

-- Veículo 4 — Scania R500 (LMN-4455)
INSERT INTO viagens (veiculo_id, data_saida, data_chegada, origem, destino, km_percorrida) VALUES
(4, '2024-01-22 05:00:00', '2024-01-23 18:00:00', 'São Paulo',       'Brasília',         1015.30),
(4, '2024-02-26 04:30:00', '2024-02-27 20:00:00', 'Brasília',        'Goiânia',           208.50),
(4, '2024-03-18 05:00:00', '2024-03-19 19:00:00', 'Goiânia',         'Campo Grande',      936.20),
(4, '2024-04-25 04:00:00', '2024-04-26 17:00:00', 'Campo Grande',    'Cuiabá',            694.80),
(4, '2024-05-30 05:00:00', '2024-05-31 18:00:00', 'Cuiabá',          'Porto Velho',      1456.30),
(4, '2024-06-20 04:30:00', '2024-06-22 10:00:00', 'Porto Velho',     'Manaus',            903.50),
(4, '2024-07-15 05:00:00', '2024-07-16 20:00:00', 'Manaus',          'Boa Vista',         785.20),
(4, '2024-08-28 04:00:00', '2024-08-29 17:00:00', 'Boa Vista',       'Belém',            1591.40),
(4, '2024-09-14 05:00:00', '2024-09-15 18:00:00', 'Belém',           'São Luís',          870.60),
(4, '2024-10-08 04:30:00', '2024-10-09 20:00:00', 'São Luís',        'Teresina',          446.80),
(4, '2024-11-19 05:00:00', '2024-11-20 18:00:00', 'Teresina',        'Fortaleza',         635.70),
(4, '2025-02-04 04:00:00', '2025-02-06 10:00:00', 'Fortaleza',       'São Paulo',        2907.10);

-- Veículo 5 — Volkswagen Delivery (PQR-7788)
INSERT INTO viagens (veiculo_id, data_saida, data_chegada, origem, destino, km_percorrida) VALUES
(5, '2024-01-09 07:00:00', '2024-01-09 12:00:00', 'Belo Horizonte',  'Contagem',          20.40),
(5, '2024-02-13 08:00:00', '2024-02-13 14:00:00', 'Contagem',        'Betim',             18.90),
(5, '2024-03-27 07:30:00', '2024-03-27 13:30:00', 'Belo Horizonte',  'Sabará',            24.80),
(5, '2024-04-16 08:00:00', '2024-04-16 15:00:00', 'Belo Horizonte',  'Sete Lagoas',       76.50),
(5, '2024-05-08 07:00:00', '2024-05-08 14:00:00', 'Sete Lagoas',     'Divinópolis',      100.20),
(5, '2024-06-19 08:30:00', '2024-06-19 15:30:00', 'Divinópolis',     'Belo Horizonte',   126.70),
(5, '2024-07-30 07:00:00', '2024-07-30 13:00:00', 'Belo Horizonte',  'Ipatinga',         200.80),
(5, '2024-08-14 08:00:00', '2024-08-14 14:30:00', 'Ipatinga',        'Coronel Fabriciano',15.30),
(5, '2024-09-23 07:30:00', '2024-09-23 14:30:00', 'Belo Horizonte',  'Montes Claros',    418.40),
(5, '2024-10-15 08:00:00', '2024-10-15 15:00:00', 'Montes Claros',   'Belo Horizonte',   418.40),
(5, '2024-12-03 07:00:00', '2024-12-03 13:00:00', 'Belo Horizonte',  'Contagem',          20.40),
(5, '2025-01-28 08:00:00', '2025-01-28 15:00:00', 'Contagem',        'Belo Horizonte',    20.40);

-- Veículo 6 — Ford Cargo 1723 (STU-3344)
INSERT INTO viagens (veiculo_id, data_saida, data_chegada, origem, destino, km_percorrida) VALUES
(6, '2024-01-17 05:00:00', '2024-01-18 18:00:00', 'Porto Alegre',    'Florianópolis',    476.80),
(6, '2024-02-22 04:30:00', '2024-02-23 10:00:00', 'Florianópolis',   'Joinville',        174.60),
(6, '2024-03-14 05:00:00', '2024-03-14 18:00:00', 'Joinville',       'Curitiba',         129.40),
(6, '2024-04-29 04:00:00', '2024-04-30 20:00:00', 'Curitiba',        'São Paulo',         408.70),
(6, '2024-05-17 05:00:00', '2024-05-17 18:00:00', 'São Paulo',       'Campinas',          97.20),
(6, '2024-06-25 04:30:00', '2024-06-26 12:00:00', 'Campinas',        'Ribeirão Preto',   238.70),
(6, '2024-07-10 05:00:00', '2024-07-11 10:00:00', 'Ribeirão Preto',  'Uberlândia',       385.90),
(6, '2024-08-01 04:00:00', '2024-08-02 18:00:00', 'Uberlândia',      'Belo Horizonte',   578.60),
(6, '2024-09-12 05:00:00', '2024-09-13 10:00:00', 'Belo Horizonte',  'Rio de Janeiro',   440.30),
(6, '2024-10-21 04:30:00', '2024-10-22 18:00:00', 'Rio de Janeiro',  'São Paulo',         430.40),
(6, '2024-12-09 05:00:00', '2024-12-10 10:00:00', 'São Paulo',       'Curitiba',          408.70),
(6, '2025-02-11 04:00:00', '2025-02-12 20:00:00', 'Curitiba',        'Porto Alegre',     476.80);

-- Veículo 7 — Renault Master (VWX-5566)
INSERT INTO viagens (veiculo_id, data_saida, data_chegada, origem, destino, km_percorrida) VALUES
(7, '2024-01-11 09:00:00', '2024-01-11 14:00:00', 'Rio de Janeiro',  'Niterói',           13.80),
(7, '2024-02-16 08:00:00', '2024-02-16 14:00:00', 'Niterói',         'Petrópolis',        77.20),
(7, '2024-03-22 09:00:00', '2024-03-22 14:30:00', 'Petrópolis',      'Volta Redonda',     82.40),
(7, '2024-04-07 08:30:00', '2024-04-07 14:30:00', 'Volta Redonda',   'Rio de Janeiro',   128.60),
(7, '2024-05-19 09:00:00', '2024-05-19 15:30:00', 'Rio de Janeiro',  'Angra dos Reis',   168.30),
(7, '2024-06-30 08:00:00', '2024-06-30 14:00:00', 'Angra dos Reis',  'Paraty',            65.40),
(7, '2024-07-22 09:00:00', '2024-07-22 15:30:00', 'Paraty',          'Ubatuba',           97.80),
(7, '2024-08-09 08:30:00', '2024-08-09 14:30:00', 'Ubatuba',         'Caraguatatuba',     27.60),
(7, '2024-09-26 09:00:00', '2024-09-26 15:00:00', 'Rio de Janeiro',  'Campos dos Goytacazes',279.50),
(7, '2024-10-17 08:00:00', '2024-10-17 14:00:00', 'Campos dos Goytacazes','Rio de Janeiro',279.50),
(7, '2024-11-28 09:00:00', '2024-11-28 15:00:00', 'Rio de Janeiro',  'Niterói',           13.80),
(7, '2025-03-05 08:30:00', '2025-03-05 14:30:00', 'Niterói',         'Rio de Janeiro',    13.80);

-- Veículo 8 — DAF XF 480 (YZA-8899)
INSERT INTO viagens (veiculo_id, data_saida, data_chegada, origem, destino, km_percorrida) VALUES
(8, '2024-01-24 05:00:00', '2024-01-25 20:00:00', 'Belém',           'São Luís',          870.60),
(8, '2024-02-28 04:00:00', '2024-02-29 17:00:00', 'São Luís',        'Fortaleza',        1072.20),
(8, '2024-03-25 05:00:00', '2024-03-26 18:00:00', 'Fortaleza',       'Natal',             537.80),
(8, '2024-04-13 04:30:00', '2024-04-14 17:00:00', 'Natal',           'João Pessoa',       184.50),
(8, '2024-05-26 05:00:00', '2024-05-27 18:00:00', 'João Pessoa',     'Recife',            119.30),
(8, '2024-06-16 04:00:00', '2024-06-17 20:00:00', 'Recife',          'Maceió',            289.70),
(8, '2024-07-28 05:00:00', '2024-07-29 18:00:00', 'Maceió',          'Aracaju',           299.40),
(8, '2024-08-18 04:30:00', '2024-08-19 18:00:00', 'Aracaju',         'Salvador',          350.20),
(8, '2024-09-06 05:00:00', '2024-09-08 10:00:00', 'Salvador',        'Rio de Janeiro',   1654.20),
(8, '2024-10-29 04:00:00', '2024-10-30 20:00:00', 'Rio de Janeiro',  'Belo Horizonte',   440.30),
(8, '2024-12-16 05:00:00', '2024-12-17 18:00:00', 'Belo Horizonte',  'São Paulo',         588.40),
(8, '2025-01-30 04:30:00', '2025-02-01 10:00:00', 'São Paulo',       'Belém',            2567.80);

-- Veículo 9 — Iveco Daily 35S14 (BCD-2233)
INSERT INTO viagens (veiculo_id, data_saida, data_chegada, origem, destino, km_percorrida) VALUES
(9, '2024-01-19 08:00:00', '2024-01-19 14:00:00', 'Curitiba',        'Londrina',         378.30),
(9, '2024-02-23 07:30:00', '2024-02-23 13:30:00', 'Londrina',        'Maringá',           96.90),
(9, '2024-03-08 08:00:00', '2024-03-08 14:30:00', 'Maringá',         'Cascavel',         254.10),
(9, '2024-04-20 07:00:00', '2024-04-20 13:00:00', 'Cascavel',        'Foz do Iguaçu',   138.60),
(9, '2024-05-13 08:30:00', '2024-05-13 14:30:00', 'Foz do Iguaçu',  'Curitiba',         639.60),
(9, '2024-06-26 07:00:00', '2024-06-26 12:30:00', 'Curitiba',        'Joinville',        129.40),
(9, '2024-07-18 08:00:00', '2024-07-18 14:00:00', 'Joinville',       'Blumenau',          48.40),
(9, '2024-08-31 07:30:00', '2024-08-31 13:30:00', 'Blumenau',        'Florianópolis',    146.10),
(9, '2024-09-21 08:00:00', '2024-09-21 14:30:00', 'Florianópolis',   'Criciúma',         177.80),
(9, '2024-10-12 07:00:00', '2024-10-12 13:00:00', 'Criciúma',        'Curitiba',         349.50),
(9, '2024-11-24 08:00:00', '2024-11-24 14:00:00', 'Curitiba',        'Paranaguá',         91.50),
(9, '2025-02-07 07:30:00', '2025-02-07 14:00:00', 'Paranaguá',       'Curitiba',          91.50);

-- Veículo 10 — Mercedes Actros 2651 (EFG-6677)
INSERT INTO viagens (veiculo_id, data_saida, data_chegada, origem, destino, km_percorrida) VALUES
(10, '2024-01-26 05:00:00', '2024-01-27 18:00:00', 'São Paulo',      'Manaus',           3905.60),
(10, '2024-02-29 04:00:00', '2024-03-01 20:00:00', 'Manaus',         'Porto Velho',       903.50),
(10, '2024-03-30 05:00:00', '2024-04-01 10:00:00', 'Porto Velho',    'Cuiabá',           1456.20),
(10, '2024-04-22 04:30:00', '2024-04-23 18:00:00', 'Cuiabá',         'Campo Grande',      694.80),
(10, '2024-05-27 05:00:00', '2024-05-28 18:00:00', 'Campo Grande',   'Brasília',         1144.60),
(10, '2024-06-11 04:00:00', '2024-06-12 20:00:00', 'Brasília',        'São Paulo',        1015.30),
(10, '2024-07-24 05:00:00', '2024-07-26 10:00:00', 'São Paulo',      'Recife',           2657.40),
(10, '2024-08-07 04:30:00', '2024-08-09 18:00:00', 'Recife',         'São Paulo',        2657.40),
(10, '2024-09-17 05:00:00', '2024-09-18 20:00:00', 'São Paulo',      'Rio de Janeiro',    430.40),
(10, '2024-10-03 04:00:00', '2024-10-04 18:00:00', 'Rio de Janeiro', 'Belo Horizonte',   440.30),
(10, '2024-11-12 05:00:00', '2024-11-13 10:00:00', 'Belo Horizonte', 'Porto Alegre',    1520.80),
(10, '2025-03-18 04:30:00', '2025-03-20 10:00:00', 'Porto Alegre',   'São Paulo',        1109.70);

-- Veículo 11 — Fiat Ducato (HIJ-0011)
INSERT INTO viagens (veiculo_id, data_saida, data_chegada, origem, destino, km_percorrida) VALUES
(11, '2024-01-30 08:00:00', '2024-01-30 14:00:00', 'Goiânia',        'Anápolis',          55.20),
(11, '2024-02-19 07:30:00', '2024-02-19 14:00:00', 'Anápolis',       'Brasília',          56.40),
(11, '2024-03-11 08:00:00', '2024-03-11 15:00:00', 'Brasília',        'Luziânia',          60.80),
(11, '2024-04-24 07:00:00', '2024-04-24 14:00:00', 'Luziânia',       'Goiânia',          161.80),
(11, '2024-05-31 08:30:00', '2024-05-31 15:00:00', 'Goiânia',        'Rio Verde',        220.50),
(11, '2024-06-13 07:00:00', '2024-06-13 14:00:00', 'Rio Verde',      'Jataí',             86.30),
(11, '2024-07-26 08:00:00', '2024-07-26 14:30:00', 'Jataí',          'Goiânia',          302.90),
(11, '2024-08-16 07:30:00', '2024-08-16 14:30:00', 'Goiânia',        'Aparecida de Goiânia',13.60),
(11, '2024-09-03 08:00:00', '2024-09-03 14:30:00', 'Goiânia',        'Caldas Novas',     167.80),
(11, '2024-10-26 07:00:00', '2024-10-26 13:30:00', 'Caldas Novas',   'Goiânia',          167.80),
(11, '2024-12-18 08:00:00', '2024-12-18 15:00:00', 'Goiânia',        'Anápolis',          55.20),
(11, '2025-01-22 07:30:00', '2025-01-22 14:00:00', 'Anápolis',       'Goiânia',           55.20);

-- Veículo 12 — Scania P360 (KLM-3456)
INSERT INTO viagens (veiculo_id, data_saida, data_chegada, origem, destino, km_percorrida) VALUES
(12, '2024-01-05 05:00:00', '2024-01-06 18:00:00', 'São Paulo',      'Vitória',          919.80),
(12, '2024-02-06 04:30:00', '2024-02-07 18:00:00', 'Vitória',        'Rio de Janeiro',   521.20),
(12, '2024-03-16 05:00:00', '2024-03-17 20:00:00', 'Rio de Janeiro', 'Salvador',        1654.20),
(12, '2024-04-05 04:00:00', '2024-04-06 18:00:00', 'Salvador',       'Aracaju',          350.20),
(12, '2024-05-03 05:00:00', '2024-05-04 10:00:00', 'Aracaju',        'Recife',           589.10),
(12, '2024-06-07 04:30:00', '2024-06-09 10:00:00', 'Recife',         'São Paulo',        2657.40),
(12, '2024-07-11 05:00:00', '2024-07-12 20:00:00', 'São Paulo',      'Belo Horizonte',   588.40),
(12, '2024-08-24 04:00:00', '2024-08-25 18:00:00', 'Belo Horizonte', 'Curitiba',        1082.60),
(12, '2024-09-30 05:00:00', '2024-10-01 20:00:00', 'Curitiba',       'Porto Alegre',     476.80),
(12, '2024-11-04 04:30:00', '2024-11-05 18:00:00', 'Porto Alegre',   'Florianópolis',    476.80),
(12, '2024-12-22 05:00:00', '2024-12-23 18:00:00', 'Florianópolis',  'São Paulo',        716.40),
(12, '2025-03-25 04:00:00', '2025-03-26 20:00:00', 'São Paulo',      'Vitória',          919.80);

-- Veículo 13 — Volkswagen Virtus Cargo (NOP-7890)
INSERT INTO viagens (veiculo_id, data_saida, data_chegada, origem, destino, km_percorrida) VALUES
(13, '2024-01-12 08:00:00', '2024-01-12 13:30:00', 'Manaus',         'Itacoatiara',      270.60),
(13, '2024-02-17 07:30:00', '2024-02-17 13:00:00', 'Manaus',         'Parintins',        369.50),
(13, '2024-03-28 08:00:00', '2024-03-28 14:00:00', 'Manaus',         'Presidente Figueiredo',107.20),
(13, '2024-04-09 07:00:00', '2024-04-09 13:00:00', 'Manaus',         'Autazes',          113.80),
(13, '2024-05-21 08:30:00', '2024-05-21 15:00:00', 'Manaus',         'Iranduba',          25.40),
(13, '2024-06-03 07:00:00', '2024-06-03 13:00:00', 'Iranduba',       'Manaus',            25.40),
(13, '2024-07-16 08:00:00', '2024-07-16 14:00:00', 'Manaus',         'Itacoatiara',      270.60),
(13, '2024-08-27 07:30:00', '2024-08-27 13:30:00', 'Manaus',         'Parintins',        369.50),
(13, '2024-09-09 08:00:00', '2024-09-09 14:30:00', 'Manaus',         'Careiro',           85.70),
(13, '2024-10-20 07:00:00', '2024-10-20 13:30:00', 'Careiro',        'Manaus',            85.70),
(13, '2024-11-30 08:00:00', '2024-11-30 14:30:00', 'Manaus',         'Presidente Figueiredo',107.20),
(13, '2025-02-25 07:30:00', '2025-02-25 14:00:00', 'Manaus',         'Itacoatiara',      270.60);

-- Veículo 14 — MAN TGX 28.440 (QRS-1357)
INSERT INTO viagens (veiculo_id, data_saida, data_chegada, origem, destino, km_percorrida) VALUES
(14, '2024-01-03 05:00:00', '2024-01-04 20:00:00', 'Campinas',       'Rio de Janeiro',   531.80),
(14, '2024-02-10 04:30:00', '2024-02-11 18:00:00', 'Rio de Janeiro', 'Belo Horizonte',   440.30),
(14, '2024-03-23 05:00:00', '2024-03-24 18:00:00', 'Belo Horizonte', 'Salvador',        1452.50),
(14, '2024-04-30 04:00:00', '2024-05-01 20:00:00', 'Salvador',       'São Paulo',        1955.00),
(14, '2024-05-11 05:00:00', '2024-05-12 18:00:00', 'São Paulo',      'Porto Alegre',     1109.70),
(14, '2024-06-22 04:30:00', '2024-06-23 18:00:00', 'Porto Alegre',   'Curitiba',         476.80),
(14, '2024-07-05 05:00:00', '2024-07-06 20:00:00', 'Curitiba',       'Brasília',        1411.30),
(14, '2024-08-12 04:00:00', '2024-08-13 18:00:00', 'Brasília',        'Fortaleza',       2383.10),
(14, '2024-09-28 05:00:00', '2024-09-30 10:00:00', 'Fortaleza',      'Recife',            537.80),
(14, '2024-11-01 04:30:00', '2024-11-02 18:00:00', 'Recife',         'São Paulo',        2657.40),
(14, '2024-12-13 05:00:00', '2024-12-14 20:00:00', 'São Paulo',      'Rio de Janeiro',    430.40),
(14, '2025-03-20 04:00:00', '2025-03-21 18:00:00', 'Rio de Janeiro', 'Campinas',         530.60);

-- Veículo 15 — Toyota Hilux Cabine (TUV-2468)
INSERT INTO viagens (veiculo_id, data_saida, data_chegada, origem, destino, km_percorrida) VALUES
(15, '2024-01-16 08:00:00', '2024-01-16 14:00:00', 'Brasília',        'Planaltina',        50.20),
(15, '2024-02-21 07:30:00', '2024-02-21 13:30:00', 'Brasília',        'Gama',              35.80),
(15, '2024-03-06 08:00:00', '2024-03-06 15:00:00', 'Brasília',        'Taguatinga',        25.60),
(15, '2024-04-17 07:00:00', '2024-04-17 14:00:00', 'Brasília',        'Sobradinho',        22.70),
(15, '2024-05-28 08:30:00', '2024-05-28 15:30:00', 'Brasília',        'Luziânia',          60.80),
(15, '2024-06-04 07:00:00', '2024-06-04 14:00:00', 'Luziânia',       'Brasília',           60.80),
(15, '2024-07-19 08:00:00', '2024-07-19 15:00:00', 'Brasília',        'Goiânia',          208.50),
(15, '2024-08-30 07:30:00', '2024-08-30 14:30:00', 'Goiânia',        'Brasília',          208.50),
(15, '2024-09-11 08:00:00', '2024-09-11 14:30:00', 'Brasília',        'Formosa',           78.30),
(15, '2024-10-22 07:00:00', '2024-10-22 13:30:00', 'Formosa',        'Brasília',           78.30),
(15, '2024-12-05 08:00:00', '2024-12-05 14:30:00', 'Brasília',        'Anápolis',         160.70),
(15, '2025-02-13 07:30:00', '2025-02-13 14:30:00', 'Anápolis',       'Brasília',          160.70);

-- ============================================================
-- MANUTENÇÕES — 2-3 CONCLUÍDAS + 1 PENDENTE ou EM_REALIZACAO por veículo
-- ============================================================

-- Veículo 1 — Fiat Fiorino
INSERT INTO manutencoes (veiculo_id, data_inicio, data_finalizacao, tipo_servico, custo_estimado, status) VALUES
(1, '2024-02-05', '2024-02-05', 'Troca de Óleo',         350.00,  'CONCLUIDA'),
(1, '2024-05-18', '2024-05-19', 'Troca de Filtros',      420.00,  'CONCLUIDA'),
(1, '2024-09-10', '2024-09-11', 'Alinhamento e Balanceamento', 280.00, 'CONCLUIDA'),
(1, '2025-03-15', NULL,         'Revisão Geral 30.000 km',1100.00, 'PENDENTE');

-- Veículo 2 — Volvo FH 460
INSERT INTO manutencoes (veiculo_id, data_inicio, data_finalizacao, tipo_servico, custo_estimado, status) VALUES
(2, '2024-01-20', '2024-01-22', 'Revisão de Freios',    1800.00, 'CONCLUIDA'),
(2, '2024-05-10', '2024-05-12', 'Troca de Pneus Traseiros',4800.00,'CONCLUIDA'),
(2, '2024-09-25', '2024-09-28', 'Troca de Óleo e Filtros',650.00, 'CONCLUIDA'),
(2, '2025-02-01', '2025-02-03', 'Revisão de Suspensão',  2200.00, 'EM_REALIZACAO');

-- Veículo 3 — Mercedes Sprinter
INSERT INTO manutencoes (veiculo_id, data_inicio, data_finalizacao, tipo_servico, custo_estimado, status) VALUES
(3, '2024-03-08', '2024-03-08', 'Troca de Óleo',         380.00,  'CONCLUIDA'),
(3, '2024-06-20', '2024-06-21', 'Revisão de Freios',     950.00,  'CONCLUIDA'),
(3, '2024-10-14', '2024-10-15', 'Troca de Correia Dentada',780.00,'CONCLUIDA'),
(3, '2025-03-20', NULL,         'Troca de Pneus',        1600.00,  'PENDENTE');

-- Veículo 4 — Scania R500
INSERT INTO manutencoes (veiculo_id, data_inicio, data_finalizacao, tipo_servico, custo_estimado, status) VALUES
(4, '2024-02-12', '2024-02-14', 'Revisão Completa',      3500.00, 'CONCLUIDA'),
(4, '2024-06-05', '2024-06-07', 'Troca de Pneus Dianteiros',3200.00,'CONCLUIDA'),
(4, '2024-10-18', '2024-10-20', 'Troca de Óleo e Filtros',720.00, 'CONCLUIDA'),
(4, '2025-01-15', '2025-01-17', 'Revisão de Freios',     2100.00, 'EM_REALIZACAO');

-- Veículo 5 — Volkswagen Delivery
INSERT INTO manutencoes (veiculo_id, data_inicio, data_finalizacao, tipo_servico, custo_estimado, status) VALUES
(5, '2024-02-28', '2024-02-28', 'Troca de Óleo',         310.00,  'CONCLUIDA'),
(5, '2024-07-01', '2024-07-02', 'Alinhamento e Balanceamento',260.00,'CONCLUIDA'),
(5, '2024-10-30', '2024-10-31', 'Revisão de Freios',     870.00,  'CONCLUIDA'),
(5, '2025-03-28', NULL,         'Troca de Filtros',       380.00,  'PENDENTE');

-- Veículo 6 — Ford Cargo 1723
INSERT INTO manutencoes (veiculo_id, data_inicio, data_finalizacao, tipo_servico, custo_estimado, status) VALUES
(6, '2024-01-28', '2024-01-30', 'Troca de Pneus',        4200.00, 'CONCLUIDA'),
(6, '2024-05-20', '2024-05-22', 'Revisão de Motor',      2800.00, 'CONCLUIDA'),
(6, '2024-09-08', '2024-09-10', 'Troca de Óleo e Filtros',680.00, 'CONCLUIDA'),
(6, '2025-02-20', NULL,         'Revisão de Suspensão',  1900.00,  'PENDENTE');

-- Veículo 7 — Renault Master
INSERT INTO manutencoes (veiculo_id, data_inicio, data_finalizacao, tipo_servico, custo_estimado, status) VALUES
(7, '2024-03-15', '2024-03-15', 'Troca de Óleo',         290.00,  'CONCLUIDA'),
(7, '2024-07-10', '2024-07-11', 'Revisão de Freios',     810.00,  'CONCLUIDA'),
(7, '2024-11-05', '2024-11-06', 'Troca de Pneus Dianteiros',1400.00,'CONCLUIDA'),
(7, '2025-03-12', '2025-03-14', 'Revisão Elétrica',       650.00, 'EM_REALIZACAO');

-- Veículo 8 — DAF XF 480
INSERT INTO manutencoes (veiculo_id, data_inicio, data_finalizacao, tipo_servico, custo_estimado, status) VALUES
(8, '2024-02-15', '2024-02-17', 'Troca de Pneus Traseiros',4600.00,'CONCLUIDA'),
(8, '2024-06-18', '2024-06-20', 'Revisão de Freios',     1950.00, 'CONCLUIDA'),
(8, '2024-10-07', '2024-10-09', 'Troca de Óleo e Filtros',700.00, 'CONCLUIDA'),
(8, '2025-01-25', NULL,         'Revisão Completa',       3800.00,  'PENDENTE');

-- Veículo 9 — Iveco Daily 35S14
INSERT INTO manutencoes (veiculo_id, data_inicio, data_finalizacao, tipo_servico, custo_estimado, status) VALUES
(9, '2024-03-22', '2024-03-22', 'Troca de Óleo',         330.00,  'CONCLUIDA'),
(9, '2024-07-14', '2024-07-15', 'Alinhamento e Balanceamento',240.00,'CONCLUIDA'),
(9, '2024-11-18', '2024-11-19', 'Revisão de Freios',     920.00,  'CONCLUIDA'),
(9, '2025-03-30', NULL,         'Troca de Correia Dentada',690.00, 'PENDENTE');

-- Veículo 10 — Mercedes Actros 2651
INSERT INTO manutencoes (veiculo_id, data_inicio, data_finalizacao, tipo_servico, custo_estimado, status) VALUES
(10, '2024-02-08', '2024-02-10', 'Revisão Completa',     4200.00, 'CONCLUIDA'),
(10, '2024-06-30', '2024-07-02', 'Troca de Pneus',       5200.00, 'CONCLUIDA'),
(10, '2024-10-25', '2024-10-27', 'Troca de Óleo e Filtros',750.00,'CONCLUIDA'),
(10, '2025-02-15', '2025-02-17', 'Revisão de Suspensão', 2600.00, 'EM_REALIZACAO');

-- Veículo 11 — Fiat Ducato
INSERT INTO manutencoes (veiculo_id, data_inicio, data_finalizacao, tipo_servico, custo_estimado, status) VALUES
(11, '2024-02-25', '2024-02-25', 'Troca de Óleo',         300.00, 'CONCLUIDA'),
(11, '2024-06-08', '2024-06-09', 'Revisão de Freios',     840.00, 'CONCLUIDA'),
(11, '2024-10-02', '2024-10-03', 'Troca de Filtros',      360.00, 'CONCLUIDA'),
(11, '2025-03-05', NULL,         'Troca de Pneus',        1280.00,  'PENDENTE');

-- Veículo 12 — Scania P360
INSERT INTO manutencoes (veiculo_id, data_inicio, data_finalizacao, tipo_servico, custo_estimado, status) VALUES
(12, '2024-01-25', '2024-01-27', 'Revisão de Motor',     3100.00, 'CONCLUIDA'),
(12, '2024-05-05', '2024-05-07', 'Troca de Pneus Traseiros',4400.00,'CONCLUIDA'),
(12, '2024-09-01', '2024-09-03', 'Troca de Óleo e Filtros',660.00, 'CONCLUIDA'),
(12, '2025-01-10', NULL,         'Revisão de Freios',     2050.00,  'PENDENTE');

-- Veículo 13 — Volkswagen Virtus Cargo
INSERT INTO manutencoes (veiculo_id, data_inicio, data_finalizacao, tipo_servico, custo_estimado, status) VALUES
(13, '2024-03-18', '2024-03-18', 'Troca de Óleo',         270.00, 'CONCLUIDA'),
(13, '2024-07-22', '2024-07-23', 'Alinhamento e Balanceamento',220.00,'CONCLUIDA'),
(13, '2024-11-10', '2024-11-11', 'Revisão de Freios',     790.00, 'CONCLUIDA'),
(13, '2025-03-22', '2025-03-24', 'Revisão Elétrica',       540.00,'EM_REALIZACAO');

-- Veículo 14 — MAN TGX 28.440
INSERT INTO manutencoes (veiculo_id, data_inicio, data_finalizacao, tipo_servico, custo_estimado, status) VALUES
(14, '2024-02-02', '2024-02-04', 'Revisão Completa',     3800.00, 'CONCLUIDA'),
(14, '2024-06-12', '2024-06-14', 'Troca de Pneus',       5000.00, 'CONCLUIDA'),
(14, '2024-09-20', '2024-09-22', 'Troca de Óleo e Filtros',730.00,'CONCLUIDA'),
(14, '2025-02-28', NULL,         'Revisão de Suspensão',  2400.00,  'PENDENTE');

-- Veículo 15 — Toyota Hilux Cabine
INSERT INTO manutencoes (veiculo_id, data_inicio, data_finalizacao, tipo_servico, custo_estimado, status) VALUES
(15, '2024-03-01', '2024-03-01', 'Troca de Óleo',         340.00, 'CONCLUIDA'),
(15, '2024-07-08', '2024-07-09', 'Revisão de Freios e Pastilhas',920.00,'CONCLUIDA'),
(15, '2024-11-15', '2024-11-16', 'Alinhamento, Balanceamento e Rodízio',430.00,'CONCLUIDA'),
(15, '2025-03-18', NULL,         'Revisão Geral 50.000 km',1850.00,'PENDENTE');

-- ============================================================
-- USUÁRIO ADMIN INICIAL (Senha: admin123)
-- Hash BCrypt gerado com bcrypt(rounds=10, prefix=2a)
-- ============================================================
INSERT INTO usuarios (nome, matricula, login, senha, perfil)
VALUES ('Administrador', 'ADM001', 'admin', '$2a$10$2DI3p8kxHYSSGc3GQKeYouC4FFeeVHWXzG593cu2qRDrlponKTMi2', 'ADMIN');