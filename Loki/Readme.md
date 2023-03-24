# loki with s3 bucket
## installetion source
https://cloud.yandex.ru/docs/managed-kubernetes/operations/applications/loki#helm-install

## values in default.yaml changet from original
```bash
kubectl create namespace loki
helm upgrade --install loki . --dependency-update -f values.yaml -n loki
```
