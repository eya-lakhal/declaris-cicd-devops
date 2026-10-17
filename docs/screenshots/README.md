# Captures — démonstration du pipeline

Captures extraites de la vidéo de démonstration ([`../demo/demo-declaris.mp4`](../demo/demo-declaris.mp4), 1 min 41).
Scénario : on modifie la couleur de la page de connexion, puis on suit le changement jusqu'au déploiement automatique.

## 1. Environnement

| | |
|---|---|
| **Page de connexion avant la modification** | ![](01-declaris-login-avant.png) |
| **Tableau de bord Jenkins** : les 2 pipelines | ![](02-jenkins-dashboard.png) |
| **Groupe GitLab `eyalakhal-group`** : back, backend, deploy, frontend | ![](03-gitlab-depots.png) |
| **Nexus Repository** : dépôts maven et nuget | ![](04-nexus.png) |

## 2. Modification et push

| | |
|---|---|
| **`git diff` / `commit` / `push`** : « style: nouvelle couleur de la page de connexion » | ![](05-git-push.png) |
| **Commit visible sur GitLab** (`declaris-frontend`) | ![](06-gitlab-commit.png) |

## 3. Pipeline Jenkins

| | |
|---|---|
| **Job `declaris-frontend-pipeline`** : SonarQube Quality Gate *Passed* | ![](07-jenkins-quality-gate.png) |
| **Build #70 déclenché par le webhook GitLab** | ![](08-jenkins-build-webhook.png) |
| **Analyse SonarScanner** (console) | ![](09-sonarscanner-console.png) |
| **SonarQube** : `declaris-frontend` *Passed* (37k lignes) | ![](10-sonarqube-quality-gate.png) |
| **Rapport Trivy** : image alpine 3.23.5 | ![](11-trivy-rapport.png) |

## 4. Approbation et déploiement

| | |
|---|---|
| **E-mail d'approbation** avec les changements détectés | ![](12-email-approbation.png) |
| **Choix APPROUVER / REFUSER** dans Jenkins | ![](13-jenkins-approbation.png) |
| **Déploiement** : `git pull`, puis `podman-compose` | ![](14-jenkins-deploiement.png) |
| **Pipeline terminé** : `Finished: SUCCESS` | ![](16-pipeline-success.png) |

## 5. Supervision et résultat

| | |
|---|---|
| **Dashboard Kibana « Declaris - Monitoring »** : erreurs backend, top URLs, codes HTTP, volume de logs | ![](15-kibana-dashboard.png) |
| **Page de connexion après le déploiement** : nouvelle couleur | ![](17-declaris-login-apres.png) |
