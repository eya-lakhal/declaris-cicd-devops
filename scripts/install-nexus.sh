#!/usr/bin/env bash
# Installation de Nexus Repository OSS (Java 8) sur RHEL 9.
# Usage : sudo bash install-nexus.sh <url_archive_nexus_unix.tar.gz>
set -euo pipefail
URL="${1:?Préciser l'URL de l'archive Nexus (unix.tar.gz)}"

dnf install -y java-1.8.0-openjdk wget tar

useradd -r -M -s /bin/bash nexus 2>/dev/null || true
cd /opt
wget -q "$URL" -O nexus.tar.gz
tar xzf nexus.tar.gz && rm -f nexus.tar.gz
mv nexus-3* nexus
chown -R nexus:nexus /opt/nexus /opt/sonatype-work
echo 'run_as_user="nexus"' > /opt/nexus/bin/nexus.rc

cp "$(dirname "$0")/../systemd/nexus.service" /etc/systemd/system/
systemctl daemon-reload
systemctl enable --now nexus

firewall-cmd --permanent --add-port=8081/tcp && firewall-cmd --reload
echo "Mot de passe admin : $(cat /opt/sonatype-work/nexus3/admin.password 2>/dev/null || echo 'disponible après le 1er démarrage')"
