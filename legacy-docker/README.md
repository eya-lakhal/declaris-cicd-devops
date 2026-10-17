# Phase 1 — Déploiement Docker (historique)

Cette première version du déploiement a été conservée pour montrer l'évolution du projet :

| Fichier | Contenu |
|---|---|
| `docker-compose-frontend.yml` | Frontend seul, port 86 |
| `docker-compose-backend.yml` | Backend seul, `network_mode: host`, logs dans `/var/log/declarisbe` |

## Évolution vers Podman

| Docker (phase 1) | Podman (phase 2) |
|---|---|
| Un fichier compose par application | Un seul `podman-compose.yml` |
| `network_mode: host` | Réseau partagé `declaris-net` |
| Démon root | Rootless, sans démon |
| Déploiement manuel | Déploiement automatisé par Jenkins après approbation |

Pour la configuration actuelle, voir `../podman/`.
