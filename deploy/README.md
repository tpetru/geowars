# Deploying GeoWars to a VPS

Target layout: Ubuntu/Debian VPS, app in `/opt/geowars` owned by a `geowars` user, MariaDB on the
same box, nginx serving the built web client and proxying `/api` (HTTP + WebSocket) to the Node
server on `127.0.0.1:3000`, managed by systemd.

## First-time setup (as root / sudo)

```sh
# 1. Packages: Node 22, MariaDB, nginx, certbot
curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
apt-get install -y nodejs mariadb-server nginx git certbot python3-certbot-nginx

# 2. App user and code
useradd --system --create-home --shell /bin/bash geowars
git clone https://github.com/tpetru/geowars.git /opt/geowars
chown -R geowars:geowars /opt/geowars

# 3. Database: edit CHANGE_ME in db/setup.sql to a strong password first
mysql < /opt/geowars/db/setup.sql

# 4. Config
sudo -u geowars cp /opt/geowars/.env.example /opt/geowars/.env
#    set DB_PASSWORD (same as step 3); COOKIE_SECURE=true once HTTPS is on

# 5. Build world, migrate, seed, build the client
cd /opt/geowars
sudo -u geowars npm ci
sudo -u geowars npm run geo:build
sudo -u geowars npm run db:migrate
sudo -u geowars npm run db:seed -- --speed 1
sudo -u geowars npm run build -w @geowars/web

# 6. Service
cp deploy/geowars.service /etc/systemd/system/
systemctl daemon-reload && systemctl enable --now geowars

# 7. nginx + HTTPS (replace example.com in the file first)
cp deploy/nginx-geowars.conf /etc/nginx/sites-available/geowars
ln -s /etc/nginx/sites-available/geowars /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t && systemctl reload nginx
certbot --nginx -d example.com
# then set COOKIE_SECURE=true in .env and: systemctl restart geowars

# 8. Firewall
ufw allow OpenSSH && ufw allow 'Nginx Full' && ufw enable
```

Allow the `geowars` user to restart its own service without a password, so `deploy.sh` works:

```sh
echo 'geowars ALL=(root) NOPASSWD: /usr/bin/systemctl restart geowars' > /etc/sudoers.d/geowars
```

## Updates

```sh
sudo -u geowars /opt/geowars/deploy/deploy.sh
```

Pulls, installs, runs new migrations, rebuilds the client and restarts the service.

## Checks

- `systemctl status geowars` and `journalctl -u geowars -f` for server logs
- `curl -I http://127.0.0.1:3000/api/...` from the VPS to hit the API directly
- MariaDB stays bound to localhost; nothing but nginx (80/443) and SSH is exposed.
