# HASHICORP VAULT

## K8s

#### HELM INSTALL
```
# helm install --name vault helm_chart/vault -f helm_chart/vault/values.yaml
```

```
# helm upgrade vault helm_chart/vault -f helm_chart/vault/values.yaml --set Server.ingress.hosts[0].host={vault.10.10.10.179.xip.io}
```










## API

#### GET SECRETS VIA API

###### KV V1
Secret Path: kv1/test
```
curl --request GET \
  --url http://vault.10.10.10.179.xip.io/v1/kv1/test \
  --header 'content-type: application/json' \
  --header 'x-vault-token: {{ TOKEN }}'
```

###### KV V2
Secret Path: afw_kv/vsrx
```
curl --request GET \
  --url http://vault.10.10.10.179.xip.io/v1/afw_kv/data/vsrx \
  --header 'content-type: application/json' \
  --header 'x-vault-token: {{ TOKEN }}'
```