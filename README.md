# CrowdSec Blocklist Import

Dockerized tool to import 28+ public threat feeds directly into CrowdSec. Get 60,000+ threat IPs from premium-quality sources - for free\!

## Features

- **28+ Free Blocklists**: IPsum, Spamhaus, Firehol, Abuse.ch, Emerging Threats, and more
- **Smart Deduplication**: Skips IPs already in CrowdSec (CAPI, Console lists, local detections)
- **Private IP Filtering**: Automatically excludes RFC1918 and reserved ranges
- **Docker Ready**: Run as a container with Docker socket access
- **Cron Friendly**: Designed for daily runs with 24h decision expiration
- **Lightweight**: Single shell script, minimal dependencies

## Included Blocklists

| Source | Description |
|--------|-------------|
| IPsum (level 3+) | Aggregated threat intel (on 3+ blocklists) |
| Spamhaus DROP/EDROP | Known hijacked/malicious netblocks |
| Blocklist.de | IPs reported for various attacks (all/ssh/apache/mail) |
| Firehol level1 + level2 | High confidence bad IPs |
| Feodo Tracker | Banking trojan C2 servers |
| SSL Blacklist | Malicious SSL certificate IPs |
| Emerging Threats | Compromised IPs |
| Binary Defense | Ban list |
| Bruteforce Blocker | SSH/FTP brute force sources |
| DShield | SANS Internet Storm Center top attackers |
| CI Army | Cinsscore bad reputation |
| Darklist | SSH brute force |
| URLhaus | Malware distribution IPs |
| Talos Intelligence | Cisco threat intel |
| Charles Haley | SSH dictionary attacks |
| Botvrij | Botnet C2 IPs |
| myip.ms | Blacklist database |
| GreenSnow | Attacker IPs |
| StopForumSpam | Toxic spam IPs |
| Tor exit nodes | Official Tor Project + dan.me.uk lists |
| Shodan scanners | Known Shodan scanner IPs |
| Censys scanners | Censys scanner IP ranges |

## Quick Start

### Docker Compose (Recommended)

```yaml
version: "3.8"

services:
  crowdsec-blocklist-import:
    image: ghcr.io/wolffcatskyy/crowdsec-blocklist-import:latest
    container_name: crowdsec-blocklist-import
    restart: "no"
    environment:
      - CROWDSEC_CONTAINER=crowdsec
      - DECISION_DURATION=24h
      - TZ=America/New_York
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
```

Run once: `docker compose up`

### Scheduled via Cron (Host)

```bash
# Run daily at 4am
0 4 * * * docker compose -f /path/to/docker-compose.yml up --abort-on-container-exit
```

### Standalone Docker Run

```bash
docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  -e CROWDSEC_CONTAINER=crowdsec \
  ghcr.io/wolffcatskyy/crowdsec-blocklist-import:latest
```

## Configuration

| Environment Variable | Default | Description |
|---------------------|---------|-------------|
| `CROWDSEC_CONTAINER` | `crowdsec` | Name of your CrowdSec container |
| `DECISION_DURATION` | `24h` | How long decisions last (refresh daily) |
| `LOG_LEVEL` | `INFO` | Logging verbosity (DEBUG, INFO, WARN, ERROR) |
| `TZ` | `UTC` | Timezone for logs |

## How It Works

1. **Fetch**: Downloads 28+ blocklists from public sources
2. **Combine**: Merges all IPs and removes duplicates  
3. **Filter**: Excludes private ranges (10.x, 192.168.x, etc.) and known good IPs
4. **Dedupe**: Queries CrowdSec for existing decisions to avoid duplicates
5. **Import**: Bulk imports new IPs via `cscli decisions import`

Decisions are tagged with `external_blocklist` reason for easy identification.

## Viewing Imported Decisions

```bash
# Count imported decisions
docker exec crowdsec cscli decisions list | grep external_blocklist | wc -l

# List by source (in logs)
docker logs crowdsec-blocklist-import

# Remove all imported decisions (if needed)
docker exec crowdsec cscli decisions delete --all --reason external_blocklist
```

## Why Use This?

CrowdSec's free tier includes community threat intel (CAPI) and some console blocklists, but many premium feeds require a paid subscription. This tool gives you:

- **More coverage**: 60k+ IPs vs ~22k from CAPI alone
- **Tor blocking**: Official Tor exit node lists
- **Scanner blocking**: Shodan, Censys, and other mass scanners
- **Zero cost**: All sources are freely available

## Architecture

```
                         ┌─────────────────────┐
                         │  Public Blocklists  │
                         │  (28+ sources)      │
                         └─────────┬───────────┘
                                   │
                                   ▼
┌─────────────────────────────────────────────────────┐
│           crowdsec-blocklist-import                 │
│  ┌─────────┐  ┌──────────┐  ┌─────────────────┐   │
│  │  Fetch  │→ │  Filter  │→ │  Import to CS   │   │
│  └─────────┘  └──────────┘  └─────────────────┘   │
└─────────────────────────────────────────────────────┘
                                   │
                                   ▼
                         ┌─────────────────────┐
                         │     CrowdSec        │
                         │   (decisions DB)    │
                         └─────────────────────┘
                                   │
              ┌────────────────────┼────────────────────┐
              ▼                    ▼                    ▼
        ┌─────────┐          ┌─────────┐          ┌─────────┐
        │ Bouncer │          │ Bouncer │          │ Bouncer │
        │ (NPM)   │          │ (UniFi) │          │ (CF)    │
        └─────────┘          └─────────┘          └─────────┘
```

## Related Projects

- [crowdsec-unifi-bouncer](https://github.com/wolffcatskyy/crowdsec-unifi-bouncer) - Sync CrowdSec decisions to UniFi firewall groups

## License

MIT License - see [LICENSE](LICENSE)

## Contributing

Contributions welcome\! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.
