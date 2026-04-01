# LogiTrack Pro - Docker Compose

Docker Compose para orquestração completa da aplicação LogiTrack Pro (Frontend + Backend + Database).

## Estrutura

```
LogiTrack Pro/
├── docker-compose.yml          (Orquestração completa)
├── Back-end/
│   ├── Dockerfile
│   ├── docker-compose.yml      (Backend isolado)
│   └── ...
├── Front-end/
│   ├── Dockerfile
│   ├── nginx.conf
│   └── ...
└── Docs/
```

## Iniciar Aplicação Completa

```bash
cd "c:\Users\humbe\Documents\LogiTrack Pro"
docker-compose up -d
```

## Acessar Serviços

- **Frontend**: http://localhost:3000
- **Backend**: http://localhost:8080
- **PostgreSQL**: localhost:5444

## Parar Aplicação

```bash
docker-compose down
```

## Remover Tudo (incluindo volumes)

```bash
docker-compose down -v
```

## Logs

Ver logs de todos os serviços:
```bash
docker-compose logs -f
```

Ver logs de um serviço específico:
```bash
docker-compose logs -f frontend
docker-compose logs -f backend
docker-compose logs -f db
```

## Credenciais Padrão

**Banco de Dados PostgreSQL:**
- Usuário: `logi_user`
- Senha: `logi_password`
- Database: `logitrack_db`
- Porta: `5444`

**Login da Aplicação:**
- Login: `admin`
- Senha: `admin123`
- Perfil: `ADMIN`

## Health Checks

**Frontend:**
```bash
curl http://localhost:3000/health
```

**Backend:**
```bash
curl http://localhost:8080/api/debug/config
```

**Banco de Dados:**
```bash
docker exec logitrack-db pg_isready -U logi_user -d logitrack_db
```

## Variáveis de Ambiente

### Backend (docker-compose.yml)

- `SPRING_DATASOURCE_URL`: URL de conexão com PostgreSQL
- `SPRING_DATASOURCE_USERNAME`: Usuário do banco
- `SPRING_DATASOURCE_PASSWORD`: Senha do banco
- `JWT_SECRET`: Chave para assinatura de JWT
- `JWT_EXPIRATION`: Expiração do token em ms

### Frontend (docker-compose.yml)

- `VITE_API_URL`: URL do backend (http://localhost:8080)

## Rede Interna

Os serviços se comunicam através da rede bridge `logitrack_network`:

- Backend acessa banco como `db:5432` (não localhost)
- Frontend acessa backend como `backend:8080` (não localhost)

## Troubleshooting

### Porta 3000 já está em uso

```bash
# Mudar a porta no docker-compose.yml
# Alterar "3000:3000" para "3001:3000" por exemplo
```

### Backend não conecta no banco

```bash
# Verificar se o banco está healthy
docker-compose ps

# Ver logs do backend
docker-compose logs -f backend
```

### Frontend não consegue conectar ao backend

Verificar se `VITE_API_URL` está correto e acessível de dentro do container.

## Para Desenvolvimento

Se quiser usar apenas backend com Vite em dev mode:

```bash
cd Back-end
docker-compose up -d

cd ../Front-end
npm install
npm run dev  # Vite com hot reload na porta 5173
```

Depois configurar a URL do API no frontend para `http://localhost:8080`.
