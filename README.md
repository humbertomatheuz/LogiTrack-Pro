# 🚚 LogiTrack Pro

Sistema de gerenciamento de frota que centraliza controle de manutenções, viagens e análises operacionais em um painel único.

> **⚠️ Ambiente recomendado: Linux nativo.**
> Rodar em Linux (ou WSL2 com arquivos no filesystem Linux, ex: `/home/` ou `/root/`) garante hot-reload funcional, melhor performance de I/O e evita problemas com `inotify` do sistema de arquivos 9P do Windows.

---

## ✅ Pré-requisitos

- **Docker** 24+ e **Docker Compose** v2
- **Git**

---

## 🚀 Como Rodar

### Clone o repositório

```bash
git clone https://github.com/humbertomatheuz/LogiTrack-Pro.git
cd LogiTrack-Pro
```

### Produção

```bash
docker compose up --build
```

Frontend servido via Nginx com bundle de produção. O primeiro build pode demorar alguns minutos (Maven + npm).

### Desenvolvimento (Hot-Reload)

```bash
docker compose -f docker-compose.dev.yml up --build
```

Habilita Spring Boot DevTools (backend) e Vite HMR (frontend). O cache Maven é persistido entre rebuilds.

Para parar e limpar volumes:
```bash
docker compose down -v
```

---

## 🌐 Endpoints

| Serviço | URL |
|---|---|
| Frontend | http://localhost:3000 |
| API Backend | http://localhost:8080 |
| PostgreSQL | `localhost:5444` |

---

## 🔑 Credenciais Padrão

| Perfil | Login | Senha |
|---|---|---|
| `ADMIN` | `admin` | `admin123` |
| `OPERADOR` | `operador` | `operador123` |

---

## 🏗 Arquitetura

```
┌─────────────────────── logitrack_network ────────────────────┐
│  Vue 3 + Vite       /api/*      Spring Boot 4 + Java 17      │
│  (porta 3000)   ──────────►     (porta 8080)                  │
│                                      │ JDBC                   │
│                              PostgreSQL 15 (porta 5444)       │
└──────────────────────────────────────────────────────────────┘
```

### Decisões Técnicas

| Camada | Tecnologia | Justificativa |
|---|---|---|
| Backend | Spring Boot 4 + Java 17 | Ecossistema maduro, JPA nativo, segurança robusta |
| ORM | Spring Data JPA + Hibernate | Repositórios declarativos, sem SQL manual |
| Auth | Spring Security + JJWT 0.11.5 | JWT stateless, ideal para SPAs |
| Frontend | Vue 3 + Vite 8 | HMR nativo, build ultra-rápido |
| Estado | Pinia 3 | Store oficial Vue 3, API simples |
| HTTP | Axios 1.14 | Interceptors para injeção automática de JWT |
| UI | Bootstrap 5.3 | Grid responsivo + componentes prontos |
| Banco | PostgreSQL 15 | Suporte robusto a DECIMAL, TIMESTAMP, constraints |

**Auth:** O usuário faz login → backend valida com BCrypt → retorna JWT → frontend envia `Authorization: Bearer <token>` em cada requisição.

**DDL:** `validate` em produção (schema criado pelo `init.sql`), `update` em desenvolvimento.

**CORS em dev:** O Vite proxy redireciona `/api/*` para `backend:8080` internamente — sem configuração extra no browser.

---

## 🗄 Banco de Dados

O schema é inicializado automaticamente pelo `Back-end/init.sql` na primeira vez que o container sobe (volume vazio). Contém as tabelas `veiculos`, `viagens`, `manutencoes` e `usuarios`, além de dados de exemplo.

### Alterações ao Schema Original

A tabela `usuarios` foi **adicionada** ao schema existente para suportar autenticação (HU01):

| Decisão | Justificativa |
|---|---|
| Nova tabela `usuarios` | Schema original não previa autenticação; adicionada sem alterar tabelas de negócio |
| `perfil VARCHAR(20)` (sem FK) | Valores fixos (`ADMIN`, `OPERADOR`) dispensam tabela separada no MVP |
| `BIGSERIAL` em vez de `SERIAL` | Evita overflow em tabelas de alta volumetria |
| `ON DELETE CASCADE` nas FKs | Remove viagens/manutenções automaticamente ao excluir veículo |
| `DEFAULT 'PENDENTE'` em status | Garante valor inicial sem depender da aplicação |

O script completo está em [`Back-end/init.sql`](./Back-end/init.sql).

---

## 🛠 Comandos Úteis

```bash
# Logs em tempo real
docker compose logs -f [backend|frontend|db]

# Acessar o banco via psql
docker exec -it logitrack-db psql -U logi_user -d logitrack_db

# Adicionar usuários manualmente
docker exec -i logitrack-db psql -U logi_user -d logitrack_db < Back-end/add_users.sql

# Forçar reinicialização do banco
docker compose down -v && docker compose up --build
```

---

## 🔧 Troubleshooting

| Problema | Solução |
|---|---|
| Backend demora para iniciar | Aguarde `Started LogiTrackProApplication` — Maven compila na primeira vez |
| `init.sql` não executa | O volume não está vazio; rode `docker compose down -v` e suba novamente |
| Hot-reload não funciona | Certifique-se de que os arquivos estão no filesystem Linux, não em `/mnt/c/...` |
| Porta em uso | Altere `"3000:3000"` para `"3001:3000"` no docker-compose |

---

*LogiTrack Pro v1.0 — 31 de março de 2026*
