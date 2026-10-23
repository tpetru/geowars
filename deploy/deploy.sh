#!/usr/bin/env bash
# Build and (re)start GeoWars on the VPS. Run from /opt/geowars as the geowars user
# (or with sudo for the restart step). First-time setup is in deploy/README.md.
set -euo pipefail
cd "$(dirname "$0")/.."

git pull --ff-only
npm ci

# World data: only rebuilt when missing (downloads Natural Earth + GeoNames)
if [ ! -f apps/web/public/geo/countries.geojson ]; then
  npm run geo:build
fi

npm run db:migrate
npm run build -w @geowars/web

sudo systemctl restart geowars
echo "Deployed $(git rev-parse --short HEAD)"
