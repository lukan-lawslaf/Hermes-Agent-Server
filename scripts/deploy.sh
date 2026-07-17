#!/usr/bin/env bash
# ============================================================
# Build and start the full stack.
# ============================================================
set -euo pipefail
cd "$(dirname "$0")/.."

if [[ ! -f .env ]]; then
  echo "ERROR: .env not found. Run: cp .env.example .env  (then edit it)" >&2
  exit 1
fi

echo "==> Validating compose file..."
docker compose config -q

echo "==> Building local images..."
docker compose build

echo "==> Starting stack..."
docker compose up -d

echo
docker compose ps
echo
echo "Deployed. Follow logs with: docker compose logs -f"
