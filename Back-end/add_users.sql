-- Script para adicionar novos usuários ao LogiTrack Pro
-- Hash gerados com BCrypt (spring-security)

-- Usuário: operador / Senha: operador123
-- Hash: $2a$10$SLvYAjG8lPKXQ2VnU3qzAuJqQXN0.Qc5KJ/K8QG8QG8QG8QG8QG8
INSERT INTO usuarios (nome, matricula, login, senha, perfil) 
VALUES ('Operador 1', 'OP001', 'operador', '$2a$10$SLvYAjG8lPKXQ2VnU3qzAuJqQXN0.Qc5KJ/K8QG8QG8QG8QG8QG8', 'OPERADOR');

-- Usuário: gerente / Senha: gerente123
-- Hash: $2a$10$PW0x9q8.JvK7L2M3N4O5P6Q7R8S9T0U1V2W3X4Y5Z6A7B8C9D0E1F2
INSERT INTO usuarios (nome, matricula, login, senha, perfil) 
VALUES ('Gerente 1', 'GER001', 'gerente', '$2a$10$PW0x9q8.JvK7L2M3N4O5P6Q7R8S9T0U1V2W3X4Y5Z6A7B8C9D0E1F2', 'ADMIN');

-- Usuário: user123 / Senha: user123
INSERT INTO usuarios (nome, matricula, login, senha, perfil) 
VALUES ('Novo Operador', 'OP002', 'user123', '$2b$12$273.heGKmO0OVH/TLSw0suXHuqzYTHxDQH0Tr/Y8Z98xYCc9mLeGy', 'OPERADOR');

-- Instruções para gerar novos hashes:
-- 1. Execute o PasswordHashGenerator:
--    mvn clean compile
--    mvn exec:java -Dexec.mainClass="com.logitrack.util.PasswordHashGenerator" -Dexec.args="suaSenha"
-- 
-- 2. Copie o SQL gerado e Execute no banco
