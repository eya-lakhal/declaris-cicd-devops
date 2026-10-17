# SonarQube — VM 192.168.187.130

| Élément | Valeur |
|---|---|
| URL | `http://192.168.187.130:9000` |
| Java | OpenJDK 17.0.19 |
| Installation | `/opt/sonarqube` |
| Port ouvert | 9000/tcp |
| Projets | `declaris-backend`, `declaris-frontend` |

## Configuration

`sonar.properties` (exporté de la VM) : une seule ligne modifiée par rapport à la configuration par défaut.
```properties
sonar.java.javaOpts=-Djava.security.manager=allow
```

## Démarrage

Pendant le stage, SonarQube était lancé à la main :
```bash
/opt/sonarqube/bin/linux-x86-64/sonar.sh start
```
Pour un démarrage automatique, voir `../systemd/sonarqube.service` (proposition).

## Lien avec Jenkins

Dans Jenkins, le serveur s'appelle **`SonarQube`** et utilise l'identifiant **`sonarqube-token`** (voir `../jenkins/config/`).
