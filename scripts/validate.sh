#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$ROOT_DIR"

command -v docker >/dev/null

# 1. Compose configuration must parse cleanly
docker compose --env-file .env.example config --quiet 2>/dev/null

# 2. Git whitespace hygiene
git diff --check

# 3. Required governance files
for f in LICENSE Makefile .editorconfig .github/PULL_REQUEST_TEMPLATE.md .github/dependabot.yml .github/CODEOWNERS; do
  test -f "$f" || { echo "missing $f" >&2; exit 1; }
done

# 4. Dockerfile must have OCI labels
grep -q 'org.opencontainers.image.title' Dockerfile
grep -q 'org.opencontainers.image.licenses' Dockerfile

# 5. Compose must use the correct project name
grep -q 'codex-relay' compose.yaml

# 6. .gitignore and .dockerignore must cover compose.override.yaml
grep -q 'compose.override.yaml' .gitignore
grep -q 'compose.override.yaml' .dockerignore

# 7. Credential leak scan — git grep works everywhere, no extra dependencies.
if git grep -n --no-index \
  -- 'sk-[A-Za-z0-9_-]{20,}' \
  -- .env.example .editorconfig .github/ .gitignore CONTRIBUTING.md \
     Dockerfile LICENSE Makefile README.md SECURITY.md \
     compose.override.yaml.example compose.yaml docs/ litellm_config.yaml requirements.txt \
  2>/dev/null; then
  echo 'possible credential found in publishable files' >&2
  exit 1
fi

echo 'project validation passed'
