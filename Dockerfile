FROM ubuntu:24.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Declare build arguments for multi-arch support
# These are automatically provided by Docker buildx and can be used for platform-specific logic
ARG TARGETARCH
ARG TARGETPLATFORM

# Install system dependencies
RUN apt-get update && apt-get -qq install -y \
    # Basic utilities
    wget \
    curl \
    xz-utils \
    gnupg \
    # X11 and GUI dependencies
    libx11-xcb1 \
    libxcomposite1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxrandr2 \
    libxrender1 \
    libxss1 \
    libxtst6 \
    # Additional libraries for Puppeteer
    libxcb-cursor0 \
    libxcb-xinerama0 \
    libxcb-icccm4 \
    libxcb-image0 \
    libxcb-keysyms1 \
    libxcb-randr0 \
    libxcb-render-util0 \
    libxkbcommon-x11-0 \
    libopengl0 \
    libegl1 \
    libgles2 \
    # Calibre dependencies
    libglx0 \
    libgl1 \
    libglx-mesa0 \
    libgl1-mesa-dri \
    # Font support
    fonts-wqy-microhei \
    ttf-wqy-zenhei \
    # Additional utilities
    poppler-utils \
    speech-dispatcher \
    # Node.js requirements
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js
RUN wget -qO- https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm@latest

# Install Calibre
RUN apt-get update \
    && apt-get -qq install -y calibre \
    && rm -rf /var/lib/apt/lists/* \
    && dbus-uuidgen > /etc/machine-id

# Install Chrome dependencies for Puppeteer
RUN apt-get update \
    && apt-get -qq install -y \
        fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst fonts-freefont-ttf \
        libasound2t64 libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgcc1 \
        libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 \
        libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 \
        libxrandr2 libxrender1 libxss1 libxtst6 fonts-liberation libappindicator3-1 libnss3 lsb-release xdg-utils \
        --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# Install Puppeteer and Chrome browser
# Note: SSL verification is temporarily disabled due to certificate chain issues in some build environments
# The strict-ssl setting is restored immediately after installation
RUN npm config set strict-ssl false \
    && npm install -g puppeteer \
    && npx puppeteer browsers install chrome \
    && npm config set strict-ssl true

# Verify installations
RUN ebook-convert --version
RUN node -v && npm -v

# Copy verification script
COPY verify-chrome-arch.sh /usr/local/bin/verify-chrome-arch.sh
RUN chmod +x /usr/local/bin/verify-chrome-arch.sh

# Verify Chrome binary architecture matches system architecture
RUN echo "=== Verifying Chrome Binary Architecture ===" \
    && echo "System Architecture: $(uname -m)" \
    && echo "Target Architecture: ${TARGETARCH}" \
    && CHROME_PATH=$(find /root/.cache/puppeteer -name chrome -type f 2>/dev/null | head -1) \
    && if [ -n "$CHROME_PATH" ]; then \
        echo "Chrome binary found: $CHROME_PATH"; \
        echo "Chrome binary architecture:"; \
        file "$CHROME_PATH"; \
        echo "Testing Chrome execution:"; \
        "$CHROME_PATH" --version || (echo "ERROR: Chrome binary failed to execute!" && exit 1); \
        CHROME_ARCH=$(file "$CHROME_PATH" | grep -o "x86-64\|aarch64\|ARM aarch64" | head -1); \
        SYSTEM_ARCH=$(uname -m); \
        echo "Detected Chrome arch: $CHROME_ARCH"; \
        echo "System arch: $SYSTEM_ARCH"; \
        if [ "$SYSTEM_ARCH" = "x86_64" ] && echo "$CHROME_ARCH" | grep -q "x86-64"; then \
            echo "✓ Architecture match: AMD64"; \
        elif [ "$SYSTEM_ARCH" = "aarch64" ] && echo "$CHROME_ARCH" | grep -q "aarch64\|ARM"; then \
            echo "✓ Architecture match: ARM64"; \
        else \
            echo "✗ WARNING: Architecture mismatch detected!"; \
            echo "  System: $SYSTEM_ARCH, Chrome: $CHROME_ARCH"; \
        fi; \
    else \
        echo "ERROR: Chrome binary not found!" && exit 1; \
    fi \
    && echo "=== Chrome verification successful ==="

# WORKDIR /app

# RUN groupadd -r pptruser && useradd -r -g pptruser -G audio,video pptruser \
#     && mkdir -p /home/pptruser/Downloads \
#     && chown -R pptruser:pptruser /home/pptruser \
#     && chown -R pptruser:pptruser /app

# Run everything after as non-privileged user.
# USER pptruser

# Copy test files and verify Puppeteer works
# WORKDIR /app
# COPY package.json package.json
# COPY index.js index.js
# RUN set -e && npm i && npm start && rm -rf /app/*

# Usage instructions in label
LABEL maintainer="atharvakusumbia@gmail.com" \
      description="Base image with Calibre and Puppeteer pre-installed" \
      version="1.0"