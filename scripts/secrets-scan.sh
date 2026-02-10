#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# SAFE Stack Secrets Scanner
# ═══════════════════════════════════════════════════════════════════════════════
# A quick scan for common leaked secrets in your codebase.
# Run this before every commit or as a pre-commit hook.
#
# Usage: ./secrets-scan.sh [directory]
# Default: scans current directory
#
# SAFE Stack Framework: https://safestacklabs.com
# ═══════════════════════════════════════════════════════════════════════════════

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Directory to scan (default: current directory)
SCAN_DIR="${1:-.}"

echo "═══════════════════════════════════════════════════════════════"
echo "  🔍 SAFE Stack Secrets Scanner"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "Scanning: $SCAN_DIR"
echo ""

# Track if we found anything
FOUND_SECRETS=0

# ─────────────────────────────────────────────────────────────────────────────────
# Function to search and report
# ─────────────────────────────────────────────────────────────────────────────────
search_pattern() {
    local pattern="$1"
    local description="$2"
    local results
    
    results=$(grep -rn --include="*.js" --include="*.ts" --include="*.jsx" --include="*.tsx" \
                       --include="*.py" --include="*.rb" --include="*.php" --include="*.go" \
                       --include="*.java" --include="*.cs" --include="*.env*" --include="*.json" \
                       --include="*.yml" --include="*.yaml" --include="*.toml" --include="*.xml" \
                       --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=vendor \
                       --exclude-dir=__pycache__ --exclude-dir=.next --exclude-dir=dist \
                       --exclude-dir=build --exclude="*.min.js" --exclude="package-lock.json" \
                       -E "$pattern" "$SCAN_DIR" 2>/dev/null || true)
    
    if [ -n "$results" ]; then
        echo -e "${RED}⚠️  $description${NC}"
        echo "$results" | head -10
        if [ $(echo "$results" | wc -l) -gt 10 ]; then
            echo -e "${YELLOW}   ... and more (showing first 10)${NC}"
        fi
        echo ""
        FOUND_SECRETS=1
    fi
}

# ─────────────────────────────────────────────────────────────────────────────────
# Scan for common secret patterns
# ─────────────────────────────────────────────────────────────────────────────────

echo "Checking for API keys and tokens..."
echo "─────────────────────────────────────────────────────────────────"

# Stripe
search_pattern "sk_live_[a-zA-Z0-9]{24,}" "Stripe Live Secret Key"
search_pattern "sk_test_[a-zA-Z0-9]{24,}" "Stripe Test Secret Key (remove before production)"
search_pattern "rk_live_[a-zA-Z0-9]{24,}" "Stripe Restricted Key"

# AWS
search_pattern "AKIA[0-9A-Z]{16}" "AWS Access Key ID"
search_pattern "aws_secret_access_key\s*=\s*['\"][^'\"]{40}['\"]" "AWS Secret Access Key"

# OpenAI
search_pattern "sk-[a-zA-Z0-9]{48}" "OpenAI API Key"

# Anthropic
search_pattern "sk-ant-[a-zA-Z0-9-]{40,}" "Anthropic API Key"

# GitHub
search_pattern "ghp_[a-zA-Z0-9]{36}" "GitHub Personal Access Token"
search_pattern "gho_[a-zA-Z0-9]{36}" "GitHub OAuth Token"
search_pattern "ghs_[a-zA-Z0-9]{36}" "GitHub Server Token"

# Google
search_pattern "AIza[0-9A-Za-z-_]{35}" "Google API Key"

# Supabase
search_pattern "sbp_[a-zA-Z0-9]{40}" "Supabase Service Key"

# Generic patterns
search_pattern "-----BEGIN (RSA |EC |DSA |OPENSSH )?PRIVATE KEY-----" "Private Key"
search_pattern "(password|passwd|pwd)\s*=\s*['\"][^'\"]{8,}['\"]" "Hardcoded Password"
search_pattern "(api_key|apikey|api-key)\s*=\s*['\"][^'\"]{16,}['\"]" "Generic API Key"
search_pattern "(secret|token)\s*=\s*['\"][^'\"]{16,}['\"]" "Generic Secret/Token"

# Database URLs with credentials
search_pattern "postgres://[^:]+:[^@]+@" "PostgreSQL Connection String with Password"
search_pattern "mysql://[^:]+:[^@]+@" "MySQL Connection String with Password"
search_pattern "mongodb://[^:]+:[^@]+@" "MongoDB Connection String with Password"

# JWT Secrets (common weak values)
search_pattern "jwt[_-]?secret\s*=\s*['\"][^'\"]{8,}['\"]" "JWT Secret"

echo ""
echo "═══════════════════════════════════════════════════════════════"

if [ $FOUND_SECRETS -eq 1 ]; then
    echo -e "${RED}❌ SECRETS DETECTED${NC}"
    echo ""
    echo "Action required:"
    echo "  1. Remove the secrets from your code"
    echo "  2. Use environment variables instead"
    echo "  3. If already committed, rotate the credentials IMMEDIATELY"
    echo "  4. Use 'git filter-branch' or BFG to remove from history"
    echo ""
    echo "Need help? https://safestacklabs.com"
    exit 1
else
    echo -e "${GREEN}✅ No obvious secrets detected${NC}"
    echo ""
    echo "Note: This scan catches common patterns but isn't exhaustive."
    echo "Consider using dedicated tools like:"
    echo "  - gitleaks (https://github.com/gitleaks/gitleaks)"
    echo "  - trufflehog (https://github.com/trufflesecurity/trufflehog)"
    echo "  - git-secrets (https://github.com/awslabs/git-secrets)"
    exit 0
fi
