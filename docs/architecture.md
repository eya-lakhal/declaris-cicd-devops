# Architecture

## Vue d'ensemble

```mermaid
flowchart TB
    subgraph HOST["Hôte Windows — VMware Workstation Pro — réseau 192.168.187.0/24"]
        subgraph VMJ["VM Jenkins · 192.168.187.132"]
            J[Jenkins 2.555.3 :8080<br/>Java 21]
            FB[Filebeat]
            subgraph POD["Podman rootless — réseau declaris-net"]
                BE[declarisbe<br/>8081→8085<br/>Spring Boot]
                FE[declarisfe<br/>4500→4500<br/>Angular + Nginx]
            end
        end
        VMS[VM SonarQube · .130<br/>:9000 · Java 17]
        VMN[VM Nexus · .131<br/>:8081]
        VME[VM ELK · .129<br/>Elasticsearch :9200 HTTPS<br/>Kibana :5601]
    end
    GL[(GitLab.com · eyalakhal-group<br/>declaris-backend<br/>declaris-frontend<br/>declaris-deploy)]
    MAIL[(smtp.gmail.com:465)]

    GL -->|webhook push| J
    J -->|clone| GL
    J -->|analyse| VMS
    J -->|e-mail d'approbation| MAIL
    J -->|podman-compose| POD
    FE -->|/api/| BE
    FB -->|journald + logs conteneurs| VME
```

## Déroulement d'un build

```mermaid
sequenceDiagram
    participant Dev
    participant GitLab
    participant Jenkins
    participant Sonar as SonarQube
    participant Trivy
    participant Valideur
    participant Podman
    Dev->>GitLab: git push (main)
    GitLab->>Jenkins: webhook
    Jenkins->>GitLab: clone (shallow)
    Jenkins->>Jenkins: build Maven / Angular
    Jenkins->>Sonar: analyse qualité
    Jenkins->>Trivy: scan image (HIGH, CRITICAL)
    Jenkins->>Valideur: e-mail + lien d'approbation
    Valideur-->>Jenkins: APPROUVER / REFUSER
    alt approuvé
        Jenkins->>Podman: podman-compose up -d --build
    else refusé
        Jenkins-->>Dev: échec du pipeline
    end
```

## Démarche (manuel → automatisé)

1. **Analyse** de la chaîne CI/CD existante de BNA (blueprint fourni)
2. **Déploiement manuel** avec Docker (`legacy-docker/`)
3. **Pipelines Jenkins** déclenchés par webhook GitLab : build, puis SonarQube
4. **Migration vers Podman** rootless + `podman-compose` et réseau `declaris-net`
5. **Sécurité** : scan Trivy et approbation par e-mail
6. **Supervision** : Filebeat → Elasticsearch (TLS) → Kibana
