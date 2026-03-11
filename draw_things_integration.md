# OpenClaw 联动生图指南：LM Studio + Draw Things (MacOS)

本文档将指导你如何通过 **Model Context Protocol (MCP)** 机制，让运行在 LM Studio 中的大语言模型（如 `qwen3`）调用本地的 **Draw Things** 应用程序，实现本地无缝出图。

## 架构说明

`OpenClaw 发出对话` -> `LM Studio (Qwen3)` -> `识别并调用工具 (Tool Calling)` -> `mcp-drawthings 桥接服务器` -> `Draw Things API (7860/8998)` -> `本地出图并返回`

---

## 步骤 1：准备 Draw Things 及开启 API

1. **打开 Draw Things** 客户端。
2. **选择模型**：在左侧边栏选定你准备用来生图的模型（如一个基于 Flux 或 SDXL 的基础模型）。
3. **开启 API**：
   * 进入软件设置（如果找不到明显写着 API 的地方，通常 Draw Things 默认会在后台开启 `7860` 或 `8998` 端口）。
   * 验证方法：打开浏览器访问 `http://127.0.0.1:7860/sdapi/v1/txt2img` 或 `http://127.0.0.1:8998/sdapi/v1/txt2img`。如果有任何 JSON 响应或路由未找到提示，说明端口是通的。
   * **记录**：确认正确的端口号（下文以 `7860` 举例）。

---

## 步骤 2：测试安装 MCP 桥接器

开源项目 `mcp-drawthings` 是一个轻量的 NodeJS 本地服务，专门用于将标准 MCP 请求翻译给 Draw Things API。

1. **验证环境**：按 `Command + Space` 打开终端（Terminal），确保安装了 NodeJS：
   ```bash
   node -v
   ```
2. **测试运行**：输入以下命令测试组件（npx 会自动下载临时包）：
   ```bash
   npx mcp-drawthings --help
   ```
   如果有帮助说明输出，则环境正常。

---

## 步骤 3：在 LM Studio 中挂载 MCP Server (划重点)

这是最关键的一步，目的是赋予你的 Qwen 模型“画图技能”。

1. 打开 **LM Studio** 客户端。
2. **加载模型**：加载你配置好的 `qwen3-4b-z-image-engineer-v2-mlx`（确保列表中它的后方有一个工具/扳手/小锤子的图标，代表它支持 Tool Calling）。
3. **进入 Tools/MCP 设置**：
   * 在左侧边栏找到“工具 (Tools)”图标，或高级设置里的“MCP”选项卡。
4. **添加服务器 (Add Server)**：
   * 点击 `+ Add Standard Input/Output (stdio) Server` 或 `Add MCP Command`。
   * **Command (命令)** 框填写：`npx`
   * **Arguments (参数)** 框填写：`-y mcp-drawthings`
     *(如果上一步发现你的 Draw Things 端口不是默认，请查阅模块说明添加自定义地址参数，如 `--url http://127.0.0.1:8998`)*
5. **保存**：保存配置。你应该能看到一个绿色的状态标记，下方列举了诸如 `generate_image` 等可用函数。

---

## 步骤 4：在 OpenClaw 中发起请求联动

1. 确保你的 OpenClaw 配置 [openclaw.json](file:///Users/frank/wk/github/openclaw/openclaw.json) 中的 `agents.defaults.model.primary` 或出图意图模型正确指定了 LM Studio 下的那个 `qwen`（已完成）。
2. 在飞书、微信或者终端中，对 OpenClaw 发送命令，例如：
   > “帮我画一张高画质的插画：一只穿着宇航服在火星表面漫步的拉布拉多犬”
3. **观察过程**：
   * OpenClaw 将文本带到 LM Studio。
   * LM Studio 发现自己的工具栏里有一个画图插件，且 Qwen 认为用户的意图需要启动它。
   * LM Studio 的界面（日志）里会显示正在打包 JSON Request （含提取出的正/负提示词）。
   * 几秒钟后，你的 **Draw Things** 窗口会跳出进度条，开始吃满显卡渲染。
   * **成功！** 图画完后将顺着原路回到 OpenClaw 聊天窗口中。

---

## 常见排错 (Troubleshooting)

| 现象 | 可能原因及排查方法 |
| :--- | :--- |
| **LM Studio 里的 MCP 状态报红或连不上** | `npx mcp-drawthings` 命令没装好。尝试全局安装或检查 Node 环境。 |
| **Qwen 只说了“好的我会画”，但 Draw Things 没反应** | Qwen 认为自己没有工具。请确认：1. 左侧配置面板的 **Enables Tools** 开关是打开的。2. 选用的模型支持 Function Calling。 |
| **LM Studio 日志报 Connection Refused** | `mcp-drawthings` 找不到 Draw Things 的端口。请检查 Draw Things 是否启动成功并开启了 Local API，然后核对端口号。 |
