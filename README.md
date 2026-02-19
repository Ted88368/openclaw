# 🦞 OpenClaw Docker + LM Studio

在 Mac 上通过 Docker 运行 [OpenClaw](https://github.com/openclaw/openclaw) AI 助手，使用本地 [LM Studio](https://lmstudio.ai) 作为 LLM 后端。

## 前置条件

| 依赖 | 说明 |
|------|------|
| [Docker Desktop for Mac](https://www.docker.com/products/docker-desktop/) | 需要 Docker Compose v2 |
| [LM Studio](https://lmstudio.ai) | 下载并加载一个模型，启动本地服务器（默认端口 `1234`） |

## 快速开始

```bash
# 1. 克隆项目
git clone https://github.com/Ted88368/openclaw.git
cd openclaw

# 2. 一键设置
chmod +x setup.sh
./setup.sh
```

## 手动设置

```bash
# 1. 创建配置目录
mkdir -p ~/.openclaw/workspace

# 2. 复制配置文件
cp openclaw.json ~/.openclaw/openclaw.json

# 3. 拉取镜像
docker pull ghcr.io/phioranex/openclaw-docker:latest

# 4. 首次 onboard（可选）
docker compose run --rm openclaw-cli onboard

# 5. 启动
docker compose up -d openclaw-gateway
```

## 访问

- **WebChat UI**: http://127.0.0.1:18789/
- **LM Studio API**: http://127.0.0.1:1234/v1/models

## 配置 LM Studio 模型

编辑 `~/.openclaw/openclaw.json`，修改模型 ID 以匹配 LM Studio 中加载的模型：

```json
{
  "agents": {
    "defaults": {
      "model": {
        "primary": "lmstudio/<你的模型ID>"
      }
    }
  },
  "models": {
    "providers": {
      "lmstudio": {
        "models": [
          {
            "id": "<你的模型ID>",
            "name": "<模型显示名称>"
          }
        ]
      }
    }
  }
}
```

> **提示**: 运行 `curl http://127.0.0.1:1234/v1/models` 查看 LM Studio 当前加载的模型 ID。

## 常用命令

```bash
docker compose logs -f openclaw-gateway    # 查看日志
docker compose restart openclaw-gateway     # 重启
docker compose down                         # 停止所有服务
docker compose run --rm openclaw-cli doctor # 运行诊断
```

## 网络说明

Docker 容器通过 `host.docker.internal` 访问 Mac 宿主机上运行的 LM Studio。这在 `docker-compose.yml` 和 `openclaw.json` 中已自动配置，无需额外操作。

## Skill 推荐
+ [Skill 推荐](./skill.md)


## 参考

- [OpenClaw 官方文档](https://docs.openclaw.ai)
- [OpenClaw Docker 镜像](https://github.com/phioranex/openclaw-docker)
- [本地模型配置指南](https://docs.openclaw.ai/gateway/local-models)
