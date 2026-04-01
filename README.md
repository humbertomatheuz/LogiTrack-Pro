# 🚚 LogiTrack Pro

Sistema de gerenciamento de frota que centraliza controle de manutenções, viagens e análises operacionais em um painel único.

---

## 🌍 Live Demo (Produção)

| Componente | Link | Status |
|---|---|---|
| **Frontend (Web)** | [https://logitrack-pro-7gm.pages.dev](https://logitrack-pro-7gm.pages.dev) | **Live** |
| **Backend (API)** | [https://logitrack-pro-xckv.onrender.com](https://logitrack-pro-xckv.onrender.com) | **Ativo** |

> **⚠️ Importante sobre o Acesso:**
> O Back-end está hospedado no plano gratuito do **Render**. Se o sistema não for acessado por um tempo, o servidor "dorme". Ao abrir o site pela primeira vez, pode haver um **atraso de 30 a 60 segundos** para o backend "acordar" e carregar os dados.

---

## ✅ Pré-requisitos (Local)

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

### Local (Docker)
| Serviço | URL |
|---|---|
| Frontend | http://localhost:3000 |
| API Backend | http://localhost:8080 |
| PostgreSQL | `localhost:5444` |

### Nuvem (Produção)
| Serviço | URL | Hospedagem |
|---|---|---|
| Frontend | [logitrack-pro-7gm.pages.dev](https://logitrack-pro-7gm.pages.dev) | Cloudflare Pages |
| API Backend | [logitrack-pro-xckv.onrender.com](https://logitrack-pro-xckv.onrender.com) | Render |
| Base de Dados | Managed PostgreSQL | Render |

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
│  (porta 3000)   ──────────►     (porta 8080)                 │
│                                      │ JDBC                  │
│                              PostgreSQL 15 (porta 5444)      │
└──────────────────────────────────────────────────────────────┘
```

### Decisões Técnicas

| Camada | Tecnologia | Justificativa |
|---|---|---|
| Backend | Spring Boot 3 + Java 17 | Ecossistema maduro, JPA nativo, segurança robusta |
| Relatórios (HU03/04) | SQL Nativo (@Query) | Performance superior e conformidade com requisitos de extração direta via SQL |
| Paginação (HU04) | SQL Offset/Limit | Paginação feita no banco para evitar transferência desnecessária de dados |
| Auth | Spring Security + JJWT 0.11.5 | JWT stateless, ideal para SPAs |
| Segurança (RBAC) | PreAuthorize (ADMIN) | Dashboard e APIs financeiras restritas apenas para perfil Administrador |
| Frontend | Vue 3 + Vite 5 | HMR nativo, build ultra-rápido |
| Estado | Pinia 2 | Store oficial Vue 3, API simples |
| UI | Bootstrap 5.3 | Grid responsivo + componentes prontos com estética premium |
| Banco | PostgreSQL 15 | Suporte robusto a DECIMAL, TIMESTAMP e constraints |

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

## ☁️ Deploy na Nuvem (Detalhes)

### Back-end (Render)
- **Tecnologia:** Docker (Multi-stage build).
- **Banco:** Managed PostgreSQL do Render.
- **Configuração:** O arquivo [`render.yaml`](./render.yaml) define o Blueprint para deploy automático.
- **Variáveis de Ambiente:** `SPRING_DATASOURCE_URL` (com prefixo `jdbc:`), `JWT_SECRET` e `SPRING_JPA_HIBERNATE_DDL_AUTO=update`.

### Front-end (Cloudflare Pages)
- **Tecnologia:** Static Site (Assets compilados via Vite).
- **Integração:** Conectado via Git. Variável `VITE_API_URL` aponta para a URL do Render.

---

*LogiTrack Pro v1.1 — 01 de abril de 2026*
