#!/usr/bin/env bash
set -euo pipefail

# Smoke test for a running registry proxy.
#   PROXY_URL   base URL, default http://127.0.0.1:4000
#   PROXY_KEY   LiteLLM master key, default local-litellm-proxy
PROXY_URL=${PROXY_URL:-http://127.0.0.1:4000}
PROXY_KEY=${PROXY_KEY:-local-litellm-proxy}

# 1. Readiness
curl --silent --show-error --fail "$PROXY_URL/health/readiness" >/dev/null

# 2. Auth required: unauthenticated requests must fail
unauth_code=$(curl --silent --output /dev/null --write-out '%{http_code}' \
  "$PROXY_URL/v1/models")
if [[ "$unauth_code" == "200" ]]; then
  echo "unauthenticated /v1/models returned 200; expected auth failure" >&2
  exit 1
fi

# 3. Authenticated /v1/models
curl --silent --show-error --fail \
  -H "Authorization: Bearer $PROXY_KEY" \
  "$PROXY_URL/v1/models" >/dev/null

# 4. Authenticated /v1/responses e2e (optional; needs upstream reachability)
if [[ "${SMOKE_RESPONSES:-0}" == "1" ]]; then
  curl --silent --show-error --fail \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $PROXY_KEY" \
    "$PROXY_URL/v1/responses" \
    --data '{"model":"deepseek-v4-flash","input":"Reply with exactly: OK","max_output_tokens":64}' \
    >/dev/null
fi

echo "proxy smoke test passed: $PROXY_URL"
