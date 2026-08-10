FROM ubuntu:24.04

# Prevent interactive prompts during apt installation
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

WORKDIR /app

# 1. Update and install core prerequisites first
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    gnupg \
    git \
    python3 \
    python3-pip \
    awscli \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# 2. Install Node.js & npm cleanly via NodeSource LTS
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# 3. Install OmniRoute globally
RUN npm install -g omniroute

# 4. Copy entrypoint script and set permissions
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# Expose default port
EXPOSE 7860

ENTRYPOINT ["/app/entrypoint.sh"]
