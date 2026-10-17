#!/usr/bin/env bash
# Rassemble la configuration d'une VM dans une archive, avant sa suppression.
# À lancer sur CHAQUE VM : sudo bash export-vm-configs.sh
# Résultat : ~/export-<hostname>.tar.gz → à copier sur Windows (WinSCP / scp)
set -uo pipefail

H=$(hostname)
OUT="$HOME/export-$H"
mkdir -p "$OUT"
c() { [ -e "$1" ] && cp -r "$1" "$OUT/$2" 2>/dev/null && echo "  ✓ $1"; }

echo "== Système"
{ cat /etc/os-release; echo; ip -4 a; echo; df -h; echo; free -h; echo; lsblk; } > "$OUT/system-info.txt"
java -version 2>"$OUT/java-version.txt"; alternatives --list 2>/dev/null | grep -i java >> "$OUT/java-version.txt"
cp ~/.bash_history "$OUT/history-$H.txt" 2>/dev/null
for u in jenkins sonar nexus; do
  [ -f "/home/$u/.bash_history" ] && cp "/home/$u/.bash_history" "$OUT/history-$u.txt"
done
systemctl list-unit-files --state=enabled > "$OUT/services-enabled.txt"
firewall-cmd --list-all > "$OUT/firewall.txt" 2>/dev/null

echo "== Jenkins"
if [ -d /var/lib/jenkins ]; then
  mkdir -p "$OUT/jenkins/jobs"
  for d in /var/lib/jenkins/jobs/*/; do
    n=$(basename "$d"); cp "$d/config.xml" "$OUT/jenkins/jobs/$n.xml" && echo "  ✓ job $n"
  done
  ls /var/lib/jenkins/plugins/*.jpi 2>/dev/null | xargs -n1 basename | sed 's/\.jpi$//' > "$OUT/jenkins/plugins-installed.txt"
  c /var/lib/jenkins/config.xml jenkins/
  c /var/lib/jenkins/hudson.tasks.Maven.xml jenkins/
  c /var/lib/jenkins/hudson.plugins.sonar.SonarGlobalConfiguration.xml jenkins/
  c /var/lib/jenkins/hudson.plugins.emailext.ExtendedEmailPublisher.xml jenkins/
  c /var/lib/jenkins/declaris/declaris-deploy jenkins/
  c /etc/systemd/system/jenkins.service.d jenkins/
  c /etc/sudoers.d/jenkins-podman jenkins/
  sudo -iu jenkins podman ps -a > "$OUT/jenkins/podman-ps.txt" 2>&1
  sudo -iu jenkins podman images > "$OUT/jenkins/podman-images.txt" 2>&1
  sudo -iu jenkins podman network inspect declaris-net > "$OUT/jenkins/declaris-net.json" 2>&1
fi

echo "== SonarQube / Nexus / ELK"
mkdir -p "$OUT/etc"
c /etc/systemd/system/sonarqube.service etc/
c /etc/systemd/system/nexus.service etc/
c /opt/sonarqube/conf/sonar.properties etc/
c /opt/nexus/bin/nexus.vmoptions etc/
c /opt/nexus/bin/nexus.rc etc/
c /etc/filebeat/filebeat.yml etc/
c /etc/elasticsearch/elasticsearch.yml etc/
c /etc/kibana/kibana.yml etc/
c /etc/logstash/conf.d etc/logstash-conf.d
c /etc/sysctl.d etc/

# Les fichiers credentials.xml / secrets/ de Jenkins ne sont volontairement PAS copiés.
tar czf "$HOME/export-$H.tar.gz" -C "$HOME" "export-$H"
echo
echo "Archive : $HOME/export-$H.tar.gz"
echo "⚠️ Lancer scripts/check-secrets.sh sur le contenu avant de le mettre dans Git."
