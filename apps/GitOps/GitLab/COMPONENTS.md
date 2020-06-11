Core GitLab components:
NGINX Ingress
Registry
GitLab/Gitaly
GitLab/GitLab Exporter
GitLab/GitLab Grafana
GitLab/GitLab Shell
GitLab/Migrations
GitLab/Sidekiq
GitLab/Webservice
Optional dependencies:
PostgreSQL
Redis
MinIO
Optional additions:
Prometheus
Grafana
Unprivileged GitLab Runner using the Kubernetes executor
Automatically provisioned SSL via Let’s Encrypt, using Jetstack’s cert-manager

Stateful 
--------

Gitaly (persists the Git repositories)
PostgreSQL (persists the GitLab database data)
Redis (persists GitLab job data)
MinIO (persists the object storage data)
