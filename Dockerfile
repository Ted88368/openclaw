FROM ghcr.io/phioranex/openclaw-docker:latest

# Install system dependencies for a complete Python environment
USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    build-essential \
    gcc \
    git \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install uv by copying from official image
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /usr/local/bin/

# Ensure uv is in PATH
ENV PATH="/usr/local/bin:${PATH}"

# Configure uv to use Chinese mirror (TUNA)
ENV UV_INDEX_URL=https://pypi.tuna.tsinghua.edu.cn/simple

# Switch back to the default user
USER node
