#!/usr/bin/env bash
# Installation d'Elasticsearch + Kibana (VM ELK) ou de Filebeat (VM Jenkins).
# Usage : sudo bash install-elk.sh server     → VM ELK
#         sudo bash install-elk.sh filebeat   → VM Jenkins
set -euo pipefail
ROLE="${1:?server | filebeat}"

rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
cat > /etc/yum.repos.d/elastic.repo <<'EOF'
[elastic-8.x]
name=Elastic repository for 8.x packages
baseurl=https://artifacts.elastic.co/packages/8.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
type=rpm-md
EOF

if [ "$ROLE" = "server" ]; then
  # Pas de Logstash : Filebeat envoie directement à Elasticsearch
  dnf install -y elasticsearch kibana
  cp "$(dirname "$0")/../elk/elasticsearch.yml" /etc/elasticsearch/elasticsearch.yml
  systemctl daemon-reload
  systemctl enable --now elasticsearch
  firewall-cmd --permanent --add-port={9200,5601}/tcp && firewall-cmd --reload
  echo "1) Mot de passe elastic :  /usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic"
  echo "2) Jeton d'inscription Kibana :  /usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s kibana"
  echo "3) systemctl enable --now kibana  puis ouvrir http://<IP>:5601 et coller le jeton"
else
  dnf install -y filebeat
  cp "$(dirname "$0")/../elk/filebeat.yml" /etc/filebeat/filebeat.yml
  echo "Stocker le mot de passe elastic dans le keystore (jamais en clair) :"
  echo "  filebeat keystore create && filebeat keystore add ES_PASSWORD"
  echo "Puis : filebeat test output && systemctl enable --now filebeat"
fi
