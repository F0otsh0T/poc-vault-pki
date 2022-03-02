# VAULT POLICY

#### POLICY PRIMER
- https://www.vaultproject.io/docs/concepts/policies

#### READ POLICY
CLI:
```
vault read sys/policy                    
Key         Value
---         -----
keys        [basic-secret-policy cert-manager.crudls default global.crudl root]
policies    [basic-secret-policy cert-manager.crudls default global.crudl root]
```
API:
```
curl \
  --header "X-Vault-Token: ..." \
  https://vault.hashicorp.rocks/v1/sys/policy
```




#### WRITE POLICY
CLI:
```
vault policy write policy-name policy-file.hcl
```
API:
```
curl \
  --request POST \
  --header "X-Vault-Token: ..." \
  --data '{"policy":"path \"...\" {...} "}' \
  https://vault.hashicorp.rocks/v1/sys/policy/policy-name

```








#### REFERENCE
- https://www.vaultproject.io/docs/commands/policy
- https://www.vaultproject.io/docs/concepts/policy








