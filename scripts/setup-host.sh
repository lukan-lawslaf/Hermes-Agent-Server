#!/usr/bin/env bash
# ============================================================
# One-time host setup for Ubuntu 24.04.
# The ONLY manual dependency of this stack is Docker — this
# script installs it (plus git) and nothing else.
# Works on Azure, Oracle Cloud, Hostinger, or any VPS.
# ============================================================
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Run as root: sudo bash scripts/setup-host.sh" >&2
  exit 1
fi

echo "==> Updating apt and installing prerequisites..."
apt-get update -y
apt-get install -y ca-certificates curl gnupg git

echo "==> Installing Docker Engine + Compose plugin (official Docker repo)..."
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
  https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
  > /etc/apt/sources.list.d/docker.list

apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io \
  docker-buildx-plugin docker-compose-plugin

systemctl enable --now docker

# Let the invoking (non-root) user run docker without sudo
REAL_USER="${SUDO_USER:-}"
if [[ -n "$REAL_USER" && "$REAL_USER" != "root" ]]; then
  usermod -aG docker "$REAL_USER"
  echo "==> Added $REAL_USER to the docker group (re-login to take effect)."
fi

echo "==> Docker versions:"
docker --version
docker compose version

echo
echo "Host setup complete. Next:"
echo "  cp .env.example .env   # then edit it"
echo "  bash scripts/deploy.sh"
