#!/bin/bash
set -euo pipefail

curl -fsSL https://get.docker.com | sh

id ssm-user &>/dev/null || useradd -m ssm-user
usermod -aG docker ssm-user

apt-get update && apt-get install -y docker-compose-plugin

mkdir -p /opt/rackula/data && chown 1001:1001 /opt/rackula/data
cd /opt/rackula
curl -fsSL https://raw.githubusercontent.com/RackulaLives/Rackula/main/deploy/docker-compose.persist.yml -o docker-compose.yml
docker compose up -d