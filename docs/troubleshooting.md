# Problèmes rencontrés et solutions

## 1. Podman rootless

| Symptôme | Cause | Solution |
|---|---|---|
| `cannot find UID/GID for user jenkins` | Pas de plage subuid/subgid | `usermod --add-subuids 100000-165535 --add-subgids 100000-165535 jenkins` puis `podman system migrate` |
| Les conteneurs s'arrêtent après le build | La session de jenkins se termine | `loginctl enable-linger jenkins` |
| Trivy ne trouve pas l'image | Pas de démon Docker | `podman save -o image.tar` puis `trivy image --input image.tar` |

## 2. Ports déjà utilisés

**Symptôme :** `rootlessport listen tcp 0.0.0.0:8081: bind: address already in use` au redéploiement.

**Cause :** le processus `rootlessport` de l'ancien conteneur garde le port ouvert.

**Solution** (intégrée à l'étape *Deploy*) :
```bash
podman-compose stop <service> || true
podman rm -f <conteneur> || true
sudo pkill -9 -f "rootlessport" || true
sleep 5
podman-compose up -d --build <service>
```

**Conflit 8081 :** Nexus et le backend utilisent tous les deux le port 8081. Ils tournent donc sur des VM différentes (.131 et .132).

## 2 bis. Mauvais mapping de ports (corrigé dans `declaris-deploy`)

| Problème | Correction |
|---|---|
| Frontend inaccessible : Nginx écoute sur 4500 mais le mapping était `4500:80` | `4500:4500` |
| Backend inaccessible : Spring Boot écoute en interne sur 8085 | `8081:8085` |

Pour diagnostiquer : `podman port declarisfe` et `podman exec declarisbe netstat -tln` (ou consulter les logs Spring Boot, ligne « Tomcat started on port »).

## 3. Mémoire (RAM)

| Symptôme | Solution |
|---|---|
| Build Angular tué (`JavaScript heap out of memory` / OOM) | Ajouter du swap ou `export NODE_OPTIONS=--max-old-space-size=2048` |
| Backend qui ne démarre pas | Réduire `-Xmx4g` dans le Dockerfile backend (ex. `-Xmx1g`) |
| SonarQube s'arrête (Elasticsearch) | `vm.max_map_count=524288` et au moins 3 Go de RAM pour la VM |

Ajouter du swap :
```bash
sudo fallocate -l 4G /swapfile && sudo chmod 600 /swapfile
sudo mkswap /swapfile && sudo swapon /swapfile
echo '/swapfile none swap defaults 0 0' | sudo tee -a /etc/fstab
```

## 4. Versions de Java

Chaque outil exige sa propre version :

| Outil | Java |
|---|---|
| Jenkins | 21 (fixé comme version par défaut : `alternatives` en mode manuel) |
| SonarQube | 17 (+ `sonar.java.javaOpts=-Djava.security.manager=allow`) |
| Nexus | JRE 1.8 |
| Elasticsearch | JDK embarqué |

La version est fixée **par service** (`JAVA_HOME` dans le fichier systemd), sans changer la version par défaut du système :
```bash
sudo alternatives --config java    # version par défaut du système
ls /usr/lib/jvm/                   # versions installées
```
Dans Jenkins, le pipeline backend utilise `tools { jdk 'JDK21' }`.

## 5. Disque plein

```bash
sudo bash scripts/extend-disk-lvm.sh     # growpart → pvresize → lvextend → xfs_growfs
podman system prune -a                   # supprimer les images inutilisées
```

## 6. Build npm du frontend

Les conflits de dépendances se règlent avec :
```bash
rm -f .npmrc package-lock.json
npm install --legacy-peer-deps --registry https://registry.npmjs.org
```
