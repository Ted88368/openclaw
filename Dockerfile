FROM ghcr.io/phioranex/openclaw-docker:latest

# Install uv by copying from official image
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /usr/local/bin/

# Ensure uv is in PATH (usually /usr/local/bin is already in PATH)
ENV PATH="/usr/local/bin:${PATH}"

# Configure uv to use Chinese mirror (TUNA)
ENV UV_INDEX_URL=https://pypi.tuna.tsinghua.edu.cn/simple

# Add any additional customizations here if needed
