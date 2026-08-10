FROM ubuntu:24.04

WORKDIR /app

# Prevent interactive prompts during apt install
ENV DEBIAN_FRONTEND=noninteractive

# Install core system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    unzip \
    ca-certificates \
    gnupg \
    git \
    python3 \
    python3-pip \
    python3-venv \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Install AWS CLI v2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf awscliv2.zip aws

# Install Node.js 22.x
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Force install hermes-agent with Telegram dependencies
RUN pip3 install --no-cache-dir --break-system-packages "hermes-agent[telegram]" python-telegram-bot

# Install OmniRoute globally
RUN npm install -g omniroute --legacy-peer-deps

# Pre-initialize OmniRoute configuration directory
RUN mkdir -p /root/.omniroute && omniroute init --yes || true

# Copy entrypoint script
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# Memory Optimization Settings for 512MB RAM Limits
ENV NODE_OPTIONS="--max-old-space-size=192"
ENV PYTHONOPTIMIZE=1
ENV HOST=0.0.0.0
EXPOSE 10000

ENTRYPOINT ["/app/entrypoint.sh"]
