# Contributing to Codex Relay

## Local checks

Run the project checks before opening a pull request:

```bash
./scripts/validate.sh
```

For a running local proxy, execute the smoke test as well:

```bash
PROXY_URL=http://127.0.0.1:4000 ./tests/smoke.sh
```

Do not commit `.env`, upstream API keys, generated logs, or local OMX state.
