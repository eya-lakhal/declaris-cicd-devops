# Déploiement Podman — VM Jenkins 192.168.187.132

`podman-compose.yml` est **le fichier réellement utilisé**. C'est le `docker-compose.yml` du dépôt GitLab `declaris-deploy`, exporté de la VM.

## Organisation sur la VM

```
/var/lib/jenkins/declaris/
├── declaris-backend/     ← clone GitLab (contient backend/Dockerfile)
├── declaris-frontend/    ← clone GitLab (contient frontend/Dockerfile + nginx.conf)
└── declaris-deploy/      ← docker-compose.yml (= podman-compose.yml ici)
```

## Conteneurs

| Service | Conteneur | Port hôte → conteneur | Image de base |
|---|---|---|---|
| `declaris-backend` | `declarisbe` | **8081 → 8085** (Spring Boot écoute sur 8085) | `eclipse-temurin:21-jre-alpine` |
| `declaris-frontend` | `declarisfe` | **4500 → 4500** (Nginx écoute sur 4500) | `nginx:alpine` |

- Réseau externe partagé : `declaris-net`
- Logs Nginx montés sur l'hôte : `/var/log/declaris-frontend` (`:Z` pour SELinux), puis collectés par Filebeat

## Historique du dépôt `declaris-deploy`

| Commit | Correction |
|---|---|
| `Fix mapping port 4500 4500` | Le frontend écoutait sur 4500 mais était mappé sur 80 |
| `Fix mapping port backend: 8081:8085` | Spring Boot écoute en interne sur 8085 |

## Commandes

```bash
sudo -iu jenkins
podman network create declaris-net            # une seule fois
cd /var/lib/jenkins/declaris/declaris-deploy
podman-compose up -d --build declaris-backend
podman-compose up -d --build declaris-frontend
podman ps
curl -I http://localhost:4500
```

## Accès

- Frontend : `http://192.168.187.132:4500`
- Backend : `http://192.168.187.132:8081`

## ⚠️ Remarques

- Dans `frontend/nginx.conf`, le proxy `/api/` pointait vers une IP interne BNA, qui a été masquée. Dans l'environnement Podman, la cible correspondante est `http://declarisbe:8085/`.
- Le Dockerfile backend utilise `-Xmx4g`, alors que la VM n'a que 1,7 Go de RAM : c'est le swap qui compense.

La première version Docker se trouve dans `../legacy-docker/`.
