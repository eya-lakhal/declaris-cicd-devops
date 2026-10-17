# Nexus Repository — VM 192.168.187.131

| Élément | Valeur |
|---|---|
| URL | `http://192.168.187.131:8081` |
| Java | JRE 1.8.0 (Nexus) ; Java 17 est la version par défaut du système |
| Installation | `/opt/nexus` + `/opt/sonatype-work/nexus3` |
| Service | `nexus.service` (activé au démarrage) |
| Port ouvert | 8081/tcp |

## Fichiers (exportés de la VM)

| Fichier | Emplacement sur la VM |
|---|---|
| `../systemd/nexus.service` | `/etc/systemd/system/nexus.service` |
| `nexus.rc` | `/opt/nexus/bin/nexus.rc` (utilisateur `nexus`) |
| `nexus.vmoptions` | `/opt/nexus/bin/nexus.vmoptions` (heap 512 Mo → 1 Go) |

```bash
sudo systemctl status nexus
sudo cat /opt/sonatype-work/nexus3/admin.password   # mot de passe initial
```
