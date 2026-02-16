#!/bin/bash
set -e

# ============================================================
# OpenClaw Docker + LM Studio 一键设置脚本
# ============================================================

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}🦞 OpenClaw Docker + LM Studio 设置脚本${NC}"
echo ""

# --- 1. 检查 Docker ---
if ! command -v docker &>/dev/null; then
  echo -e "${RED}❌ 未找到 Docker。请先安装 Docker Desktop for Mac:${NC}"
  echo "   https://www.docker.com/products/docker-desktop/"
  exit 1
fi

if ! docker info &>/dev/null 2>&1; then
  echo -e "${RED}❌ Docker 未运行。请启动 Docker Desktop。${NC}"
  exit 1
fi

echo -e "${GREEN}✅ Docker 已就绪${NC}"

# --- 2. 检查 Docker Compose ---
if ! docker compose version &>/dev/null 2>&1; then
  echo -e "${RED}❌ 未找到 Docker Compose v2。请更新 Docker Desktop。${NC}"
  exit 1
fi

echo -e "${GREEN}✅ Docker Compose 已就绪${NC}"

# --- 3. 检查 LM Studio ---
echo ""
echo -e "${YELLOW}📡 检查 LM Studio 连接...${NC}"
if curl -s http://127.0.0.1:1234/v1/models > /dev/null 2>&1; then
  echo -e "${GREEN}✅ LM Studio 已运行${NC}"
  echo "   可用模型:"
  curl -s http://127.0.0.1:1234/v1/models | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    for m in data.get('data', []):
        print(f\"   - {m['id']}\")
except:
    print('   (无法解析模型列表)')
"
else
  echo -e "${YELLOW}⚠️  LM Studio 未运行或未启动本地服务器${NC}"
  echo "   请确保 LM Studio 已启动并在 Developer 标签页中开启本地服务器"
  echo "   默认地址: http://127.0.0.1:1234"
  echo ""
  read -p "是否继续设置？(y/N) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
  fi
fi

# --- 4. 创建配置目录 ---
echo ""
echo -e "${YELLOW}📁 创建配置目录...${NC}"
mkdir -p ~/.openclaw/workspace

# --- 5. 安装 openclaw.json ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_SRC="${SCRIPT_DIR}/openclaw.json"
CONFIG_DST="$HOME/.openclaw/openclaw.json"

if [ -f "$CONFIG_DST" ]; then
  echo -e "${YELLOW}⚠️  已存在 ~/.openclaw/openclaw.json${NC}"
  read -p "是否覆盖？(y/N) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    cp "$CONFIG_SRC" "$CONFIG_DST"
    echo -e "${GREEN}✅ 配置已更新${NC}"
  else
    echo "   保留现有配置"
  fi
else
  cp "$CONFIG_SRC" "$CONFIG_DST"
  echo -e "${GREEN}✅ 配置已安装到 ~/.openclaw/openclaw.json${NC}"
fi

# --- 6. 拉取镜像 ---
echo ""
echo -e "${YELLOW}📦 拉取 OpenClaw Docker 镜像...${NC}"
docker pull ghcr.io/phioranex/openclaw-docker:latest

# --- 7. 运行 onboard（首次设置） ---
echo ""
echo -e "${YELLOW}🧙 是否运行 onboard 向导？(首次使用推荐)${NC}"
read -p "(y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  docker compose run --rm openclaw-cli onboard
fi

# --- 8. 启动 Gateway ---
echo ""
echo -e "${YELLOW}🚀 启动 OpenClaw Gateway...${NC}"
docker compose up -d openclaw-gateway

echo ""
echo -e "${GREEN}============================================================${NC}"
echo -e "${GREEN}🎉 OpenClaw 已启动！${NC}"
echo -e "${GREEN}============================================================${NC}"
echo ""
echo "  WebChat UI:  http://127.0.0.1:18789/"
echo "  LM Studio:   http://127.0.0.1:1234/"
echo ""
echo "  常用命令:"
echo "    docker compose logs -f openclaw-gateway   # 查看日志"
echo "    docker compose restart openclaw-gateway    # 重启"
echo "    docker compose down                        # 停止"
echo "    docker compose run --rm openclaw-cli doctor # 诊断"
echo ""
