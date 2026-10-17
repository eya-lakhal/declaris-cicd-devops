# Sécurité

## Scan Trivy dans le pipeline

Podman étant rootless et sans démon, Trivy ne peut pas lire l'image directement. Le pipeline procède donc ainsi :

1. `podman build -t declaris-<app>:scan-temp`
2. `podman save -o /tmp/declaris-<app>-scan.tar`
3. `trivy image --input /tmp/...tar --severity HIGH,CRITICAL`
4. Suppression du `.tar`

## Installation de Trivy (RHEL 9)

```bash
sudo tee /etc/yum.repos.d/trivy.repo <<'EOF'
[trivy]
name=Trivy repository
baseurl=https://aquasecurity.github.io/trivy-repo/rpm/releases/$basearch/
gpgcheck=1
enabled=1
gpgkey=https://aquasecurity.github.io/trivy-repo/rpm/public.key
EOF
sudo dnf install -y trivy
```

## Approbation avant déploiement

Après le scan, Jenkins envoie un e-mail avec la liste des commits et attend une décision (**APPROUVER** / **REFUSER**). Aucun déploiement ne se fait sans validation humaine.

## Gestion des secrets

- Identifiants stockés dans **Jenkins Credentials**, jamais dans le code
- Mot de passe d'application Gmail pour le SMTP
- Vérification avant chaque push : `scripts/check-secrets.sh`
