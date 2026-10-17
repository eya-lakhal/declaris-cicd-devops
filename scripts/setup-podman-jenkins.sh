#!/usr/bin/env bash
# Prépare Podman rootless pour l'utilisateur jenkins (VM Jenkins).
# Usage : sudo bash setup-podman-jenkins.sh
set -euo pipefail

dnf install -y podman python3-pip git
pip3 install podman-compose

# Plages subuid/subgid nécessaires au mode rootless
grep -q '^jenkins:' /etc/subuid || usermod --add-subuids 100000-165535 jenkins
grep -q '^jenkins:' /etc/subgid || usermod --add-subgids 100000-165535 jenkins

# Les conteneurs de jenkins survivent à la fin de session
loginctl enable-linger jenkins

# Autorisation sudo limitée pour libérer les ports (rootlessport)
cat > /etc/sudoers.d/jenkins-podman <<'EOF'
jenkins ALL=(root) NOPASSWD: /usr/bin/pkill -9 -f rootlessport
EOF
chmod 440 /etc/sudoers.d/jenkins-podman
visudo -cf /etc/sudoers.d/jenkins-podman

# Réseau partagé + dossier de déploiement
sudo -iu jenkins podman system migrate
sudo -iu jenkins podman network exists declaris-net || sudo -iu jenkins podman network create declaris-net
sudo -u jenkins mkdir -p /var/lib/jenkins/declaris
mkdir -p /var/log/declarisbe && chown jenkins:jenkins /var/log/declarisbe

echo "OK. Vérification :"
sudo -iu jenkins podman info --format '{{.Host.Security.Rootless}}'
