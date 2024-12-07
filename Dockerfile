FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get -qq install -y \
    # Basic utilities
    wget \
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
    libgl1-mesa-glx \
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

# Install Calibre (dynamic version retrieval)
RUN CALIBRE_VERSION=$(curl -sX GET "https://api.github.com/repos/kovidgoyal/calibre/releases/latest" | grep -Po '"tag_name": "\K[^"]*') \
    && CALIBRE_VERSION_NUM=$(echo ${CALIBRE_VERSION} | cut -c2-) \
    && CALIBRE_URL="https://download.calibre-ebook.com/${CALIBRE_VERSION_NUM}/calibre-${CALIBRE_VERSION_NUM}-x86_64.txz" \
    && wget -qO /tmp/calibre-tarball.txz "$CALIBRE_URL" \
    && mkdir -p /opt/calibre \
    && tar -xf /tmp/calibre-tarball.txz -C /opt/calibre \
    && /opt/calibre/calibre_postinstall \
    && rm /tmp/calibre-tarball.txz \
    && dbus-uuidgen > /etc/machine-id


RUN apt-get update \
    && apt-get -qq install -y \
    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
    && apt-get update \
    && apt-get -qq install -y google-chrome-stable fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst fonts-freefont-ttf libxss1 \
        gconf-service libasound2 libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 ca-certificates fonts-liberation libappindicator1 libnss3 lsb-release xdg-utils \
      --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# ENV PUPPETEER_SKIP_DOWNLOAD true

# Install Puppeteer
RUN npm install -g puppeteer
RUN npx puppeteer browsers install chrome --install-deps

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