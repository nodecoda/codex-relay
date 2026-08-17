# Codex Relay Architecture

```text
Codex (Responses API)
        |
        v
127.0.0.1:4000 (LiteLLM)
        |
        | openai/chat_completions/deepseek-v4-flash
        | drops web_search_options
        v
Configured OpenAI-compatible upstream (/v1)
```

LiteLLM owns the protocol conversion and local bearer-token check. The upstream URL and key are injected at runtime through environment variables; they are not copied into the image or configuration file. The image runs as UID/GID `10001` and Compose drops all Linux capabilities.

The host port is configurable with `HOST_PORT`, while the container always listens on port `4000`.
