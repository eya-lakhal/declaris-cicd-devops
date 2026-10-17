#!/usr/bin/env bash
# Installation de Jenkins (Java 21) + outils de build sur RHEL 9.
# Usage : sudo bash install-jenkins.sh
set -euo pipefail

dnf install -y java-21-openjdk java-21-openjdk-devel git maven wget fontconfig

wget -qO /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
dnf install -y jenkins

# Forcer Jenkins à utiliser Java 21
mkdir -p /etc/systemd/system/jenkins.service.d
cat > /etc/systemd/system/jenkins.service.d/override.conf <<'EOF'
[Service]
Environment="JAVA_HOME=/usr/lib/jvm/java-21-openjdk"
EOF

# Node.js pour le build Angular
dnf module install -y nodejs:20 || dnf install -y nodejs npm

systemctl daemon-reload
systemctl enable --now jenkins

firewall-cmd --permanent --add-port={8080,8081,4500}/tcp
firewall-cmd --reload

echo "Mot de passe initial :"
cat /var/lib/jenkins/secrets/initialAdminPassword
echo "→ http://$(hostname -I | awk '{print $1}'):8080"
