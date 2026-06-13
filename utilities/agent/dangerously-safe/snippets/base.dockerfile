# apt: ca-certificates, curl, git, locales, procps, less
FROM debian:stable-slim
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
SHELL ["/bin/bash", "-c"]
