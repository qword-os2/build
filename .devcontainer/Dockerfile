FROM mcr.microsoft.com/devcontainers/python:1-3.9-bullseye
RUN apt-get update && \
    apt-get install -y wget git bash make patch gzip texinfo tar nasm ninja-build autoconf bison gperf autopoint help2man libfuse-dev rsync parted qemu-system && \
    pip3 install meson xbstrap