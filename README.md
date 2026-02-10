# SAFE Stack Framework

**A security framework for founders shipping AI-generated code.**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Framework Version](https://img.shields.io/badge/version-2026.02.0-green.svg)](CHANGELOG.md)

---

## Why This Exists

AI coding assistants (Cursor, Claude, Copilot, Replit) are changing how software gets built. They're fast. They're productive. They're also dangerously optimized for *working code* over *secure code*.

**The problem isn't the AI. It's the gap between "it works" and "it's safe to deploy."**

Common issues we've observed in AI-generated codebases:

- SQL queries built with string concatenation (injection vulnerabilities)
- API keys hardcoded in source files (secret exposure)
- Authentication middleware silently removed during refactoring (agentic drift)
- Row-Level Security policies disabled for "debugging" and never re-enabled
- Session tokens generated with predictable patterns
- Error messages leaking stack traces and internal paths

The SAFE Stack Framework provides guardrails, checklists, and prompts to catch these issues *before* they reach production.

---

## The 9 Principles

The SAFE Stack is built on 9 security principles designed for the AI-native development workflow:

| # | Principle | Focus |
|---|-----------|-------|
| 1 | **Scope** | Know your attack surface. Map every entry point, data store, and third-party integration. |
| 2 | **Assume** | Design for breach. Limit blast radius through isolation and least privilege. |
| 3 | **Filter** | Validate and sanitize all input. Prefer allowlists over blocklists. |
| 4 | **Enforce** | Implement authentication and authorization at every layer. |
| 5 | **Scan** | Automate secret detection and dependency vulnerability scanning. |
| 6 | **Test** | Security testing doesn't require a dedicated team. Start with basics. |
| 7 | **Audit** | Log security-relevant events. You can't investigate what you didn't record. |
| 8 | **Control** | Manage secrets properly. Rotate credentials. Use environment variables. |
| 9 | **Kill** | Have an incident response plan. Know how to revoke access quickly. |

---

## Quick Start: The Guardian Prompt

The fastest way to improve your AI-assisted development security is to use the **SAFE Stack Guardian Prompt**.

### What It Does

- Instructs your AI assistant to preserve security controls during refactoring
- Prevents silent removal of authentication middleware, RLS policies, and input validation
- Adds a "SAFE Checkup" footer to every response for transparency

### Usage

**Option A: Copy the raw prompt**

1. Open [`prompts/GUARDIAN_PROMPT.txt`](prompts/GUARDIAN_PROMPT.txt)
2. Click "Raw" → Select All → Copy
3. Paste into your AI assistant

**Option B: Read the documented version**

1. Review [`prompts/safe-stack-guardian.md`](prompts/safe-stack-guardian.md) for full documentation
2. Copy the prompt from the code block
3. Customize for your stack if needed

### Where to Paste

- **Cursor**: Settings → Rules for AI → Paste in "User Rules"
- **Claude Projects**: Add to Project Knowledge or System Prompt
- **Claude.ai**: Paste at the start of conversations about code
- **ChatGPT**: Custom Instructions → "How would you like ChatGPT to respond?"

Start coding. The AI will now flag security-relevant changes.

---

## Repository Contents

```
safe-stack/
├── README.md                       # You are here
├── SECURITY.md                     # Vulnerability disclosure policy
├── CHANGELOG.md                    # Version history
├── LICENSE                         # MIT License
├── prompts/
│   ├── GUARDIAN_PROMPT.txt         # Raw prompt (copy-paste ready)
│   └── safe-stack-guardian.md      # Full documentation
├── checklists/
│   └── pre-launch-lite.md          # 10-point pre-deployment checklist
├── scripts/
│   └── secrets-scan.sh             # Scan your codebase for leaked secrets
├── examples/
│   └── vulnerable-vs-secure.md     # Side-by-side secure code patterns
```

---

## Pre-Launch Checklist (Lite)

Before your first deployment, run through the [Pre-Launch Lite Checklist](checklists/pre-launch-lite.md):

- [ ] Secrets scan completed
- [ ] Database RLS enabled
- [ ] SQL injection vectors checked
- [ ] Authentication middleware verified
- [ ] HTTPS enforced
- [ ] Error handling sanitized
- [ ] Dependencies audited
- [ ] Credential rotation plan documented
- [ ] Kill switch tested
- [ ] Backup verified

This is a condensed version. The full audit worksheet is available in the [Founder Toolkit](https://safestacklabs.com/#buy).

---

## Full Framework

This repository contains the open-source essentials. For comprehensive coverage, the **SAFE Stack Founder Toolkit** includes:

- Complete 90-page implementation guide
- Full Pre-Launch Security Audit worksheet
- Incident Response Battle Card
- SAFE Stack Cheat Sheet (print-ready)
- 3 months of SAFE Stack Signals (weekly security briefings)

**→ [Get the Founder Toolkit](https://safestacklabs.com/#buy)**

---

## Agentic Drift: The Hidden Risk

"Agentic Drift" is when AI coding assistants silently remove or weaken security controls while making seemingly unrelated changes.

**Example:**

You ask the AI to "optimize this function for performance." It returns cleaner code — but quietly removes the input validation middleware because it "wasn't being used efficiently."

The Guardian Prompt is specifically designed to prevent this. It includes explicit constraints that instruct the AI to preserve security-critical code and flag any modifications.

---

## Contributing

We welcome contributions that improve the framework's utility:

- Additional checklists for specific frameworks (Next.js, Django, Rails)
- Translations of the Guardian Prompt
- Integration guides for CI/CD pipelines

Please read [SECURITY.md](SECURITY.md) before submitting security-related changes.

---

## License

MIT License. See [LICENSE](LICENSE) for details.

Use it. Fork it. Make your code safer.

---

## Links

- **Website**: [safestacklabs.com](https://safestacklabs.com)
- **Security Contact**: security@safestacklabs.com
- **Updates**: [SAFE Stack Signals](https://safestacklabs.com/#signals)

---

*Built for founders who ship fast and sleep well.*
