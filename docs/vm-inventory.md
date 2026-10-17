# Inventaire des VM

Valeurs relevées sur les VM le 17/10/2026 (`scripts/export-vm-configs.sh`).

| VM | Rôle | IP | OS | RAM | Swap | Disque | Java | Ports ouverts | Services actifs |
|---|---|---|---|---|---|---|---|---|---|
| Jenkins | Jenkins, Podman, Filebeat | 192.168.187.132 | RHEL 9.6 | 1,7 Go | 4 Go | 50 Go | 21.0.11 (+17) | 80, 8000, 8080, 8081, 4500 | jenkins, filebeat |
| SonarQube | SonarQube | 192.168.187.130 | RHEL 9.6 | 3,5 Go | 4 Go | 41 Go | 17.0.19 (+21) | 9000 | (lancé manuellement) |
| Nexus | Nexus Repository | 192.168.187.131 | RHEL 9.6 | 3,5 Go | 4 Go | 40 Go | 17.0.19 + JRE 1.8 | 8081 | nexus |
| ELK | Elasticsearch 8, Kibana | 192.168.187.129 | RHEL 9.8 | 1,6 Go | 4 Go | 40 Go | 17.0.19 | 9200, 5601 | elasticsearch, kibana |

## Paramètres communs

- Hyperviseur : VMware Workstation Pro (hôte Windows), clones d'une même VM RHEL 9
- Réseau : NAT `192.168.187.0/24` (DHCP), interface `ens160`
- Disque NVMe en LVM : `rhel-root`, `rhel-home` (5 Go), `rhel-var`
- Les 4 clones ont le même hostname (`localhost.localdomain`) et la même clé SSH

## Partitions

| VM | `/` | `/var` |
|---|---|---|
| Jenkins | 17 Go (46 %) | 22 Go (54 %) |
| SonarQube | 16 Go (39 %) | 12 Go (23 %) |
| Nexus | 16 Go (37 %) | 12 Go (24 %) |
| ELK | 14 Go (55 %) | 12 Go (16 %) |

## Sauvegardes

| VM | Export OVA | Emplacement |
|---|---|---|
| Jenkins | ☐ | |
| SonarQube | ☐ | |
| Nexus | ☐ | |
| ELK | ☐ | |
