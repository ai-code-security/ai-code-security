# Pre-Launch Security Checklist (Lite)

A 10-point security checklist for founders deploying AI-generated code to production.

**Time to complete**: 15-30 minutes  
**When to use**: Before every production deployment

---

## The Checklist

### 1. Secrets Scan

**Goal**: Ensure no API keys, passwords, or tokens are committed to your repository.

```bash
# Using git-secrets (install first: brew install git-secrets)
git secrets --scan

# Or using gitleaks
gitleaks detect --source . --verbose

# Or manual grep for common patterns
grep -rE "(sk_live|pk_live|AKIA|password\s*=|api_key\s*=)" --include="*.js" --include="*.ts" --include="*.py" --include="*.env*" .
```

**Pass criteria**:
- [ ] No secrets in source code
- [ ] No secrets in git history
- [ ] `.env` files are in `.gitignore`
- [ ] Example env file uses placeholder values only

**If you find secrets**: Rotate them immediately. Assume they're compromised.

---

### 2. Database RLS Verification

**Goal**: Confirm Row-Level Security is enabled and policies are active.

```sql
-- For Supabase/PostgreSQL: Check RLS status
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public';

-- Verify policies exist
SELECT tablename, policyname, cmd, qual 
FROM pg_policies 
WHERE schemaname = 'public';
```

**Pass criteria**:
- [ ] RLS enabled on all tables containing user data
- [ ] Policies exist for SELECT, INSERT, UPDATE, DELETE as appropriate
- [ ] No tables accessible without authentication (unless intentionally public)
- [ ] Tested with different user contexts to verify isolation

---

### 3. SQL Injection Check

**Goal**: Verify all database queries use parameterized statements.

**Search for dangerous patterns**:

```bash
# JavaScript/TypeScript
grep -rE "query\s*\(\s*['\`\"].*\$\{" --include="*.js" --include="*.ts" .
grep -rE "execute\s*\(\s*['\`\"].*\+" --include="*.js" --include="*.ts" .

# Python
grep -rE "execute\s*\(\s*['\"].*%" --include="*.py" .
grep -rE "execute\s*\(\s*f['\"]" --include="*.py" .
```

**Pass criteria**:
- [ ] No string concatenation in SQL queries
- [ ] No template literals with user input in queries
- [ ] All queries use parameterized statements (`$1, $2` or `?, ?`)
- [ ] ORM queries don't use raw SQL with user input

---

### 4. Authentication Middleware Audit

**Goal**: Confirm all protected routes have authentication checks.

**Manual review required**:

```bash
# List all route definitions
grep -rE "(app\.(get|post|put|delete|patch)|router\.(get|post|put|delete|patch))" --include="*.js" --include="*.ts" .

# Check for auth middleware
grep -rE "(requireAuth|isAuthenticated|protect|auth)" --include="*.js" --include="*.ts" .
```

**Pass criteria**:
- [ ] All `/api/*` routes (except public ones) have auth middleware
- [ ] Auth middleware runs before route handlers
- [ ] Failed auth returns 401, not 500
- [ ] No routes accidentally exposed during development

---

### 5. HTTPS Enforcement

**Goal**: Ensure all traffic is encrypted.

**Pass criteria**:
- [ ] Production URL uses `https://`
- [ ] HTTP redirects to HTTPS (301)
- [ ] HSTS header is set: `Strict-Transport-Security: max-age=31536000`
- [ ] No mixed content warnings in browser console
- [ ] SSL certificate is valid and not expiring within 30 days

**Test**:
```bash
curl -I http://yourdomain.com
# Should return 301 redirect to https://
```

---

### 6. Error Handling Sanitization

**Goal**: Production errors don't leak sensitive information.

**Pass criteria**:
- [ ] Stack traces not shown to users
- [ ] Database errors return generic messages
- [ ] File paths not exposed in responses
- [ ] Dependency versions not leaked
- [ ] Custom error pages configured (not framework defaults)

**Test**: Trigger intentional errors and inspect responses:
```bash
# Try invalid input
curl -X POST https://yourapi.com/endpoint -d '{"invalid": "data"}'

# Check response doesn't contain stack trace
```

---

### 7. Dependency Audit

**Goal**: No known vulnerabilities in your dependencies.

```bash
# Node.js
npm audit
# or
yarn audit

# Python
pip-audit
# or
safety check

# Review results and fix critical/high severity issues
```

**Pass criteria**:
- [ ] No critical vulnerabilities
- [ ] No high vulnerabilities (or documented exceptions)
- [ ] Dependencies updated within the last 6 months
- [ ] Lock file (`package-lock.json`, `yarn.lock`, `poetry.lock`) committed

---

### 8. Credential Rotation Plan

**Goal**: Document how to rotate every credential in case of breach.

**Create a table**:

| Credential | Location | Rotation Steps | Last Rotated |
|------------|----------|----------------|--------------|
| Database password | Supabase Dashboard | Settings → Database → Reset | YYYY-MM-DD |
| Stripe API key | Stripe Dashboard | Developers → API Keys → Roll | YYYY-MM-DD |
| JWT secret | Vercel env vars | Generate new, update env | YYYY-MM-DD |
| LLM API key | Provider dashboard | Regenerate key | YYYY-MM-DD |

**Pass criteria**:
- [ ] All credentials documented
- [ ] Rotation steps verified to work
- [ ] At least one person other than you knows the process
- [ ] Credentials rotated at least once (to verify the process)

---

### 9. Kill Switch Test

**Goal**: Verify you can quickly disable the application if compromised.

**Test these actions**:

```bash
# Can you immediately:
# 1. Disable API endpoints?
# 2. Revoke database access?
# 3. Invalidate all sessions?
# 4. Block specific IP addresses?
# 5. Put the site in maintenance mode?
```

**Pass criteria**:
- [ ] Maintenance mode can be enabled in < 2 minutes
- [ ] Database connections can be severed in < 5 minutes
- [ ] All API keys can be revoked in < 10 minutes
- [ ] Process is documented and accessible offline
- [ ] Emergency contacts are documented

---

### 10. Backup Verification

**Goal**: Confirm you can recover from data loss.

**Test**:
```bash
# 1. Identify where backups are stored
# 2. Download a recent backup
# 3. Restore to a test environment
# 4. Verify data integrity
```

**Pass criteria**:
- [ ] Automatic backups are enabled
- [ ] Backup frequency is appropriate (daily minimum)
- [ ] You've successfully restored from a backup (at least once)
- [ ] Backups are stored separately from production
- [ ] Backup retention policy is documented

---

## Completion

**Date**: _______________  
**Completed by**: _______________  
**Environment**: _______________

| Item | Status | Notes |
|------|--------|-------|
| 1. Secrets Scan | ☐ Pass ☐ Fail | |
| 2. RLS Verification | ☐ Pass ☐ Fail | |
| 3. SQL Injection Check | ☐ Pass ☐ Fail | |
| 4. Auth Middleware Audit | ☐ Pass ☐ Fail | |
| 5. HTTPS Enforcement | ☐ Pass ☐ Fail | |
| 6. Error Handling | ☐ Pass ☐ Fail | |
| 7. Dependency Audit | ☐ Pass ☐ Fail | |
| 8. Rotation Plan | ☐ Pass ☐ Fail | |
| 9. Kill Switch Test | ☐ Pass ☐ Fail | |
| 10. Backup Verification | ☐ Pass ☐ Fail | |

**Overall Status**: ☐ Ready for Production ☐ Requires Remediation

---

## Next Steps

This is the **Lite** version of the Pre-Launch Checklist.

The full **Founder's Pre-Launch Security Audit** includes:

- 40+ detailed checkpoints
- Framework-specific guidance (Next.js, Supabase, Vercel)
- Compliance considerations (GDPR, SOC 2 basics)
- Incident response planning worksheets
- Printable PDF format

**→ [Get the Full Audit in the Founder Toolkit](https://safestacklabs.com/#buy)**

---

*Part of the [SAFE Stack Framework](https://github.com/safestacklabs/safe-stack)*
