# Codex Relay

一个仅供本机 [Codex CLI](https://codex.so) 使用的 LiteLLM Docker 中继（Relay）。
它接收 OpenAI Responses API 请求，并将其转换为上游 OpenAI 兼容 Chat Completions 请求。

## 项目结构

```text
.
├── .github/workflows/     # GitHub Actions
├── docs/                  # 架构说明
├── scripts/               # 可重复执行的维护命令
├── tests/                 # 不依赖上游密钥的烟雾测试
├── compose.yaml           # 本地 Compose 入口
├── Dockerfile             # 多阶段 LiteLLM 镜像构建
├── litellm_config.yaml    # LiteLLM 模型路由
└── requirements.txt       # Python 运行依赖
```

## 启动

```bash
cp .env.example .env
# 编辑 .env，填写 UPSTREAM_API_BASE 和 UPSTREAM_API_KEY
docker compose up -d --build
```

在 Docker Hub 不可用的环境中，可在 `.env` 指定可访问的 Python 基础镜像，例如：

```ini
# 本机镜像仓库
PYTHON_IMAGE=127.0.0.1:5000/foundation/base/python:3.13.14-slim-bookworm

# 或远端镜像仓库
# PYTHON_IMAGE=8.138.175.157:5000/foundation/base/python:3.13.14-slim-bookworm
```

### 国内镜像加速

默认构建从官方 PyPI 下载包。在中国大陆网络下，在 `.env` 中取消注释并设置：

```ini
# 可选：腾讯云、阿里云、清华、中科大
PIP_INDEX_URL=https://pypi.tuna.tsinghua.edu.cn/simple
```

支持的其他镜像源：

- 腾讯云：`https://mirrors.cloud.tencent.com/pypi/simple`
- 阿里云：`https://mirrors.aliyun.com/pypi/simple`
- 清华：`https://pypi.tuna.tsinghua.edu.cn/simple`
- 中科大：`https://pypi.mirrors.ustc.edu.cn/simple`

### 检查运行状态

```bash
docker compose ps
curl --fail http://127.0.0.1:4000/health/readiness
curl --fail -H 'Authorization: Bearer local-litellm-proxy' http://127.0.0.1:4000/v1/models
```

### 项目自检（不启动容器、不访问上游）

```bash
./scripts/validate.sh
```

### 停止服务

```bash
docker compose down
```

如果本机已有服务占用 `4000`，在 `.env` 中将 `HOST_PORT` 改为未占用端口；Codex 的 `base_url` 也要使用相同端口。

## Codex 配置

`~/.codex/config.toml`：

```toml
model = "deepseek-v4-flash"
model_provider = "litellm"

[model_providers.litellm]
name = "LiteLLM local proxy"
wire_api = "responses"
requires_openai_auth = true
base_url = "http://127.0.0.1:4000/v1"
```

`~/.codex/auth.json` 保留既有 `auth_mode`，并设置本地占位令牌：

```json
{
  "OPENAI_API_KEY": "local-litellm-proxy"
}
```

该令牌不用于上游鉴权；上游密钥只存在于 Docker 的 `.env` 文件中。
如在 `.env` 中修改 `LITELLM_MASTER_KEY`，请将 `OPENAI_API_KEY` 修改为相同值。

## 安全

- Compose 绑定到 `127.0.0.1` 仅限本机访问
- 凭据仅存在于本地 `.env`，已加入 `.gitignore`
- 运行时使用非 root 用户（UID 10001）
- 详见 [SECURITY.md](SECURITY.md)

## 贡献

详见 [CONTRIBUTING.md](CONTRIBUTING.md)
