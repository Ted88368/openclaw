# 🦞 OpenClaw Docker + LM Studio

在 Mac 上通过 Docker 运行 [OpenClaw](https://github.com/openclaw/openclaw) AI 助手，使用本地 [LM Studio](https://lmstudio.ai) 作为 LLM 后端 —— **无需任何云 API Key，完全本地运行**。

## 前置条件

| 依赖 | 版本要求 | 说明 |
|------|---------|------|
| [Docker Desktop for Mac](https://www.docker.com/products/docker-desktop/) | Docker Compose v2+ | 容器运行时 |
| [LM Studio](https://lmstudio.ai) | 最新版 | 本地 LLM 服务，默认端口 `1234` |

---

## 快速开始

```bash
# 1. 克隆项目
git clone https://github.com/Ted88368/openclaw.git
cd openclaw

# 2. 一键设置（自动检测 LM Studio、复制配置、拉取镜像、启动 Gateway）
chmod +x setup.sh
./setup.sh
```

---

## 详细使用说明

### 第一步：在 LM Studio 中准备模型

1. 打开 LM Studio，下载并加载 `zai-org/glm-4.7-flash`（或其他模型）
2. 进入 **Developer** 标签页，开启本地服务器
3. **重要**：点击模型旁的设置，将 **Context Length** 设置为 `65536` 或更大

   > OpenClaw 的系统提示词约 25000 字符，需要足够大的上下文窗口

4. 验证 LM Studio 正在运行：
   ```bash
   curl http://127.0.0.1:1234/v1/models
   ```

### 第二步：配置 openclaw.json

当前配置已预设为使用 `zai-org/glm-4.7-flash`。如需更换模型，编辑 `openclaw.json`：

```json
{
  "gateway": {
    "mode": "local",
    "auth": { "token": "local-dev" }
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "lmstudio/<你的模型ID>"
      }
    }
  },
  "models": {
    "mode": "merge",
    "providers": {
      "lmstudio": {
        "baseUrl": "http://host.docker.internal:1234/v1",
        "apiKey": "lmstudio",
        "api": "openai-completions",
        "models": [
          {
            "id": "<你的模型ID>",
            "name": "<模型显示名称>",
            "contextWindow": 65536,
            "maxTokens": 4096
          }
        ]
      }
    }
  }
}
```

> **注意**：`agents.defaults.model.primary` 中的模型 ID 必须带 `lmstudio/` 前缀。

### 第三步：启动 Gateway

```bash
# 将配置同步到 ~/.openclaw 并启动
mkdir -p ~/.openclaw/workspace
cp openclaw.json ~/.openclaw/openclaw.json
docker compose up -d openclaw-gateway
```

---

## 验证和测试

### 检查 Gateway 状态

```bash
# 查看 Gateway 运行状态和模型配置
docker compose run --rm openclaw-cli status
```

成功输出应包含：
```
Gateway  │ local · ws://127.0.0.1:18789 · reachable · auth token
Sessions │ default glm-4.7-flash (200k ctx) ...
```

### 发送测试对话

```bash
# 发送一条消息给 AI Agent
docker compose run --rm openclaw-cli agent \
  --session-id test-001 \
  --message "你好！请介绍一下你自己,包括使用的模型" \
  --json
```

返回 `"status": "ok"` 即表示成功。查看 Gateway 日志获取模型回复：

```bash
docker compose logs --tail=20 openclaw-gateway
```

### 健康检查

```bash
docker compose run --rm openclaw-cli health
```

---

## 常用命令

```bash
# Gateway 管理
docker compose up -d openclaw-gateway        # 启动
docker compose restart openclaw-gateway      # 重启
docker compose down                          # 停止
docker compose logs -f openclaw-gateway      # 实时日志

# CLI 工具
docker compose run --rm openclaw-cli status  # 系统状态总览
docker compose run --rm openclaw-cli health  # 健康检查
docker compose run --rm openclaw-cli doctor  # 诊断问题

# 配置同步（修改 openclaw.json 后执行）
# cp  ~/.openclaw/openclaw.json openclaw.json
cp openclaw.json ~/.openclaw/openclaw.json && docker compose restart openclaw-gateway
```

---

## 网络架构

```
Mac 宿主机
├── LM Studio  → http://127.0.0.1:1234
└── Docker
    ├── openclaw-gateway  (ws://127.0.0.1:18789)
    │     └── 通过 host.docker.internal:1234 调用 LM Studio
    └── openclaw-cli (共享 gateway 网络空间)
```

容器通过 `host.docker.internal` 访问宿主机上的 LM Studio，已在 `docker-compose.yml` 中自动配置。

---

## 常见问题

| 问题 | 原因 | 解决方法 |
|------|------|---------|
| `token context length exceeded` | LM Studio 上下文窗口太小 | 在 LM Studio 中将 Context Length 设为 65536+ |
| `Unknown model: zai-org/...` | primary 模型 ID 缺少前缀 | 改为 `lmstudio/zai-org/glm-4.7-flash` |
| `gateway token missing` | CLI 未配置认证 Token | 确保 CLI 容器有 `OPENCLAW_GATEWAY_TOKEN=local-dev` |
| `gateway closed (1006)` | CLI 无法访问 Gateway | 确认 `docker-compose.yml` 中 CLI 使用 `network_mode: service:openclaw-gateway` |

---

## Skill 推荐

- [Skill 推荐](./skill.md)
- [find-skills](https://clawhub.ai/JimLiuxinghai/find-skills) — 帮助快速找到适合的技能

## 参考

- [OpenClaw 官方文档](https://docs.openclaw.ai)
- [OpenClaw Docker 镜像](https://github.com/phioranex/openclaw-docker)
- [本地模型配置指南](https://docs.openclaw.ai/gateway/local-models)
