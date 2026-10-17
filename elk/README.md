# Supervision ELK — VM 192.168.187.129

```
VM Jenkins ── Filebeat ──HTTPS──▶ Elasticsearch :9200 ──▶ Kibana :5601
 (journald jenkins + logs conteneurs Podman)
```

> Logstash n'est pas utilisé : Filebeat envoie directement à Elasticsearch.

## Fichiers (exportés des VM, secrets masqués)

| Fichier | VM | Emplacement |
|---|---|---|
| `elasticsearch.yml` | ELK | `/etc/elasticsearch/elasticsearch.yml` |
| `kibana.yml` | ELK | `/etc/kibana/kibana.yml` |
| `filebeat.yml` | Jenkins | `/etc/filebeat/filebeat.yml` |

## Ce qui est collecté

| Input Filebeat | Source | Champ `app` |
|---|---|---|
| `jenkins-journal` | journald, unité `jenkins.service` | — |
| `declaris-nginx-access` | logs des conteneurs Podman (`ctr.log`) | `declaris-frontend-container` |
| `declaris-nginx-error` | `/var/log/nginx/error.log` | `declaris-frontend` |
| `declaris-backend-container` | logs des conteneurs Podman (multiline Spring Boot) | `declaris-backend` |

## Sécurité

- Elasticsearch 8 avec **xpack.security** et **TLS** (`https://`, certificats `http.p12` / `transport.p12`)
- Kibana relié par **service account token** (masqué ici)
- Filebeat : `ssl.verification_mode: none` (certificat auto-signé, environnement de test)

## Remettre en place les secrets

```bash
# VM Jenkins : mot de passe elastic pour Filebeat
sudo filebeat keystore create
sudo filebeat keystore add ES_PASSWORD

# VM ELK : nouveau jeton Kibana
sudo /usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s kibana
```

## Kibana

1. `http://192.168.187.129:5601`, connexion avec `elastic`
2. *Stack Management → Data Views → Create* : `filebeat-*`
3. *Discover* : filtrer par `app : "declaris-backend"`, etc.
