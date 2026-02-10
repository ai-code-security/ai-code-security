# Vulnerable vs Secure: AI-Generated Code Patterns

Real examples of security flaws commonly introduced by AI coding assistants, with their secure alternatives.

---

## 1. SQL Injection

### ❌ Vulnerable (AI often generates this)

```javascript
// "Build a search endpoint"
app.get('/api/search', async (req, res) => {
  const { query } = req.query;
  const results = await db.query(
    `SELECT * FROM products WHERE name LIKE '%${query}%'`
  );
  res.json(results);
});
```

**What's wrong:** User input directly concatenated into SQL. An attacker can input `'; DROP TABLE products; --` and destroy your database.

### ✅ Secure

```javascript
app.get('/api/search', async (req, res) => {
  const { query } = req.query;
  const results = await db.query(
    'SELECT * FROM products WHERE name LIKE $1',
    [`%${query}%`]
  );
  res.json(results);
});
```

**Why it's safe:** Parameterized query. The database treats `$1` as data, not code.

---

## 2. Hardcoded Secrets

### ❌ Vulnerable (AI often generates this)

```javascript
// "Add Stripe payment processing"
const stripe = require('stripe')('sk_live_abc123xyz789');

app.post('/api/charge', async (req, res) => {
  const charge = await stripe.charges.create({
    amount: req.body.amount,
    currency: 'usd',
    source: req.body.token
  });
  res.json(charge);
});
```

**What's wrong:** Live API key in source code. Once pushed to GitHub, it's compromised within minutes (bots scan for these).

### ✅ Secure

```javascript
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);

app.post('/api/charge', async (req, res) => {
  if (!process.env.STRIPE_SECRET_KEY) {
    console.error('STRIPE_SECRET_KEY not configured');
    return res.status(500).json({ error: 'Payment not configured' });
  }
  
  const charge = await stripe.charges.create({
    amount: req.body.amount,
    currency: 'usd',
    source: req.body.token
  });
  res.json(charge);
});
```

**Why it's safe:** Secret loaded from environment variable. Never touches source control.

---

## 3. Missing Authentication

### ❌ Vulnerable (AI often generates this)

```javascript
// "Create an endpoint to update user profile"
app.put('/api/users/:id', async (req, res) => {
  const { id } = req.params;
  const { name, email } = req.body;
  
  await db.query(
    'UPDATE users SET name = $1, email = $2 WHERE id = $3',
    [name, email, id]
  );
  
  res.json({ success: true });
});
```

**What's wrong:** No authentication check. Anyone can update any user's profile by guessing IDs.

### ✅ Secure

```javascript
app.put('/api/users/:id', requireAuth, async (req, res) => {
  const { id } = req.params;
  const { name, email } = req.body;
  
  // Verify user can only update their own profile
  if (req.user.id !== id && !req.user.isAdmin) {
    return res.status(403).json({ error: 'Forbidden' });
  }
  
  await db.query(
    'UPDATE users SET name = $1, email = $2 WHERE id = $3',
    [name, email, id]
  );
  
  res.json({ success: true });
});
```

**Why it's safe:** Authentication middleware + authorization check. Users can only modify their own data.

---

## 4. Exposed Stack Traces

### ❌ Vulnerable (AI often generates this)

```javascript
// "Add error handling"
app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({
    error: err.message,
    stack: err.stack,
    details: err
  });
});
```

**What's wrong:** Exposes internal file paths, dependency versions, and code structure to attackers.

### ✅ Secure

```javascript
app.use((err, req, res, next) => {
  // Log full error internally
  console.error({
    message: err.message,
    stack: err.stack,
    url: req.url,
    method: req.method,
    timestamp: new Date().toISOString()
  });
  
  // Return generic message to user
  res.status(500).json({
    error: 'An unexpected error occurred',
    code: 'INTERNAL_ERROR',
    requestId: req.id // For support reference
  });
});
```

**Why it's safe:** Detailed logs stay server-side. Users get safe, generic responses.

---

## 5. Predictable Session Tokens

### ❌ Vulnerable (AI often generates this)

```javascript
// "Generate a session token"
function createSession(userId) {
  const token = userId + '-' + Date.now();
  sessions[token] = { userId, created: Date.now() };
  return token;
}
```

**What's wrong:** Token is predictable. If I know your user ID and approximate login time, I can guess your session.

### ✅ Secure

```javascript
const crypto = require('crypto');

function createSession(userId) {
  const token = crypto.randomBytes(32).toString('hex');
  sessions[token] = { 
    userId, 
    created: Date.now(),
    expires: Date.now() + (24 * 60 * 60 * 1000) // 24 hours
  };
  return token;
}
```

**Why it's safe:** Cryptographically random token. 256 bits of entropy = unguessable.

---

## 6. Cross-Site Scripting (XSS)

### ❌ Vulnerable (AI often generates this)

```javascript
// "Display user comments"
app.get('/comments', async (req, res) => {
  const comments = await db.query('SELECT * FROM comments');
  
  let html = '<div class="comments">';
  comments.forEach(c => {
    html += `<div class="comment">
      <strong>${c.author}</strong>: ${c.text}
    </div>`;
  });
  html += '</div>';
  
  res.send(html);
});
```

**What's wrong:** User content rendered as HTML. An attacker can post `<script>stealCookies()</script>` as a comment.

### ✅ Secure

```javascript
const escapeHtml = require('escape-html');

app.get('/comments', async (req, res) => {
  const comments = await db.query('SELECT * FROM comments');
  
  let html = '<div class="comments">';
  comments.forEach(c => {
    html += `<div class="comment">
      <strong>${escapeHtml(c.author)}</strong>: ${escapeHtml(c.text)}
    </div>`;
  });
  html += '</div>';
  
  res.send(html);
});
```

**Why it's safe:** HTML entities escaped. `<script>` becomes `&lt;script&gt;` and displays as text, not code.

---

## 7. Missing Rate Limiting

### ❌ Vulnerable (AI often generates this)

```javascript
// "Create a login endpoint"
app.post('/api/login', async (req, res) => {
  const { email, password } = req.body;
  const user = await db.query('SELECT * FROM users WHERE email = $1', [email]);
  
  if (user && await bcrypt.compare(password, user.password)) {
    const token = generateToken(user.id);
    res.json({ token });
  } else {
    res.status(401).json({ error: 'Invalid credentials' });
  }
});
```

**What's wrong:** No rate limiting. Attackers can try millions of passwords per hour.

### ✅ Secure

```javascript
const rateLimit = require('express-rate-limit');

const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // 5 attempts per window
  message: { error: 'Too many login attempts, try again later' },
  standardHeaders: true,
  legacyHeaders: false,
});

app.post('/api/login', loginLimiter, async (req, res) => {
  const { email, password } = req.body;
  const user = await db.query('SELECT * FROM users WHERE email = $1', [email]);
  
  if (user && await bcrypt.compare(password, user.password)) {
    const token = generateToken(user.id);
    res.json({ token });
  } else {
    // Same delay for valid/invalid users (timing attack prevention)
    await new Promise(r => setTimeout(r, 100));
    res.status(401).json({ error: 'Invalid credentials' });
  }
});
```

**Why it's safe:** 5 attempts per 15 minutes makes brute force impractical. Constant-time response prevents user enumeration.

---

## 8. Disabled RLS (Supabase/PostgreSQL)

### ❌ Vulnerable (AI often generates this)

```sql
-- "Fix: query not returning data"
ALTER TABLE documents DISABLE ROW LEVEL SECURITY;

-- or in application code:
const { data } = await supabase
  .from('documents')
  .select('*')
  .eq('id', documentId);
```

**What's wrong:** RLS disabled means any authenticated user can access ALL documents, not just their own.

### ✅ Secure

```sql
-- Keep RLS enabled
ALTER TABLE documents ENABLE ROW LEVEL SECURITY;

-- Create proper policy
CREATE POLICY "Users can only access their own documents"
ON documents FOR ALL
USING (auth.uid() = user_id);
```

```javascript
// Query works the same, but RLS filters automatically
const { data } = await supabase
  .from('documents')
  .select('*')
  .eq('id', documentId);
// Only returns the document if user_id matches current user
```

**Why it's safe:** Database enforces access control. Even if application code has bugs, data stays protected.

---

## Key Takeaways

1. **AI optimizes for "working"** — not "secure"
2. **Always validate AI-generated code** against these patterns
3. **Use the SAFE Stack Guardian Prompt** to catch issues during generation
4. **Run the Pre-Launch Checklist** before deploying

---

## Learn More

- [SAFE Stack Framework](https://safestacklabs.com)
- [Guardian Prompt](../prompts/GUARDIAN_PROMPT.txt)
- [Pre-Launch Checklist](../checklists/pre-launch-lite.md)
