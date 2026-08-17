# Security

This project is designed for a single local Codex client.

- Compose binds the proxy to `127.0.0.1` only. Do not change this to `0.0.0.0` unless you add network access controls and TLS.
- Keep `UPSTREAM_API_KEY` and `LITELLM_MASTER_KEY` in an untracked `.env` file.
- Keep the value of `LITELLM_MASTER_KEY` synchronized with `OPENAI_API_KEY` in the local Codex `auth.json`.
- Rotate credentials immediately if they are pasted into chat, issue trackers, logs, or Git history.
- Report a suspected vulnerability privately rather than opening a public issue with credentials or exploit details.
