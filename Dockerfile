FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    bash \
    bc \
    logrotate \
    && rm -rf /var/lib/apt/lists/*

COPY src/guardian.sh /usr/local/bin/guardian
COPY scripts/setup.sh /usr/local/bin/guardian-setup
COPY config.json /etc/guardian/config.json

RUN chmod +x /usr/local/bin/guardian /usr/local/bin/guardian-setup \
    && mkdir -p /var/log/guardian /var/lib/guardian \
    && guardian-setup

ENTRYPOINT ["guardian"]