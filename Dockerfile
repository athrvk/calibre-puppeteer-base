FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    # Basic utilities
    curl \
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
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm@latest

# Install Calibre
RUN curl -sSL https://download.calibre-ebook.com/linux-installer.sh | sh /dev/stdin

# Install Puppeteer
RUN npm install -g puppeteer

# Create necessary directories and set permissions
RUN mkdir -p /usr/src/app \
    && mkdir -p /usr/src/app/.cache/puppeteer \
    && mkdir -p /usr/src/app/.npm \
    && chown -R nobody:nogroup /usr/src/app

WORKDIR /usr/src/app

# Switch to non-root user
USER nobody

# Verify installations
RUN ebook-convert --version \
    && node -e "const browser = require('puppeteer').launch(); console.log('Puppeteer works')"

# Usage instructions in label
LABEL maintainer="atharvakusumbia@gmail.com" \
      description="Base image with Calibre and Puppeteer pre-installed" \
      version="1.0"