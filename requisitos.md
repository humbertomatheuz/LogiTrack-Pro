📋 Especificações de Interface: LogiTrack Pro
1. Elemento Global: Navbar
Esquerda: Nome do projeto "LogiTrack Pro" (estilo Bold/Brand).

Centro: Grupo de botões de navegação: Gerenciamento e Dashboard.

Direita: Nome do perfil do usuário logado acompanhado de um ícone de seta (dropdown).

Dropdown: Opção "Sair da conta" (Logout).

2. Tela de Autenticação (HU01)
Layout: Centralizado (Card).

Campos: Login (Texto), Senha (Password).

Ação: Botão "Entrar".

Comportamento: Exibição de alertas de erro para credenciais inválidas.

3. Módulo de Gerenciamento (HU02)
Funcionalidade: CRUD de Manutenções.

Formulário: Select de Veículos, Data Início, Data Finalização, Tipo de Serviço, Custo Estimado e Status (Select: PENDENTE, EM_REALIZACAO, CONCLUIDA).

Tabela: Listagem com botões de "Editar" e "Excluir".

Regra UI: O botão "Excluir" deve ficar oculto para o perfil OPERADOR.

4. Módulo Dashboard: Estrutura de Abas (HU03)
Navegação: Sistema de 5 abas (Tabs) utilizando Bootstrap 5.

Persistência: Os filtros aplicados em uma aba devem ser mantidos ao alternar entre elas.

Aba 01: Total de KM Percorrido (HU04 e HU09)
Topo: Filtros (Autocomplete Placa, Select Tipo, Range de Data) + Botão Filtrar.

Cards: 2 Cards fixos (KM Total da Frota | KM Filtrado).

Grid: 10 itens por página, ordenação padrão KM DESC.

Ação: Ícone de "Olho" que abre o Modal de Detalhamento (HU09).

HU09 (Modal): Tabela com Data Saída, Data Chegada, Origem, Destino, KM. (Ordenação via front-end).

Aba 02: Volume por Categoria (HU05)
Topo: Filtros (Data Início, Data Fim) + Botão Filtrar.

Layout: 2 Cards Grandes fixos (Total Leve | Total Pesado). No-interactive (fixos).

Aba 03: Cronograma de Manutenção (HU06)
Grid: Colunas (Placa, Modelo, Serviço, Custo, Início, Fim, Status).

Ordenação Fixa: 1º Pendente, 2º Em Realização, 3º Concluída.

Botão: "Carregar Mais" (Lógica: +10 itens. Some se < 10 no último lote ou < 5 no primeiro).

Aba 04: Ranking de Utilização (HU07)
Topo: Filtros de Data + Botão Filtrar.

Grid: Colunas (Placa, Modelo, Tipo, Ano, KM Percorrida).

Ordenação Fixa: KM DESC (Maior para menor).

Botão: "Carregar Mais" (Mesma lógica da HU06).

Aba 05: Projeção Financeira (HU08)
Topo: Filtros de Data + Botão Filtrar.

Gráfico: Gráfico de Rosca (Doughnut) com valor total monetário centralizado.

Interação: Hover mostra valor em R$, fatias mostram %.

Regra UI: Bloqueio visual total para perfil OPERADOR.