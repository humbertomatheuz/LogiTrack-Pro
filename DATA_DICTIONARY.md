# Dicionário de Dados: LogiTrack Pro

Este documento descreve o esquema do banco de dados do LogiTrack Pro MVP. Inclui as tabelas originais para gerenciamento de frota e operações, bem como a tabela personalizada para autenticação e controle de acesso.

---

## 1. Tabela: `usuarios` (Usuários)

Armazena credenciais e informações funcionais de funcionários, utilizada para autenticação e Controle de Acesso Baseado em Função (RBAC).

| Coluna | Tipo | Restrições | Descrição |
|--------|------|-------------|-------------|
| `id` | SERIAL | Chave Primária | Identificador único do usuário. |
| `nome` | VARCHAR(100) | Obrigatório | Nome completo do funcionário. |
| `matricula` | VARCHAR(20) | Único, Obrigatório | ID funcional usado para trilhas de auditoria e conformidade. |
| `login` | VARCHAR(50) | Único, Obrigatório | Nome de usuário usado para acesso ao sistema. |
| `senha` | VARCHAR(255) | Obrigatório | Senha armazenada como hash BCrypt seguro. |
| `perfil` | VARCHAR(20) | Obrigatório | Função do usuário; define o nível de acesso ('ADMIN' ou 'OPERADOR'). |

---

## 2. Tabela: `veiculos` (Veículos)

Armazena informações principais sobre a frota LogiTrack.

| Coluna | Tipo | Restrições | Descrição |
|--------|------|-------------|-------------|
| `id` | SERIAL | Chave Primária | Identificador único do veículo. |
| `placa` | VARCHAR(10) | Único, Obrigatório | Placa de licença do veículo. |
| `modelo` | VARCHAR(50) | Obrigatório | Modelo do veículo (ex: Fiorino, Volvo FH). |
| `tipo` | VARCHAR(20) | Restrição de Verificação | Categoria do veículo; deve ser 'LEVE' ou 'PESADO'. |
| `ano` | INTEGER | Opcional | Ano de fabricação. |

---

## 3. Tabela: `viagens` (Viagens)

Registra dados históricos e operacionais de viagens para alimentar o painel de análises.

| Coluna | Tipo | Restrições | Descrição |
|--------|------|-------------|-------------|
| `id` | SERIAL | Chave Primária | Identificador único do registro de viagem. |
| `veiculo_id` | INTEGER | Chave Estrangeira | Referência à tabela `veiculos`. |
| `data_saida` | TIMESTAMP | Obrigatório | Data e hora de saída. |
| `data_chegada` | TIMESTAMP | Opcional | Data e hora de chegada. |
| `origem` | VARCHAR(100) | Opcional | Cidade de origem. |
| `destino` | VARCHAR(100) | Opcional | Cidade de destino. |
| `km_percorrida` | DECIMAL(10,2) | Opcional | Quilômetros percorridos durante a viagem. |

---

## 4. Tabela: `manutencoes` (Manutenções)

Gerencia o ciclo de vida de reparos de veículos e agendamento de serviços.

| Coluna | Tipo | Restrições | Descrição |
|--------|------|-------------|-------------|
| `id` | SERIAL | Chave Primária | Identificador único do registro de manutenção. |
| `veiculo_id` | INTEGER | Chave Estrangeira | Referência à tabela `veiculos`. |
| `data_inicio` | DATE | Obrigatório | Data de início do serviço. |
| `data_finalizacao` | DATE | Opcional | Data de conclusão esperada ou real. |
| `tipo_servico` | VARCHAR(100) | Opcional | Descrição do serviço (ex: Troca de Óleo, Revisão de Freios). |
| `custo_estimado` | DECIMAL(10,2) | Opcional | Custo estimado da manutenção. |
| `status` | VARCHAR(20) | Padrão: 'PENDENTE' | Estado atual do serviço; inclui 'PENDENTE', 'EM_REALIZACAO' ou 'CONCLUIDA'. |

---

## 5. Dados de Inicialização (Carga Inicial)

O banco de dados é inicializado com dados de exemplo para garantir funcionalidade imediata do painel:

### Veículos
- Mistura de veículos Leves e Pesados (Fiorino, Volvo FH, Sprinter, Scania)

### Viagens
- Rotas de exemplo entre cidades principais (SP, RJ, Curitiba, BH) para testar cálculos de km

### Manutenções
- Casos de teste para serviços pendentes e concluídos para validar o cronograma e projeções financeiras

---

**Última Atualização:** 31 de março de 2026  
**Versão:** 1.0
