FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PORT=7860

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    python3 \
    python3-pip \
    nodejs \
    npm \
    awscli \
    && rm -rf /var/lib/apt/lists/*

# Install global packages
RUN npm install -g omniroute

WORKDIR /app

COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# Expose default Hugging Face Space port
EXPOSE 7860

ENTRYPOINT ["/app/entrypoint.sh"]
