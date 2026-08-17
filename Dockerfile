# syntax=docker/dockerfile:1.7

ARG PYTHON_IMAGE=python:3.12-slim

###############################################################################
# Stage 1: install pinned dependencies into a venv rooted at /venv
###############################################################################
FROM ${PYTHON_IMAGE} AS deps

# Default to the official PyPI index. In mainland China, uncomment the
# Tsinghua/Aliyun/Tencent/USTC mirror instead of overriding PYTHON_IMAGE.
ARG PIP_INDEX_URL=
ARG PIP_VERSION=26.1.2

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

WORKDIR /build
COPY requirements.txt ./
RUN python -m venv /venv \
    && /venv/bin/pip install --no-cache-dir "pip==${PIP_VERSION}" \
    && /venv/bin/pip install --no-cache-dir ${PIP_INDEX_URL:+--index-url "${PIP_INDEX_URL}"} -r requirements.txt

###############################################################################
# Stage 2: runtime image
###############################################################################
FROM ${PYTHON_IMAGE}

ARG RUN_AS_USER=litellm
ARG RUN_AS_UID=10001
ARG RUN_AS_GID=10001

ENV PATH="/venv/bin:${PATH}" \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    JUPYTER_RUNTIME_DIR=/tmp

WORKDIR /app

COPY --from=deps /venv /venv
COPY --chown=${RUN_AS_UID}:${RUN_AS_GID} litellm_config.yaml ./

RUN if command -v addgroup && command -v adduser; then \
      addgroup --system --gid ${RUN_AS_GID} ${RUN_AS_USER} \
      && adduser --system --uid ${RUN_AS_UID} --ingroup ${RUN_AS_USER} --home /app --disabled-password ${RUN_AS_USER}; \
    fi

USER ${RUN_AS_UID}:${RUN_AS_GID}
EXPOSE 4000

# OCI labels
LABEL org.opencontainers.image.title="Codex Relay"
LABEL org.opencontainers.image.description="Local LiteLLM proxy for the Codex CLI"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.source="https://github.com/USER/codex-relay"
LABEL org.opencontainers.image.version="${CODE_RELAY_VERSION:-latest}"

HEALTHCHECK --interval=30s --timeout=5s --start-period=25s --retries=5 \
  CMD ["/venv/bin/python","-c","import urllib.request; urllib.request.urlopen('http://127.0.0.1:4000/health/readiness', timeout=5)"]

CMD ["litellm","--config","/app/litellm_config.yaml","--host","0.0.0.0","--port","4000"]
