# Calibre and Puppeteer Base Image

[![Docker Image Version](https://img.shields.io/docker/v/athrvk/calibre-puppeteer-base)](https://hub.docker.com/repository/docker/athrvk/calibre-puppeteer-base/general)

This repository contains a Dockerfile for creating a base image with Calibre and Puppeteer pre-installed. This image is built on top of Ubuntu 22.04 and includes all necessary dependencies for running Calibre and Puppeteer.

## Features

- **Ubuntu 22.04**: The base image is built on the latest LTS version of Ubuntu.
- **Calibre**: Pre-installed for e-book management and conversion.
- **Puppeteer**: Pre-installed for headless browser automation.
- **Node.js**: Latest version of Node.js and npm installed.
- **Non-root User**: The container runs as a non-root user for improved security.

## Usage

To build the Docker image, run the following command in the directory containing the Dockerfile:

```sh
docker build -t calibre-puppeteer-base .
```

To run a container using the built image:

```sh
docker run -it --rm calibre-puppeteer-base
```

To use the image as a base for another Dockerfile, include the following line at the top of the file:

```Dockerfile
FROM athrvk:calibre-puppeteer-base
```

## Installed Packages

The Dockerfile installs the following packages and dependencies:

- Basic utilities: `curl`
- Additional libraries for Calibre and Puppeteer
- Node.js and npm

## Verifying Installations

The Dockerfile includes a step to verify the installations of Calibre and Puppeteer:

- Calibre: `ebook-convert --version`
- Puppeteer: A simple script to launch Puppeteer and log a message

## Maintainer

This image is maintained by [athrv.k](https://github.com/athrvk).

## License

This project is licensed under the MIT License.
