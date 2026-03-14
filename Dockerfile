FROM openclaw-multiarch-test:latest

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
    sudo \
    zsh \
    fzf \
    bat \
    eza \
    vim \
    && echo "node ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
    && ln -s /usr/bin/batcat /usr/local/bin/bat \
    && rm -rf /var/lib/apt/lists/*

# Install Starship
RUN curl -sS https://starship.rs/install.sh | sh -s -- -y

# Install uv by copying from official image
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /usr/local/bin/

# Use uv to install Python 3.12 and make it the default
ENV UV_PYTHON_INSTALL_DIR=/usr/local/share/uv/python
RUN mkdir -p $UV_PYTHON_INSTALL_DIR && \
    uv python install 3.12 && \
    chmod -R a+rx /usr/local/share/uv && \
    PYTHON_EXE=$(uv python find 3.12) && \
    ln -sf "$PYTHON_EXE" /usr/local/bin/python3 && \
    ln -sf "$PYTHON_EXE" /usr/local/bin/python && \
    ln -sf "$PYTHON_EXE" /usr/bin/python3 && \
    ln -sf "$PYTHON_EXE" /usr/bin/python

# Ensure uv is in PATH
ENV PATH="/usr/local/bin:${PATH}"

# Configure uv to use Chinese mirror (TUNA)
ENV UV_INDEX_URL=https://pypi.tuna.tsinghua.edu.cn/simple

# Switch back to the default user
USER node
WORKDIR /home/node

# Install Oh My Zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended && \
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Copy configurations
COPY --chown=node:node .zshrc /home/node/.zshrc
COPY --chown=node:node starship.toml /home/node/.starship.toml

# Set Starship config path
ENV STARSHIP_CONFIG=/home/node/.starship.toml

# Set zsh as default shell for the node user
USER root
RUN chsh -s /bin/zsh node
USER node

CMD ["zsh"]
