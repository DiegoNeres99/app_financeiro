# App Financeiro

Aplicativo financeiro completo com backend NestJS e frontend Flutter, com controle de rendas, despesas, cartões, criptomoedas e dashboard interativo.

---

## Estrutura do Projeto

```
app_financeiro/
├── api/          # Backend NestJS + MySQL
└── mobile/       # Frontend Flutter
```

---

## Pré-requisitos

| Ferramenta | Versão mínima |
|------------|--------------|
| Node.js    | 18+          |
| npm        | 9+           |
| MySQL      | 8+           |
| Flutter    | 3.x          |
| Dart       | 3.x          |

---

## Backend (API)

### 1. Instalar dependências

```bash
cd api
npm install

npm install @nestjs/mapped-types

npm run build
```

### 2. Configurar variáveis de ambiente

Crie o arquivo `api/.env`:

```env
# Banco de dados
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=sua_senha
DB_NAME=app_financeiro

# JWT
JWT_SECRET=sua_chave_secreta_muito_forte_aqui
JWT_EXPIRES_IN=7d

# Servidor
PORT=3000
NODE_ENV=development
```

### 3. Criar o banco de dados

```sql
CREATE DATABASE app_financeiro CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

### 4. Executar migrations

```bash
npm run migrate
```

Isso criará as tabelas:
- `users`
- `password_reset_tokens`
- `categories`
- `payment_methods`
- `incomes`
- `expenses`
- `cards`
- `cryptocurrencies`

### 5. Popular dados iniciais (seed)

```bash
npm run seed
```

Cria:
- Usuário admin: `admin@sistema.com` / `admin123`
- 15 categorias padrão (despesas e rendas)
- 3 métodos de pagamento (Dinheiro, PIX, Transferência)

### 6. Iniciar o servidor

```bash
# Desenvolvimento (hot-reload)
npm run start:dev

```

O servidor estará disponível em: `http://localhost:3000`

---

## Endpoints da API

Base URL: `http://localhost:3000/api/v1`

### Autenticação

| Método | Rota | Descrição |
|--------|------|-----------|
| POST | `/auth/register` | Cadastrar usuário |
| POST | `/auth/login` | Login |
| POST | `/auth/forgot-password` | Solicitar reset de senha |
| POST | `/auth/reset-password` | Redefinir senha com token |

### Usuário (requer JWT)

| Método | Rota | Descrição |
|--------|------|-----------|
| GET | `/users/me` | Dados do perfil |
| PATCH | `/users/me` | Atualizar perfil |
| PATCH | `/users/me/change-password` | Alterar senha |

### Dashboard (requer JWT)

| Método | Rota | Descrição |
|--------|------|-----------|
| GET | `/dashboard?month=&year=` | Resumo financeiro completo |
| GET | `/dashboard/expenses-by-category` | Despesas por categoria |
| GET | `/dashboard/last-6-months` | Evolução dos últimos 6 meses |
| GET | `/dashboard/upcoming-expenses?days=7` | Próximas despesas a vencer |
| GET | `/dashboard/movement-history` | Histórico de movimentações |

### Rendas, Despesas, Cartões, Criptomoedas, Categorias, Métodos de Pagamento

Todos seguem padrão REST:

```
GET    /[recurso]         → Listar
POST   /[recurso]         → Criar
GET    /[recurso]/:id     → Buscar por ID
PUT    /[recurso]/:id     → Atualizar
DELETE /[recurso]/:id     → Excluir
```

Recursos disponíveis: `incomes`, `expenses`, `cards`, `cryptocurrencies`, `categories`, `payment-methods`

Endpoint especial: `PATCH /expenses/:id/pay` — marca despesa como paga

---

## Mobile (Flutter)

### 1. Instalar dependências

```bash
cd mobile
flutter pub get
```

### 2. Configurar URL da API

Edite `mobile/lib/config/app_config.dart`:

```dart
// Emulador Android → usa 10.0.2.2 para localhost do computador
static const String baseUrl = 'http://10.0.2.2:3000/api/v1';

// Dispositivo físico → use o IP da sua rede local
// static const String baseUrl = 'http://192.168.1.100:3000/api/v1';
```

### 3. Executar o app

```bash
flutter run
```

### 4. Gerar APK de release

```bash
flutter build apk --release
```

---

## Funcionalidades

### Dashboard
- Resumo financeiro mensal (renda, despesas pagas/pendentes/atrasadas)
- Saldo do mês
- Gráfico de despesas por categoria (pizza)
- Indicador de uso dos cartões de crédito
- Portfólio de criptomoedas com lucro/prejuízo
- Próximas contas a vencer (7 dias)

### Rendas
- CRUD completo
- Tipos: salário, freelance, investimento, aluguel, outros
- Filtros por mês/ano e tipo
- Categorização opcional
- Marcação de recorrência

### Despesas
- CRUD completo
- Filtros por mês/ano e status (pendente/pago/atrasado)
- Marcar como paga
- Vínculo com categoria e método de pagamento
- Marcação de recorrência

### Cartões de Crédito
- CRUD completo
- Controle de limite total e utilizado
- Barra de progresso de uso
- Dias de vencimento, fechamento e melhor dia de compra

### Criptomoedas
- CRUD completo
- Portfólio com total investido, valor atual e lucro/prejuízo
- Suporte a múltiplas exchanges

### Perfil
- Edição de nome
- Alteração de senha
- Gerenciamento de métodos de pagamento
- Logout

---

## Credenciais padrão (seed)

| Campo | Valor |
|-------|-------|
| E-mail | admin@sistema.com |
| Senha | admin123 |

---

## Segurança

- Senhas com bcrypt (12 rounds)
- JWT com expiração configurável
- Rate limiting nos endpoints sensíveis (login, forgot-password)
- Validação de DTOs com class-validator
- Guard global JWT (rotas públicas marcadas com `@Public()`)
- Token de reset com expiração de 2h e uso único

---

## Tecnologias

### Backend
- **NestJS 10** — framework Node.js
- **MySQL2** — driver MySQL com connection pool
- **bcrypt** — hash de senhas
- **@nestjs/jwt + passport-jwt** — autenticação JWT
- **class-validator** — validação de DTOs
- **@nestjs/throttler** — rate limiting
- **uuid** — tokens de reset de senha

### Frontend
- **Flutter 3** — framework mobile
- **Dio** — cliente HTTP com interceptors
- **flutter_secure_storage** — armazenamento seguro do token
- **fl_chart** — gráficos
- **flutter_riverpod** — gerenciamento de estado
- **flutter_easyloading** — indicadores de carregamento
- **mask_text_input_formatter** — máscara de campos
- **intl** — formatação de moeda e datas (pt-BR)
