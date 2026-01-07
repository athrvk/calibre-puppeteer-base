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

# Install Node.js and npm
RUN apt-get update \
    && apt-get install -y nodejs npm \
    && rm -rf /var/lib/apt/lists/*

# Install Calibre (using apt package for both architectures)
# Note: For amd64, this uses the Ubuntu package instead of the official binary
# to avoid SSL certificate issues in the build environment
RUN apt-get update \
    && apt-get install -y calibre \
    && rm -rf /var/lib/apt/lists/* \
    && dbus-uuidgen > /etc/machine-id

# Install Chromium (works for both amd64 and arm64)
RUN apt-get update \
    && apt-get -qq install -y chromium-browser \
        fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst fonts-freefont-ttf libxss1 \
        libasound2t64 libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgcc1 libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 ca-certificates fonts-liberation libappindicator3-1 libnss3 lsb-release xdg-utils \
      --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# Install Puppeteer (with browser download skipped)
# Note: SSL verification is temporarily disabled due to certificate chain issues in some build environments
# The strict-ssl setting is restored immediately after installation
RUN npm config set strict-ssl false \
    && PUPPETEER_SKIP_DOWNLOAD=true npm install -g puppeteer \
    && npm config set strict-ssl true
# Install Chrome browser for Puppeteer (skipped - using system chromium-browser)
# RUN npm config set strict-ssl false \
#     && npx puppeteer browsers install chrome --install-deps \
#     && npm config set strict-ssl true

# Verify installations
RUN ebook-convert --version
RUN node -v && npm -v

# WORKDIR /app

# RUN groupadd -r pptruser && useradd -r -g pptruser -G audio,video pptruser \
#     && mkdir -p /home/pptruser/Downloads \
#     && chown -R pptruser:pptruser /home/pptruser \
#     && chown -R pptruser:pptruser /app

# Run everything after as non-privileged user.
# USER pptruser

# COPY package.json package.json
# COPY index.js index.js
# RUN npm i
# RUN npm start
# RUN rm -rf ./*

# Usage instructions in label
LABEL maintainer="atharvakusumbia@gmail.com" \
      description="Base image with Calibre and Puppeteer pre-installed" \
      version="1.0"