FROM ubuntu:24.04

# Prevent interactive prompts during apt installation
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

WORKDIR /app

# 1. Update and install core system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    unzip \
    ca-certificates \
    gnupg \
    git \
    python3 \
    python3-pip \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# 2. Install official AWS CLI v2 (Bypasses apt v1 deprecation in Ubuntu 24.04)
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf awscliv2.zip aws

# 3. Install Node.js 22 LTS & npm via NodeSource
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# 4. Install Hermes Agent CLI
RUN pip3 install hermes-agent --break-system-packages || true

# 5. Install OmniRoute globally
RUN npm install -g omniroute --legacy-peer-deps

# 6. Copy entrypoint script and configure permissions
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# Expose port (Render overrides this with $PORT dynamically)
EXPOSE 7860

ENTRYPOINT ["/app/entrypoint.sh"]
