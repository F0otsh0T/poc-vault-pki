# AUTHENTICATION METHOD: KUBERNETES

##







##









## SET VAULT KUBERNETES AUTHENTICATION METHOD
This part can be confusing as the context of the defined variables below is not well described in the HashiCorp documentation. Verify the following before executing the ```vault write``` step.
- __CONTEXT: NameSpace:__ The JWT token is hard set at the time of writing the HashiCorp Vault Authentication Method for Kubernetes. Since this is read from the ```/var/run/secrets/kubernetes.io/serviceaccount/token``` file (mounted K8s tmpfs File System by the container), the place you execute the ```vault write``` from also needs to be in the same K8s NameSpace as the K8s Deployment/Pod you're attempting to inject the HashiCorp Vault Secrets into.
- __CONTEXT: ServiceAccount:__ HashiCrop Vault HELM Chart creates a K8s ```ServiceAccount``` that gets nested into a K8s ```ClusterRoleBinding``` that has a ```roleRef``` of ```name: system:auth-delegator```. Whatever K8s ```ServiceAccount``` you utilize in your HashiCorp Auth K8s Role, that needs to be nested and defined as ```subject``` in the K8s ```ClusterRoleBinding``` Spec.
  - You can use the ```ServiceAccount``` created by the HELM Chart or another account
  - You will use this ```ServiceAccount``` later in the ```vault write aut/kubernetes/role/{{ ServiceAccount }}``` step
  - E.g. ```vaultdemo-server-binding                               ClusterRole/system:auth-delegator                                                  5d                                                                                         demo/vaultdemo```
- To troubleshoot, you can utilize a JWT decoder like https://jwt.io/ to verify that the ```/var/run/secrets/kubernetes.io/serviceaccount/token``` matches with what you expect in the K8s ```ServiceAccount``` you specified.
  - the ```token_reviewer_jwt``` attribute in the ```auth/kubernetes/config``` is used to validate that the role and K8s ```serviceaccount``` are indeed valid
  - the ```auth/kubernetes/role/[role name]``` 
  
\* NOTE: JWT == JSON Web Token (often pronounced "JOT")

```
# vault write auth/kubernetes/config \
token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
kubernetes_host="https://${KUBERNETES_PORT_443_TCP_ADDR}:443" \
kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
Success! Data written to: auth/kubernetes/config
```

## SET VAULT ROLES FOR KUBERNETES AUTHENTICATION METHOD
This HashiCorp Vault Kubernetes Authentication Method Role and Specs must match the K8s ```ServiceAccount``` and ```ClusterRoleBinding``` from the previous step

```
# vault write auth/kubernetes/role/poc-04-00 \
bound_service_account_names=poc-04-00 \
bound_service_account_namespaces=demo \
policies=global.crudl \
ttl=1h
Success! Data written to: auth/kubernetes/role/poc-04-00
```

```
# vault write auth/kubernetes/role/poc-04-01 \
bound_service_account_names=poc-04-01 \
bound_service_account_namespaces=demo \
policies=global.crudl \
ttl=1h
Success! Data written to: auth/kubernetes/role/poc-04-01
```


## CREATE KUBERNETES SERVICES ACCOUNTS FOR APPLICATION
This step is relevant only if you choose to *NOT* use the K8s ```ServiceAccount``` created by the HashiCorp Vault HELM Chart. Caveats apply for rolling this into the correct K8s ```ClusterRoleBinding```.
```
# kubectl -n demo create -f ./poc-04-00.serviceaccount.yaml
serviceaccount "poc-04-00" created

# kubectl -n demo create -f ./poc-04-01.serviceaccount.yaml
serviceaccount "poc-04-01" created

# kubectl get --all-namespaces -o wide serviceAccount | grep -i poc-04              
demo            poc-04-00                            1         1m
demo            poc-04-01                            1         23s
```

## PATCH DEPLOYMENT TO ANNOTATE POD FOR VAULT SECRETS INJECTION
___IT IS VERY IMPORTANT THAT YOU PATCH THE K8s ```DEPLOYMENT``` RESOURCE WITH THE FOLLOWING SPEC___
```
spec:
  template:
    spec:
      serviceAccountName: vaultdemo
```
^^ The above ```deployment``` spec can be either put into the patch or via the HELM_CHART depending on how you have your CD set up.

Patch the Deployment or modify ```HELM_CHART``` for annotations and ___serviceAccountName___
```
# kubectl -n demo patch deployment poc-04-00 --patch "$(cat poc-04-00.patch_deploy-inject_secrets.yaml)"
deployment.extensions "poc-04-00" patched

# kubectl -n demo patch deployment poc-04-01 --patch "$(cat poc-04-01.patch_deploy-inject_secrets.yaml)"
deployment.extensions "poc-04-01" patched

```



```
from Tristan to everyone:
https://www.vaultproject.io/docs/commands/lease
from Tristan to everyone:
spec:
  template:
    metadata:
      annotations:
        # AGENT INJECTOR SETTINGS
        vault.hashicorp.com/agent-inject: "true"
        ...
        # TLS SERVER CERTIFICATE
        vault.hashicorp.com/agent-inject-secret-server.crt: "pki/issue/hashicorp-com"
        vault.hashicorp.com/agent-inject-template-server.crt: |
          {{- with secret "pki/issue/hashicorp-com" "common_name=www.hashicorp.com" -}}
          {{ .Data.crtificate }}
          {{- end }}
        # TLS SERVER KEY
        vault.hashicorp.com/agent-inject-secret-server.key: "pki/issue/hashicorp-com"
        vault.hashicorp.com/agent-inject-template-server.key: |
          {{- with secret "pki/issue/hashicorp-com" "common_name=www.hashicorp.com" -}}
          {{ .Data.private_key }}
          {{- end }}
        # TLS CA CERTIFICATE
        vault.hashicorp.com/agent-inject-secret-ca.crt: "pki/issue/hashicorp-com"
        vault.hashicorp.com/agent-inject-template-ca.crt: |
          {{- with secret "pki/issu

```

```
        vault.hashicorp.com/agent-inject-secret-kv: hello/poc
        vault.hashicorp.com/agent-inject-secret-cert: pki_int/issue/

```

###### APPENDIX: Check Certs
```
openssl x509 -in ca.certificate -text -noout         
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            67:b7:cc:7b:f9:01:09:c9:48:71:a1:00:97:fe:87:44:16:17:04:46
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: CN = demo.svc.cluster.local
        Validity
            Not Before: Jul  9 21:13:40 2020 GMT
            Not After : Jul  7 21:14:09 2030 GMT
        Subject: CN = demo.svc.cluster.local
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                RSA Public-Key: (2048 bit)
                Modulus:
                    00:ac:05:d1:9f:41:5e:9e:0d:e2:ab:14:ba:48:c4:
                    21:51:a1:da:c3:d3:2a:2a:86:ab:d7:ea:73:91:3f:
                    70:f1:d3:53:d6:93:2f:9e:4d:76:e3:0b:4a:1f:07:
                    74:3e:ac:2d:bd:48:7d:43:5e:c3:f4:1c:85:25:44:
                    d6:de:0b:0c:e9:4c:e9:d2:14:38:49:cc:f1:e5:0b:
                    11:b6:86:6c:ad:5f:57:be:e6:cc:2a:72:af:b0:9a:
                    e8:24:b3:c2:92:51:11:78:e6:67:21:44:3b:bc:e5:
                    d6:4d:dd:56:2d:01:19:28:8f:fa:36:e8:3f:6d:82:
                    cd:9f:26:64:12:ec:a3:6e:7b:b4:ca:cf:fb:fe:a8:
                    2a:c7:32:56:ae:1b:da:65:f7:c1:c5:25:13:22:28:
                    b2:ac:36:e2:f7:4f:99:f3:38:2c:b5:c3:fa:bc:39:
                    0b:1a:b3:5f:33:f9:7a:43:c9:ac:7a:84:fa:cd:01:
                    26:15:b0:b6:e0:d3:fb:f2:a6:08:33:4a:3d:12:46:
                    55:1a:6a:db:2d:b0:ea:f6:b8:87:48:22:e9:ee:fa:
                    f9:ab:f6:8e:8c:8b:96:84:89:e4:d8:3d:14:77:a8:
                    bb:77:3a:f8:b3:f4:a2:22:18:02:c4:ba:15:39:3d:
                    f6:e4:23:7f:10:8a:dd:c7:fc:93:64:07:3d:99:63:
                    d3:e1
                Exponent: 65537 (0x10001)
        X509v3 extensions:
            X509v3 Key Usage: critical
                Certificate Sign, CRL Sign
            X509v3 Basic Constraints: critical
                CA:TRUE
            X509v3 Subject Key Identifier: 
                6A:8F:CD:F4:18:F4:4A:F1:8E:CA:CC:CD:E3:1E:E2:03:CE:9D:94:14
            X509v3 Authority Key Identifier: 
                keyid:6A:8F:CD:F4:18:F4:4A:F1:8E:CA:CC:CD:E3:1E:E2:03:CE:9D:94:14

            X509v3 Subject Alternative Name: 
                DNS:demo.svc.cluster.local
    Signature Algorithm: sha256WithRSAEncryption
         9d:95:05:6f:52:a3:32:3d:b1:50:d5:29:54:48:fc:1a:66:33:
         e7:09:51:b6:d3:91:84:0e:aa:75:60:20:31:02:31:ab:63:77:
         bb:96:01:b7:41:58:5b:f5:30:6d:00:bc:bb:6f:b8:0e:8c:07:
         1f:d6:c3:5a:07:92:06:a2:fd:d9:5a:79:85:5d:bf:1d:18:8a:
         ce:37:38:8d:cf:91:40:b9:54:fa:4f:8a:e5:12:7c:9b:84:99:
         e3:18:17:02:72:59:ac:ec:b6:33:05:1e:9d:7b:3f:b3:c0:a9:
         c5:7e:4f:eb:34:ac:cf:df:d9:05:de:ff:79:c1:31:c3:98:ce:
         ea:f5:e1:bb:61:95:2c:b3:53:6e:18:f9:fd:1a:b3:84:ae:a8:
         ef:8b:48:21:9e:29:5a:a0:85:de:a6:6c:a9:0a:e3:68:7f:e5:
         26:5b:21:bb:5a:f3:2b:61:fd:db:15:7d:ee:14:19:2c:94:f2:
         90:d0:be:d6:f0:06:ab:f9:8c:1e:8c:9c:fe:c3:7a:56:35:2d:
         6b:1d:8f:77:11:ad:3f:9c:ea:53:4a:b9:a1:8d:db:b8:0e:ae:
         4f:50:7f:2d:d8:5e:18:99:b3:53:98:d4:7c:42:d6:fd:37:27:
         55:d1:37:8a:c2:bb:8b:3f:b6:92:c7:6f:ef:6e:ce:eb:c5:ae:
         44:e6:97:c8
```

###### Appendix: Ubuntu Cert Rotation:
```
sudo mv /tmp/files/vault-ca.pem /opt/vault/tls/ca.crt.pem
sudo mv /tmp/files/vault.pem /opt/vault/tls/vault.crt.pem
sudo mv /tmp/files/vault-key.pem /opt/vault/tls/vault.key.pem
sudo cp /opt/vault/tls/ca.crt.pem /usr/local/share/ca-certificates/custom.crt
sudo update-ca-certificates
```

###### Appendix: AUTH/KUBERNETES/ROLE & K8s ServiceAccount Diagnostics
- Variable(s) Key
```
KEY:
"jwt": $KUBE_TOKEN == /var/run/secrets/kubernetes.io/serviceaccount/token
"role": auth/kubernetes/role/[role name] associatd with the ServiceAccount used for Vault/K8s Interaction

$VAULT_ADDR == VAULT API URL
```
- Set Environment Variables
```
# export KUBE_TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token | tr '\r\n' ' ')

# export VAULT_ADDR="http://vaultdemo.demo.svc.cluster.local:8200"
```

```
curl --request POST --data '{"jwt": "'"$KUBE_TOKEN"'", "role": "poc-04-00"}' $VAULT_ADDR/v1/auth/kubernetes/login | jq
curl --request POST --data '{"jwt": "'"$KUBE_TOKEN"'", "role": "poc-04-01"}' $VAULT_ADDR/v1/auth/kubernetes/login | jq
curl --request POST --data '{"jwt": "'"$KUBE_TOKEN"'", "role": "vaultdemo"}' $VAULT_ADDR/v1/auth/kubernetes/login | jq
curl --request POST --data '{"jwt": "'"$KUBE_TOKEN"'", "role": "issuer"}' $VAULT_ADDR/v1/auth/kubernetes/login | jq



curl --request POST \
--data '{"jwt": "'"$KUBE_TOKEN"'", "role": "poc-04-00"}' \
$VAULT_ADDR/v1/auth/kubernetes/login | jq

curl --request POST \
--data '{"jwt": "'"$KUBE_TOKEN"'", "role": "default"}' \
$VAULT_ADDR/v1/auth/kubernetes/login | jq


$(cat /var/run/secrets/kubernetes.io/serviceaccount/token | tr '\r\n' ' ')


export KUBE_TOKEN=eyJhbGciOiJSUzI1NiIsImtpZCI6IjVtM1VVd2VVRWl3OG13M1VDUGNQNFZHdmdWT01FSE9URUZKTWhyV3VvOVEifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJkZW1vIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6InZhdWx0ZGVtby10b2tlbi1rdnRyZiIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50Lm5hbWUiOiJ2YXVsdGRlbW8iLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC51aWQiOiJkZmNmMDZjMS1lZWQ1LTRkMGEtODM2OC1jYmRhN2QxODJmMjAiLCJzdWIiOiJzeXN0ZW06c2VydmljZWFjY291bnQ6ZGVtbzp2YXVsdGRlbW8ifQ.VLOYufnTc7Xq3Sg432_W4y95QMxSHZr11wU0P-Oxz8p80CyR-MpxEbKSHMxM8_yfkHeBzaXSenrDNTQD2Mk6O2y7yspJOYFB9r5WJUzTRUBajYUg0x26lS_dIFVFxvbWeo_7hbGVy_wOppQd8yRlB_Hx9qVvbtDTQp91hgIkTc1lm3el21qnvlBEcq2uRE1SkApQXiW6gwIzZaD-w169pLDkV6ZuktCR1V7Ku5hHCvp5N54V0d0oDnFlpgShy0HYUeKQPW235ZgRMy4H3JQciMNxojTjzhrvzczefRws80BkKFDwz3zcKR4UEbwcGVA3dYQSbDfwwbWwbLEcucvAAA

^^ should be the JWT token in /var/run/secrets/kubernetes.io/serviceaccount/token
$(cat /var/run/secrets/kubernetes.io/serviceaccount/token | tr '\r\n' ' ')


export VAULT_TOKEN=s.YvQlKJZ3cnxShyQyjGJzAksR
export VAULT_ADDR="http://vaultdemo.demo.svc.cluster.local:8200"








vault write auth/kubernetes/config \
token_reviewer_jwt="$KUBE_TOKEN" \
kubernetes_host="https://${KUBERNETES_PORT_443_TCP_ADDR}:443" \
kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt


```