# Configuration Jenkins — VM 192.168.187.132

| Élément | Valeur |
|---|---|
| Version | Jenkins 2.555.3 |
| URL | `http://192.168.187.132:8080` |
| Java | OpenJDK 21.0.11 (JDK `JDK21`) |
| Exécuteurs | 2 |
| Sécurité | Base d'utilisateurs Jenkins, contrôle total une fois connecté |

## Jobs (`jobs/`, exportés de la VM)

| Job | Type | Dépôt | Script | Déclencheur |
|---|---|---|---|---|
| `declaris-backend-pipeline` | Pipeline from SCM | `eyalakhal-group/declaris-backend` (`*/main`) | `Jenkinsfile` | Webhook GitLab (push) |
| `declaris-frontend-pipeline` | Pipeline from SCM | `eyalakhal-group/declaris-frontend` (`*/main`) | `Jenkinsfile` | Webhook GitLab (push) |

Chaque Jenkinsfile est lu **à la racine du dépôt applicatif**. Les copies se trouvent ici : `Jenkinsfile-backend` et `Jenkinsfile-frontend`.

Pour restaurer un job :
```bash
sudo cp jobs/declaris-backend-pipeline.xml /var/lib/jenkins/jobs/declaris-backend-pipeline/config.xml
sudo systemctl restart jenkins
```
(Le `secretToken` du webhook est masqué : il faut le régénérer dans le job, puis le recopier dans GitLab → *Settings → Webhooks*.)

Les deux pipelines déploient depuis `/var/lib/jenkins/declaris/declaris-deploy`, un clone du dépôt GitLab `declaris-deploy` qui contient le compose (voir `../podman/`).

## Plugins

[`plugins.txt`](plugins.txt) liste les **112 plugins installés**. Pour les réinstaller : `jenkins-plugin-cli --plugin-file plugins.txt`.
Principaux plugins : `workflow-aggregator`, `git`, `gitlab-plugin`, `sonar`, `email-ext`, `pipeline-input-step`, `pipeline-maven`, `nexus-artifact-uploader`, `docker-workflow`, `ws-cleanup`, `timestamper`.

## Outils (*Manage Jenkins → Tools*)

| Nom | Valeur |
|---|---|
| `JDK21` | `/usr/lib/jvm/java-21-openjdk-21.0.11.0.10-2.el9.x86_64` |
| Maven | aucune installation déclarée, `mvn` du système |
| `SonarScanner` | utilisé par le pipeline frontend |

## SonarQube (*Manage Jenkins → System*) — `config/`

| Nom | URL | Identifiant |
|---|---|---|
| `SonarQube` | `http://192.168.187.130:9000` | `sonarqube-token` |

⚠️ Jenkins déclare **un seul** serveur, nommé `SonarQube`. Or le fichier `Jenkinsfile-backend` de ce dépôt utilise `sonarqube-server`. La version active dans GitLab (`declaris-backend/Jenkinsfile`) est sans doute plus récente : remplace celle d'ici par la version GitLab.

## Identifiants (*Manage Jenkins → Credentials*)

| ID | Usage |
|---|---|
| `gitlab-git-credentials` | Clone GitLab (utilisateur + token) |
| `sonarqube-token` | Analyse SonarQube |
| `gmail-smtp-v2` | Envoi de l'e-mail d'approbation |

## E-mail (*Extended E-mail Notification*)

`smtp.gmail.com`, port **465**, SSL, UTF-8, identifiant `gmail-smtp-v2` (mot de passe d'application Gmail).

## sudo pour l'utilisateur jenkins

`/etc/sudoers.d/jenkins-podman` (exporté de la VM) : la règle n'autorise **que** cette commande.
```
jenkins ALL=(root) NOPASSWD: /usr/bin/pkill -9 -f rootlessport
```
