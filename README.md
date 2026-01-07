# Calibre and Puppeteer Base Image

[![Docker Image Version](https://img.shields.io/docker/v/athrvk/calibre-puppeteer-base)](https://hub.docker.com/repository/docker/athrvk/calibre-puppeteer-base/general)

This repository contains a Dockerfile for creating a base image with Calibre and Puppeteer pre-installed. This image is built on top of Ubuntu 24.04 and includes all necessary dependencies for running Calibre and Puppeteer.

## Features

- **Ubuntu 24.04**: The base image is built on the latest LTS version of Ubuntu.
- **Multi-Architecture Support**: Built for both `linux/amd64` and `linux/arm64` platforms.
- **Calibre**: Pre-installed for e-book management and conversion.
- **Puppeteer**: Pre-installed for headless browser automation.
- **Chromium Browser**: System chromium-browser installed for Puppeteer compatibility.
- **Node.js**: Node.js and npm installed from Ubuntu repositories.

## Multi-Architecture Support

This image is built for multiple architectures:
- **linux/amd64** - For x86_64 systems
- **linux/arm64** - For ARM64 systems (e.g., Apple Silicon, AWS Graviton)

Docker will automatically pull the correct image for your platform. You can also explicitly specify the platform:

```sh
docker run --platform linux/amd64 athrvk/calibre-puppeteer-base
docker run --platform linux/arm64 athrvk/calibre-puppeteer-base
```

## Usage

### Pull the Pre-built Image

To pull the latest multi-arch image from Docker Hub:

```sh
docker pull athrvk/calibre-puppeteer-base:latest
```

### Build Locally

To build the Docker image locally for your platform:

```sh
docker build -t calibre-puppeteer-base .
```

To build for a specific platform or multiple platforms:

```sh
# Build for amd64
docker buildx build --platform linux/amd64 -t calibre-puppeteer-base:amd64 .

# Build for arm64
docker buildx build --platform linux/arm64 -t calibre-puppeteer-base:arm64 .

# Build for both platforms
docker buildx build --platform linux/amd64,linux/arm64 -t calibre-puppeteer-base:latest .
```

### Run a Container

To run a container using the built image:

```sh
docker run -it --rm athrvk/calibre-puppeteer-base
```


### Use as Base Image

To use the image as a base for another Dockerfile, include the following line at the top of the file:

```Dockerfile
FROM athrvk/calibre-puppeteer-base:latest
```

## Installed Packages

The Dockerfile installs the following packages and dependencies:

- **System utilities**: `wget`, `curl`, `xz-utils`, `gnupg`
- **X11 and GUI libraries**: Required for running GUI applications in headless mode
- **Calibre**: E-book management and conversion tool (from Ubuntu repository)
- **Chromium Browser**: Installed for Puppeteer compatibility
- **Node.js and npm**: From Ubuntu repository
- **Puppeteer**: Headless browser automation library
- **Font support**: Various international fonts for proper text rendering

## Verifying Installations

The Dockerfile includes steps to verify the installations of Calibre and Node.js:

```sh
# Calibre version
docker run --rm athrvk/calibre-puppeteer-base ebook-convert --version

# Node.js version
docker run --rm athrvk/calibre-puppeteer-base node -v

# npm version
docker run --rm athrvk/calibre-puppeteer-base npm -v

# Chromium browser location
docker run --rm athrvk/calibre-puppeteer-base which chromium-browser
```

## CI/CD

This image is automatically built and pushed to Docker Hub via GitHub Actions whenever changes are pushed to the master branch. The workflow:

1. Sets up QEMU for multi-architecture emulation
2. Configures Docker Buildx for multi-platform builds
3. Builds images for both linux/amd64 and linux/arm64
4. Pushes the images to Docker Hub with version tags and `latest` tag
5. Verifies the installation by running Calibre's `ebook-convert --version`

## Maintainer

This image is maintained by [athrv.k](https://github.com/athrvk).

## License

This project is licensed under the MIT License.
