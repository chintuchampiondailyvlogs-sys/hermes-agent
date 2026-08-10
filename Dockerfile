FROM ubuntu:24.04

WORKDIR /app

# Install system dependencies
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

# Install AWS CLI v2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf awscliv2.zip aws

# Install Node.js 22.x
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install Hermes Agent Python package
RUN pip3 install "hermes-agent[telegram]" --break-system-packages || true

# Install OmniRoute AI Gateway globally
RUN npm install -g omniroute --legacy-peer-deps

# Pre-initialize OmniRoute so key generation doesn't block startup
RUN mkdir -p /root/.omniroute && omniroute init --yes || true

# Copy entrypoint execution script
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# Force binding to all network interfaces inside container
ENV HOST=0.0.0.0
EXPOSE 10000

ENTRYPOINT ["/app/entrypoint.sh"]
