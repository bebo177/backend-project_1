# 🚗 Backend + Python Chatbot — التشغيل من الصفر

ده الـbackend بتاعك متربوط بالـPython chatbot. كل اللي محتاج تعمله:

---

## مرة واحدة بس (Setup)

### 1. نزّل dependencies الـbackend

في الـterminal جوه folder الـ`backend-project`:

```bash
npm install
```

### 2. اعمل الـdatabase

في MySQL:

```bash
mysql -u root -p < schema.sql
```

أو افتح `schema.sql` في MySQL Workbench واضغط Run.

### 3. الـ.env جاهز

الملف `.env` فيه كل الـvalues اللي عندك + السطرين الجداد بتاع الـPython bot. متلمسهوش غير لو هتغيّر DB password أو حاجة.

---

## كل مرة تشتغل (Daily)

محتاج **2 terminals** شغّالين في نفس الوقت.

### Terminal 1 — الـPython bot

```bash
cd ~/Downloads/chatbot
source .venv/bin/activate
uvicorn server:app --reload --port 8000
```

لازم تشوف:
```
INFO: Uvicorn running on http://127.0.0.1:8000
```

### Terminal 2 — الـExpress backend

```bash
cd path/to/backend-project
npm run dev
```

لازم تشوف:
```
✅ MySQL connection established
🚀 Server running on http://localhost:3000
```

---

## جرّب إنه شغال

من terminal تالت، أو من Postman، ابعت:

```bash
curl -X POST http://localhost:3000/chat \
  -H 'Content-Type: application/json' \
  -d '{"message":"العربية بتسخن في الزحمة"}'
```

لازم ترجع رد بالعربي زي:
```json
{
  "success": true,
  "reply": "يلا نشوف. شكله عطل في مروحة الراديتر (Cooling)...",
  "confidence": 0.85
}
```

ابعت رد للسؤال:
```bash
curl -X POST http://localhost:3000/chat \
  -H 'Content-Type: application/json' \
  -d '{"message":"أيوه"}'
```

الـPython bot هيفتكر إنك في نص تشخيص (لأن الـsession_id ثابت من نفس الـIP) ويسألك السؤال التاني.

---

## إيه اللي بيحصل في الـbackground

```
Client → POST /chat → Express :3000
                          │
                          ├─ auth check
                          ├─ rate limit check
                          ├─ POST /chat → Python :8000
                          │                   │
                          │                   ├─ match symptoms
                          │                   ├─ run state machine
                          │                   └─ return Arabic reply
                          │
                          ├─ log to MySQL chat_logs
                          └─ return { reply, confidence }
```

الـExpress بيعمل:
- ✅ Authentication
- ✅ Rate limiting
- ✅ MySQL logging
- ✅ Validation
- ✅ Error handling

الـPython bot بيعمل:
- ✅ Arabic text normalization
- ✅ Fuzzy matching على الـ14 fault
- ✅ State machine (greeting → choosing → diagnosing → done)
- ✅ Bilingual (عربي/إنجليزي)
- ✅ Diagnostic question loop

---

## مشاكل شائعة

**`bash: pip: command not found`** — انت مش جوه الـvenv. اعمل `source .venv/bin/activate` الأول.

**`ECONNREFUSED 127.0.0.1:8000`** — الـPython bot مش شغّال. شغّله في Terminal 1.

**`Failed to start server: ECONNREFUSED ...:3306`** — MySQL مش شغّال أو الـcredentials في `.env` غلط.

**الـreply راجع باللغة الإنجليزية** — تأكد إن الـ`ChatbotService.js` هو الجديد (يـimport fetch مش بيستخدم similarity utils).

**`Cannot find module './app'`** — الـ`app.js` مش موجود في root. اتأكد إنه في نفس مكان `server.js`.

---

## الـfiles اللي اتعدّلت/اتضافت

- ✨ **جديد:** `app.js` — Express bootstrap كان مفقود
- 🔄 **اتعدّل:** `services/ChatbotService.js` — بقى proxy للـPython
- 🔄 **اتعدّل:** `.env` — اتضافله سطرين للـPython bot
- ✅ **زي ما هو:** كل باقي الـbackend

ده اللي خلّى الـintegration بسيط — مش لازم نلمس auth, routes, middleware, أو DB models.
