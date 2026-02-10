# Changelog

All notable changes to the SAFE Stack Framework will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Planned
- Framework-specific checklists (Next.js, Django, Rails, Laravel)
- CI/CD integration templates (GitHub Actions, GitLab CI)
- Guardian Prompt translations (ES, FR, DE, PT, JA, ZH)

---

## [2026.02.0] - 2026-02-08

### Initial Framework Release

This is the first public release of the SAFE Stack Framework.

### Added

- **README.md**: Complete project documentation with the 9 Principles overview
- **SECURITY.md**: Vulnerability disclosure policy and security contact information
- **CHANGELOG.md**: This file, tracking version history
- **prompts/safe-stack-guardian.md**: AI system prompt for secure coding
  - XML-tagged security constraints
  - Agentic Drift prevention rules
  - SAFE Checkup footer requirement
- **checklists/pre-launch-lite.md**: 10-point pre-deployment security checklist
  - Secrets scanning
  - RLS verification
  - SQL injection checks
  - Authentication middleware audit
  - Kill switch testing
- **templates/.env.example**: Production-grade environment variable template
  - Auth provider configuration
  - Database connection security
  - LLM API key management
  - Payment processor setup
  - Security hygiene comments

### Security

- Guardian Prompt includes explicit constraints against removing:
  - Authentication middleware
  - Row-Level Security policies
  - Input validation functions
  - Rate limiting configurations
  - CSRF protections

---

## Version Numbering

SAFE Stack uses calendar-based versioning: `YYYY.MM.PATCH`

- **YYYY**: Year of release
- **MM**: Month of release
- **PATCH**: Incremental updates within the month

Example: `2026.02.0` = February 2026, initial release

---

## Links

- [Full Documentation](https://safestacklabs.com)
- [Report Security Issues](SECURITY.md)
- [Founder Toolkit](https://safestacklabs.com/#buy)

---

*For questions about releases, contact help@safestacklabs.com*
