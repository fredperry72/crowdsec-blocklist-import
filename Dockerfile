FROM docker:24-cli

LABEL org.opencontainers.image.source="https://github.com/wolffcatskyy/crowdsec-blocklist-import"
LABEL org.opencontainers.image.description="Import public threat feeds into CrowdSec"
LABEL org.opencontainers.image.licenses="MIT"

RUN apk add --no-cache bash curl coreutils

COPY import.sh /usr/local/bin/import.sh
RUN chmod +x /usr/local/bin/import.sh

ENTRYPOINT ["/usr/local/bin/import.sh"]
