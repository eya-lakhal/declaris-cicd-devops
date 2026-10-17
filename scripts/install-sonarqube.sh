#!/usr/bin/env bash
# Installation de SonarQube (Java 17) sur RHEL 9.
# Usage : sudo bash install-sonarqube.sh <version>   ex. 10.6.0.92116
set -euo pipefail
VERSION="${1:?Préciser la version SonarQube}"

dnf install -y java-17-openjdk unzip wget

# Prérequis noyau pour Elasticsearch embarqué
cat > /etc/sysctl.d/99-sonarqube.conf <<'EOF'
vm.max_map_count=524288
fs.file-max=131072
EOF
sysctl --system

useradd -r -m -d /opt/sonarqube -s /bin/bash sonar 2>/dev/null || true
cd /tmp
wget -q "https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-${VERSION}.zip"
unzip -q "sonarqube-${VERSION}.zip"
cp -r "sonarqube-${VERSION}/." /opt/sonarqube/
chown -R sonar:sonar /opt/sonarqube

cp "$(dirname "$0")/../systemd/sonarqube.service" /etc/systemd/system/
systemctl daemon-reload
systemctl enable --now sonarqube

firewall-cmd --permanent --add-port=9000/tcp && firewall-cmd --reload
echo "→ http://$(hostname -I | awk '{print $1}'):9000  (admin / admin au premier login)"
