FROM mcr.microsoft.com/vscode/devcontainers/base:debian-12

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install git flex-old bison build-essential csh clangd
