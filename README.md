# 🚀 Backend Project — Auth & Chatbot API

A production-ready Node.js/Express/MySQL backend featuring a complete
authentication system and an intelligent chatbot engine.

---

## 📁 Project Structure

```
backend-project/
├── config/
│   ├── database.js          # MySQL connection pool
│   └── passport.js          # Google & Facebook OAuth strategies
├── controllers/
│   ├── AuthController.js    # Auth request handlers
│   └── ChatController.js    # Chat request handler
├── middleware/
│   ├── auth.js              # JWT protect & optionalAuth
│   ├── errorHandler.js      # Global error & 404 handlers
│   └── rateLimiter.js       # express-rate-limit configs
├── models/
│   ├── UserModel.js         # users table queries
│   ├── PasswordResetModel.js# password_resets queries
│   └── ChatbotModel.js      # chatbot_data & chat_logs queries
├── routes/
│   ├── authRoutes.js        # /auth/* routes
│   └── chatRoutes.js        # /chat route
├── services/
│   ├── AuthService.js       # Auth business logic
│   └── ChatbotService.js    # Chatbot matching logic
├── utils/
│   ├── email.js             # Nodemailer helper
│   ├── jwt.js               # Sign & verify JWT
│   ├── logger.js            # Winston logger
│   ├── similarity.js        # Levenshtein & text scoring
│   └── validation.js        # Joi schemas + middleware
├── logs/                    # Auto-created by Winston
├── schema.sql               # Full MySQL schema + sample data
├── postman_collection.json  # Import into Postman
├── .env.example             # Copy to .env and fill in values
├── app.js                   # Express app factory
└── server.js                # Entry point (DB check + listen)
```

---

## ⚙️ Prerequisites

| Tool    | Version |
|---------|---------|
| Node.js | ≥ 18.x  |
| npm     | ≥ 9.x   |
| MySQL   | ≥ 8.x   |

---

## 🛠️ Installation

### 1 — Clone & install dependencies

```bash
git clone <your-repo-url>
cd backend-project
npm install
```

### 2 — Configure environment

```bash
cp .env.example .env
# Open .env and fill in your values (DB credentials, JWT secret, email, OAuth keys)
```

### 3 — Set up the database

```bash
# Log into MySQL
mysql -u root -p

# Inside MySQL shell:
source /path/to/backend-project/schema.sql
# OR
mysql -u root -p < schema.sql
```

### 4 — Run the server

```bash
# Development (auto-restart on file changes)
npm run dev

# Production
npm start
```

You should see:
```
✅ MySQL connection established
🚀 Server running on http://localhost:3000 [development]
```

---

## 🔑 API Reference

### Base URL
```
http://localhost:3000
```

### Authentication Header (for protected routes)
```
Authorization: Bearer <your_jwt_token>
```

---

### Auth Endpoints

| Method | Endpoint                  | Auth     | Description                    |
|--------|---------------------------|----------|--------------------------------|
| POST   | `/auth/register`          | Public   | Register with email & password |
| POST   | `/auth/login`             | Public   | Login, returns JWT             |
| GET    | `/auth/me`                | 🔒 JWT   | Get current user profile       |
| POST   | `/auth/forgot-password`   | Public   | Request password reset email   |
| POST   | `/auth/reset-password`    | Public   | Reset password with token      |
| GET    | `/auth/google`            | Public   | Start Google OAuth (browser)   |
| GET    | `/auth/facebook`          | Public   | Start Facebook OAuth (browser) |

---

### POST `/auth/register`
```json
// Request
{
  "name":     "John Doe",
  "email":    "john@example.com",
  "password": "Password1"
}

// Response 201
{
  "success": true,
  "message": "Registration successful",
  "data": {
    "user":  { "id": 1, "name": "John Doe", "email": "john@example.com" },
    "token": "eyJhbGci..."
  }
}
```

### POST `/auth/login`
```json
// Request
{ "email": "john@example.com", "password": "Password1" }

// Response 200
{
  "success": true,
  "message": "Login successful",
  "data": { "user": { ... }, "token": "eyJhbGci..." }
}
```

### POST `/auth/forgot-password`
```json
// Request
{ "email": "john@example.com" }

// Response 200
{
  "success": true,
  "message": "If that email is registered, a reset link has been sent.",
  "debug_token": "uuid-token-here"   // only in development
}
```

### POST `/auth/reset-password`
```json
// Request
{ "token": "uuid-token-here", "password": "NewPassword1" }

// Response 200
{ "success": true, "message": "Password has been reset successfully." }
```

---

### Chatbot Endpoint

| Method | Endpoint | Auth          | Description          |
|--------|----------|---------------|----------------------|
| POST   | `/chat`  | Optional JWT  | Send a chat message  |

### POST `/chat`
```json
// Request
{ "message": "What are your working hours?", "userId": 1 }

// Response 200
{
  "success":    true,
  "reply":      "Our working hours are Monday to Friday, 9 AM to 6 PM.",
  "confidence": 0.9732
}
```

**Confidence scores:**
| Range       | Meaning               |
|-------------|-----------------------|
| `1.0`       | Exact match           |
| `≥ 0.75`    | High-confidence match |
| `0.40–0.75` | Partial match (caveat added) |
| `< 0.40`    | Fallback response     |

---

## 🤖 Chatbot Matching Pipeline

```
User Input
    │
    ▼
1. Normalize (lowercase, strip punctuation, collapse spaces)
    │
    ▼
2. MySQL FULLTEXT pre-filter (fast candidate retrieval)
    │
    ▼
3. Exact match check (normalized comparison)
    │
    ▼
4. Composite scoring per candidate:
   - 40% Levenshtein similarity
   - 35% Word-overlap (Jaccard)
   - 25% Keyword overlap
    │
    ▼
5. Threshold check:
   ≥ 0.75 → return answer
   ≥ 0.40 → return answer with clarification prefix
   < 0.40 → return fallback
    │
    ▼
6. Log to chat_logs table
```

---

## 🗄️ Database Schema Overview

```
users              — id, name, email, password(hashed), provider, avatar
password_resets    — id, user_id(FK), token(UUID), expires_at, used
chatbot_data       — id, question(FULLTEXT), answer, category, keywords(FULLTEXT)
chat_logs          — id, user_id(FK,nullable), user_message, bot_reply, confidence, matched_id(FK)
```

---

## 🧪 Testing with Postman

1. Open Postman → **Import** → select `postman_collection.json`
2. The collection has a `baseUrl` variable pre-set to `http://localhost:3000`
3. **Register** or **Login** first — the test script auto-saves the token to `{{authToken}}`
4. **Forgot Password** auto-saves `debug_token` to `{{resetToken}}`
5. Run requests in order or individually

---

## 🔒 Security Features

| Feature              | Implementation                          |
|----------------------|-----------------------------------------|
| Password hashing     | bcryptjs (12 salt rounds)               |
| Authentication       | JWT (HS256, configurable expiry)        |
| Input validation     | Joi with sanitisation                   |
| Rate limiting        | express-rate-limit (per-route configs)  |
| Security headers     | Helmet.js                               |
| SQL injection        | Parameterised queries (mysql2)          |
| OAuth               | Passport.js (Google + Facebook)          |

---

## 📊 Environment Variables

| Variable                | Description                          | Default          |
|-------------------------|--------------------------------------|------------------|
| `PORT`                  | HTTP port                            | `3000`           |
| `NODE_ENV`              | Environment                          | `development`    |
| `DB_HOST/USER/PASSWORD/NAME` | MySQL credentials               | —                |
| `JWT_SECRET`            | JWT signing key                      | —                |
| `JWT_EXPIRES_IN`        | Token lifetime                       | `7d`             |
| `BCRYPT_SALT_ROUNDS`    | Hashing cost                         | `12`             |
| `EMAIL_*`               | SMTP credentials (Mailtrap/Gmail)    | —                |
| `GOOGLE_CLIENT_ID/SECRET` | Google OAuth credentials           | —                |
| `FACEBOOK_APP_ID/SECRET`  | Facebook OAuth credentials         | —                |
| `RATE_LIMIT_WINDOW_MS`  | Rate limit window (ms)               | `900000` (15min) |
| `RATE_LIMIT_MAX_REQUESTS` | Max requests per window            | `100`            |

---

## 🪵 Logging

Logs are written to:
- **Console** — colorised output in development
- `logs/combined.log` — all levels (max 5 MB × 5 files)
- `logs/error.log` — errors only

---

## 📦 Key Dependencies

| Package              | Purpose                        |
|----------------------|--------------------------------|
| `express`            | HTTP framework                 |
| `mysql2`             | MySQL driver with promise API  |
| `bcryptjs`           | Password hashing               |
| `jsonwebtoken`       | JWT sign/verify                |
| `passport`           | OAuth2 middleware              |
| `joi`                | Input validation               |
| `helmet`             | Security HTTP headers          |
| `express-rate-limit` | Rate limiting                  |
| `winston`            | Structured logging             |
| `nodemailer`         | Email sending                  |
| `uuid`               | Password reset token generation|
| `morgan`             | HTTP request logging           |

---

## 🔧 Adding Your Dataset

Replace the sample rows in `schema.sql`:

```sql
INSERT INTO chatbot_data (question, answer, category, keywords) VALUES
('Your question here', 'Your answer here', 'category', 'keyword1,keyword2,keyword3');
```

Or insert rows directly from your application or a migration script.
The chatbot **only uses `chatbot_data`** — it never hallucinate answers.

---

*Built with Node.js · Express · MySQL · JWT · Passport.js*
# backend-project_1
