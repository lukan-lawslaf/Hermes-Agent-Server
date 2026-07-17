# Portable AI Server

A self-contained, provider-agnostic AI server stack. Runs today on Azure and moves to Oracle Cloud, Hostinger, or any Ubuntu 24.04 VPS with **zero changes** — the only host dependency is Docker.

## Stack

| Service    | Image                    | Role                                  |
|------------|--------------------------|---------------------------------------|
| Ollama     | `ollama/ollama`          | Local LLM inference                   |
| Hermes     | built from `./hermes`    | AI agent application layer            |
| PostgreSQL | `postgres:16-alpine`     | Relational storage                    |
| Qdrant     | `qdrant/qdrant`          | Vector database                       |
| Nginx      | `nginx:stable-alpine`    | Reverse proxy — the only public port  |
| Watchtower | `containrrr/watchtower`  | Automatic container image updates     |

Only Nginx (80/443) is exposed to the internet. Everything else communicates on an internal Docker network.

## Project structure

```
.
├── docker-compose.yml      # The entire stack
├── .env.example            # Configuration template — copy to .env
├── README.md
├── scripts/
│   ├── setup-host.sh       # One-time Ubuntu 24.04 host setup (installs Docker)
│   ├── deploy.sh           # Build + start the stack
│   ├── pull-models.sh      # Pull Ollama models
│   ├── backup.sh           # Tar all named volumes to ./backups/
│   └── restore.sh          # Restore volumes from a backup archive
├── hermes/
│   ├── Dockerfile
│   └── ...                 # Hermes Agent source / config
├── postgres/
│   └── init/               # *.sql / *.sh run once on first startup
├── qdrant/
│   └── config.yaml         # Qdrant production config
└── nginx/
    ├── nginx.conf          # Base nginx config
    └── conf.d/
        └── default.conf    # Reverse-proxy routes
```

## Current status

This repository is scaffolded only. Nothing has been installed, built, pulled,
or started. Deployment will be a separate step after the Hermes Agent image and
production settings are finalized.

## Later deployment prerequisites

The target host is Ubuntu 24.04 with Docker Engine, Docker Compose, and Git.
All application services run in Docker; persistent application state uses named
Docker volumes. No cloud-provider-specific runtime is required.

## Later quick start (any Ubuntu 24.04 host)

```bash
# 1. One-time host setup — installs Docker + Compose, enables firewall basics
sudo bash scripts/setup-host.sh

# 2. Configure
cp .env.example .env
nano .env                # set POSTGRES_PASSWORD, SERVER_NAME, etc.

# 3. Deploy (do not run during repository scaffolding)
bash scripts/deploy.sh

# 4. Pull an LLM
bash scripts/pull-models.sh
```

## Persistent data

All state lives in **named Docker volumes** — nothing is written to host paths:

- `ollama_data` — downloaded models
- `hermes_data` — agent state
- `postgres_data` — database
- `qdrant_data` — vector collections
- `nginx_certs` — TLS certificates

## Moving to another provider

The stack is fully portable. To migrate:

```bash
# On the old server
bash scripts/backup.sh                 # creates backups/<timestamp>.tar.gz

# Copy repo + backup to the new server, then:
sudo bash scripts/setup-host.sh
cp .env.example .env && nano .env      # or copy your existing .env
bash scripts/restore.sh backups/<timestamp>.tar.gz
bash scripts/deploy.sh
```

Point DNS at the new server's IP. Done — no cloud-specific services are used anywhere.

## Updates

Watchtower checks daily (configurable via `WATCHTOWER_POLL_INTERVAL`) and auto-updates containers labeled for it. The locally built `hermes` image is excluded — rebuild it with `docker compose build hermes && docker compose up -d hermes`.

## Operations cheat-sheet

```bash
docker compose ps                      # status
docker compose logs -f hermes          # follow app logs
docker compose exec postgres psql -U hermes   # DB shell
docker compose exec ollama ollama list        # installed models
docker compose down                    # stop (volumes are kept)
```
