# VAULT: CONSUL SERVICE MESH SIDE CAR

##




##

#### 1. CONSUL SERVICE MESH
Install Consul Service Mesh infrastructure either as VM's or in a K8s environment
#### 2. APPLICATION ANNOTATION
Annotate Application Deployment Spec with the following example:
```

```
#### 3. VAULT TOKEN
Generate or utilize Vault Token for Consul to Vault access for PKI Engine.

###### Create Policy
```
# vault policy write consul.crudl p.consul.crudl.hcl 
Success! Uploaded policy: consul.crudl

# vault policy read consul.crudl
# Allow management of secrets path pki (crudls)
path "pki/*" {
    capabilities = ["create", "read", "update", "delete", "list"]
}

# Allow management of secrets path pki_int (crudls)
path "pki_int/*" {
    capabilities = ["create", "read", "update", "delete", "list"]
}
```

###### Create Token
```
# vault token create -policy=consul.crudl -no-default-policy -orphan -ttl=768h
Key                  Value
---                  -----
token                {{ TOKEN }}
token_accessor       {{ TOKEN_ACCESSOR }}
token_duration       768h
token_renewable      true
token_policies       ["consul.crudl"]
identity_policies    []
policies             ["consul.crudl"]
```
^^ {{ TOKEN }} will be used in the Consul Configurations for VAULT Integrations

#### CONSUL UTILIZATION OF VAULT FOR CA
###### Reference:
  - https://www.consul.io/docs/k8s/connect/connect-ca-provider
  - https://www.consul.io/docs/connect/ca/vault#configuration

###### Create Configuration JSON
```
{
  "connect": [
    {
      "enabled": true,
      "ca_provider": "vault",
      "ca_config": [
        {
          "address": "http://vaultdemo.demo.svc.cluster.local:8200",
          "intermediate_pki_path": "poc5b/consul_connect_intermediate",
          "root_pki_path": "pki",
          "token": ""
        }
      ]
    }
  ]
}


```
```
connect {
  enabled = true
  ca_provider = "vault"
  ca_config {
    address = "http://[VAULT URL]:8200"
    token = "..."
    root_pki_path = "[PKI ENGINE PATH]"
    intermediate_pki_path = "[PKI_INT ENGINE PATH]"
    }
}
```

###### Create K8s Secret from Configuration JSON
```
# kubectl create secret generic vault-config --from-file=config=vault-config.json
secret/vault-config created
```

###### MODIFY CONSUL MANIFEST / HELM CHART TO MOUNT CONFIGURATION VIA EXTRAVOLUMES PATTERN
```values.yaml```
```
  extraVolumes: []
    - type: secret
      name: vault-config
      load: true
      items:
        - key: config
          path: vault-config.json
```

###### HELM INSTALL / UPGRADE WITH ABOVE MODIFICATIONS

```
# helm upgrade consul . -f values.yaml --set global.name=consul
Release "consul" has been upgraded. Happy Helming!
NAME: consul
LAST DEPLOYED: Thu Oct 29 23:50:34 2020
NAMESPACE: default
STATUS: deployed
REVISION: 4
NOTES:
Thank you for installing HashiCorp Consul!

Now that you have deployed Consul, you should look over the docs on using 
Consul with Kubernetes available here: 

https://www.consul.io/docs/platform/k8s/index.html


Your release is named consul.

To learn more about the release if you are using Helm 2, run:

  $ helm status consul
  $ helm get consul

To learn more about the release if you are using Helm 3, run:

  $ helm status consul
  $ helm get all consul
```


#### CREATE INTENTIONS (SECURITY POLICY) TO ALLOW COMMUNICATION BETWEEN APPLICATIONS
```
# consul intention create -allow poc-03-00 poc-03-01
Created: poc-03-00 => poc-03-01 (allow)

# consul intention create -allow poc-03-01 poc-03-00
Created: poc-03-01 => poc-03-00 (allow)
```


## REFERENCE
- https://www.consul.io/docs/connect/ca/vault
- asdf





```
# kga all | grep -i consul | grep -i server                                                       
default            pod/consul-server-0                                                  1/1     Running            0          27d    10.47.0.17       k8snode004   <none>           <none>
default            pod/consul-server-1                                                  1/1     Running            0          23d    10.43.128.1      k8snode003   <none>           <none>
default            pod/consul-server-2                                                  0/1     CrashLoopBackOff   1          26s    10.40.0.6        k8snode006   <none>           <none>
default            service/consul-server                                   ClusterIP      None             <none>           8500/TCP,8301/TCP,8301/UDP,8302/TCP,8302/UDP,8300/TCP,8600/TCP,8600/UDP   27d    app=consul,component=server,release=consul
default            service/consul-ui                                       ClusterIP      10.111.33.175    <none>           80/TCP                                                                    27d    app=consul,component=server,release=consul
default     statefulset.apps/consul-server                        2/3     27d    consul                       consul:1.8.2
 user@k8snode001  23:51:24  ~/git/poc/poc-consul-cd-poc5b/helm_chart/v0.24.1   development 
 k logs pod/consul-server-2                                        
==> Error parsing /consul/userconfig/vault-config/..2020_10_29_23_50_59.742786779/vault-config.json: 1 error(s) decoding:

* 'connect.enabled' expected type 'bool', got unconvertible type 'string'
```




```
consul connect ca set-config -config-file
 /tmp/config-api.json
```

```
# curl http://127.0.0.1:8500/v1/connect/ca/roots | jq
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--100  5436    0  5436    0     0   108k      0 --:--:-- --:--:-- --:--:--  108k
{
  "ActiveRootID": "9c:e9:56:1f:bf:42:df:9d:4f:5e:a3:99:1f:a4:cf:76:bf:4e:ad:29",
  "TrustDomain": "99a02990-6180-e8e0-2404-c652e8bfc8ae.consul",
  "Roots": [
    {
      "ID": "0a:dc:00:a1:a2:02:7e:e4:ef:b8:ac:93:0e:f6:92:f2:ec:46:a7:8c",
      "Name": "Consul CA Root Cert",
      "SerialNumber": 15,
      "SigningKeyID": "c1:55:6c:bf:6d:e6:50:f9:f6:d7:f4:5d:72:d0:89:5c:f3:d0:21:4d:c0:55:0f:0c:4b:61:1e:3d:1e:c7:fa:35",
      "ExternalTrustDomain": "99a02990-6180-e8e0-2404-c652e8bfc8ae",
      "NotBefore": "2020-10-02T00:18:50Z",
      "NotAfter": "2030-10-02T00:18:50Z",
      "RootCert": "-----BEGIN CERTIFICATE-----\nMIICDzCCAbWgAwIBAgIBDzAKBggqhkjOPQQDAjAxMS8wLQYDVQQDEyZwcmktaGNp\nd2MxdGguY29uc3VsLmNhLjk5YTAyOTkwLmNvbnN1bDAeFw0yMDEwMDIwMDE4NTBa\nFw0zMDEwMDIwMDE4NTBaMDExLzAtBgNVBAMTJnByaS1oY2l3YzF0aC5jb25zdWwu\nY2EuOTlhMDI5OTAuY29uc3VsMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEPVJF\n7m3oVlqc3vWz5zc+B+07a+mWejYlAQbY6dXyaLL1fNgocvBTLf0ysSvu2Aa2s+4S\n8+IjQEs7pmihlUUpZKOBvTCBujAOBgNVHQ8BAf8EBAMCAYYwDwYDVR0TAQH/BAUw\nAwEB/zApBgNVHQ4EIgQgwVVsv23mUPn21/RdctCJXPPQIU3AVQ8MS2EePR7H+jUw\nKwYDVR0jBCQwIoAgwVVsv23mUPn21/RdctCJXPPQIU3AVQ8MS2EePR7H+jUwPwYD\nVR0RBDgwNoY0c3BpZmZlOi8vOTlhMDI5OTAtNjE4MC1lOGUwLTI0MDQtYzY1MmU4\nYmZjOGFlLmNvbnN1bDAKBggqhkjOPQQDAgNIADBFAiEAjfurq4FuYOFvfaBKmIRb\ntjRaCo+SoHMZOJLwpwN+EmACIAGTbiZ0rzRtT1V4vb3YyTqPCPfc+rt30V4pF8Zt\nXgL0\n-----END CERTIFICATE-----\n",
      "IntermediateCerts": null,
      "Active": false,
      "PrivateKeyType": "ec",
      "PrivateKeyBits": 256,
      "CreateIndex": 17,
      "ModifyIndex": 4101794
    },
    {
      "ID": "9c:e9:56:1f:bf:42:df:9d:4f:5e:a3:99:1f:a4:cf:76:bf:4e:ad:29",
      "Name": "Vault CA Root Cert",
      "SerialNumber": 10952340070309759000,
      "SigningKeyID": "6a:8f:cd:f4:18:f4:4a:f1:8e:ca:cc:cd:e3:1e:e2:03:ce:9d:94:14",
      "ExternalTrustDomain": "99a02990-6180-e8e0-2404-c652e8bfc8ae",
      "NotBefore": "2020-07-09T21:13:40Z",
      "NotAfter": "2030-07-07T21:14:09Z",
      "RootCert": "-----BEGIN CERTIFICATE-----\nMIIDWDCCAkCgAwIBAgIUZ7fMe/kBCclIcaEAl/6HRBYXBEYwDQYJKoZIhvcNAQEL\nBQAwITEfMB0GA1UEAxMWZGVtby5zdmMuY2x1c3Rlci5sb2NhbDAeFw0yMDA3MDky\nMTEzNDBaFw0zMDA3MDcyMTE0MDlaMCExHzAdBgNVBAMTFmRlbW8uc3ZjLmNsdXN0\nZXIubG9jYWwwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCsBdGfQV6e\nDeKrFLpIxCFRodrD0yoqhqvX6nORP3Dx01PWky+eTXbjC0ofB3Q+rC29SH1DXsP0\nHIUlRNbeCwzpTOnSFDhJzPHlCxG2hmytX1e+5swqcq+wmugks8KSURF45mchRDu8\n5dZN3VYtARkoj/o26D9tgs2fJmQS7KNue7TKz/v+qCrHMlauG9pl98HFJRMiKLKs\nNuL3T5nzOCy1w/q8OQsas18z+XpDyax6hPrNASYVsLbg0/vypggzSj0SRlUaatst\nsOr2uIdIIunu+vmr9o6Mi5aEieTYPRR3qLt3Oviz9KIiGALEuhU5PfbkI38Qit3H\n/JNkBz2ZY9PhAgMBAAGjgYcwgYQwDgYDVR0PAQH/BAQDAgEGMA8GA1UdEwEB/wQF\nMAMBAf8wHQYDVR0OBBYEFGqPzfQY9ErxjsrMzeMe4gPOnZQUMB8GA1UdIwQYMBaA\nFGqPzfQY9ErxjsrMzeMe4gPOnZQUMCEGA1UdEQQaMBiCFmRlbW8uc3ZjLmNsdXN0\nZXIubG9jYWwwDQYJKoZIhvcNAQELBQADggEBAJ2VBW9SozI9sVDVKVRI/BpmM+cJ\nUbbTkYQOqnVgIDECMatjd7uWAbdBWFv1MG0AvLtvuA6MBx/Ww1oHkgai/dlaeYVd\nvx0Yis43OI3PkUC5VPpPiuUSfJuEmeMYFwJyWazstjMFHp17P7PAqcV+T+s0rM/f\n2QXe/3nBMcOYzur14bthlSyzU24Y+f0as4SuqO+LSCGeKVqghd6mbKkK42h/5SZb\nIbta8yth/dsVfe4UGSyU8pDQvtbwBqv5jB6MnP7DelY1LWsdj3cRrT+c6lNKuaGN\n27gOrk9Qfy3YXhiZs1OY1HxC1v03J1XRN4rCu4s/tpLHb+9uzuvFrkTml8g=\n-----END CERTIFICATE-----",
      "IntermediateCerts": [
        "-----BEGIN CERTIFICATE-----\nMIICoDCCAkagAwIBAgIBNDAKBggqhkjOPQQDAjAxMS8wLQYDVQQDEyZwcmktaGNp\nd2MxdGguY29uc3VsLmNhLjk5YTAyOTkwLmNvbnN1bDAeFw0yMDExMTgyMzU4Mjda\nFw0yMDExMjUyMzU4MjdaMCExHzAdBgNVBAMTFmRlbW8uc3ZjLmNsdXN0ZXIubG9j\nYWwwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCsBdGfQV6eDeKrFLpI\nxCFRodrD0yoqhqvX6nORP3Dx01PWky+eTXbjC0ofB3Q+rC29SH1DXsP0HIUlRNbe\nCwzpTOnSFDhJzPHlCxG2hmytX1e+5swqcq+wmugks8KSURF45mchRDu85dZN3VYt\nARkoj/o26D9tgs2fJmQS7KNue7TKz/v+qCrHMlauG9pl98HFJRMiKLKsNuL3T5nz\nOCy1w/q8OQsas18z+XpDyax6hPrNASYVsLbg0/vypggzSj0SRlUaatstsOr2uIdI\nIunu+vmr9o6Mi5aEieTYPRR3qLt3Oviz9KIiGALEuhU5PfbkI38Qit3H/JNkBz2Z\nY9PhAgMBAAGjgZMwgZAwDgYDVR0PAQH/BAQDAgEGMA8GA1UdEwEB/wQFMAMBAf8w\nHQYDVR0OBBYEFGqPzfQY9ErxjsrMzeMe4gPOnZQUMCsGA1UdIwQkMCKAIMFVbL9t\n5lD59tf0XXLQiVzz0CFNwFUPDEthHj0ex/o1MCEGA1UdEQQaMBiCFmRlbW8uc3Zj\nLmNsdXN0ZXIubG9jYWwwCgYIKoZIzj0EAwIDSAAwRQIgREqwoe3XHRKY0Af4S/Mp\nIUAxdWMAo5H0IGjuDwt9Cb0CIQCY8eIfjvM85aD/aR2VVb+kO27LgZvh3YmGySO7\nkVN2qA==\n-----END CERTIFICATE-----\n",
        "-----BEGIN CERTIFICATE-----\nMIIDfzCCAmegAwIBAgIUS5hYtQk/5zSVAhEbA+8nZD+l/xgwDQYJKoZIhvcNAQEL\nBQAwITEfMB0GA1UEAxMWZGVtby5zdmMuY2x1c3Rlci5sb2NhbDAeFw0yMDExMTgy\nMzU4NTdaFw0yMDEyMjAyMzU5MjdaMC8xLTArBgNVBAMTJHByaS15dmdia2F4LnZh\ndWx0LmNhLjk5YTAyOTkwLmNvbnN1bDBZMBMGByqGSM49AgEGCCqGSM49AwEHA0IA\nBJiWAlbp5vqFi+8FFGR+goQ2WPkqtWeAY5cevmB8KBt+J1evt1pCdBM7y/Y296/J\n8kgwSuoxubiMYqqjr70cu2KjggFqMIIBZjAOBgNVHQ8BAf8EBAMCAQYwDwYDVR0T\nAQH/BAUwAwEB/zAdBgNVHQ4EFgQUa/jyNy8orJYtspv70M/UYkGKkm0wHwYDVR0j\nBBgwFoAUao/N9Bj0SvGOyszN4x7iA86dlBQwUgYIKwYBBQUHAQEERjBEMEIGCCsG\nAQUFBzAChjZodHRwOi8vdmF1bHRkZW1vLmRlbW8uc3ZjLmNsdXN0ZXIubG9jYWw6\nODIwMC92MS9wa2kvY2EwSAYDVR0fBEEwPzA9oDugOYY3aHR0cDovL3ZhdWx0ZGVt\nby5kZW1vLnN2Yy5jbHVzdGVyLmxvY2FsOjgyMDAvdjEvcGtpL2NybDBlBgNVHREE\nXjBcgiRwcmkteXZnYmtheC52YXVsdC5jYS45OWEwMjk5MC5jb25zdWyGNHNwaWZm\nZTovLzk5YTAyOTkwLTYxODAtZThlMC0yNDA0LWM2NTJlOGJmYzhhZS5jb25zdWww\nDQYJKoZIhvcNAQELBQADggEBAHIEK4XLG3xjnJIQ7OPOUfNIRHNO8ZRG9+RUwnmf\nyIKdPJzixogJIWoKZFxMjOqioQA2WKDfvPjxRU/JOwRTNs6O7gX/jRHn6reTdJ+C\nt61+rENZngNrhNV2Ew5LtVS+3FeE3nsXaMkatzfq8J0i9PVeIQwcoKA545muqA/z\ndgrlmpSbfk7m4o2CoGZxlKgs3KI92QgErJXVeCV/aIgCxXVCVp3g9Z8HA/khPif2\n2mkJAIH2Khg+hYwKCHVku/dBjwNcH7PIfa1BcuVv4sxUg4LKNKT5/ZQVMRYpAp9B\nxUUaoxHc+Nb1nzE70iD/SRVwdma63SgiRajylMKq4nCKk7I=\n-----END CERTIFICATE-----"
      ],
      "Active": true,
      "PrivateKeyType": "rsa",
      "PrivateKeyBits": 2048,
      "CreateIndex": 4101794,
      "ModifyIndex": 4101794
    }
  ]
}
```


CONSUL GUI => Service => Service (POC-03-00) => Instance (Click on Instance shown that maps to the K8s Pod) => Proxy Info => Top "Proxy Public Listener" => Grab "Output" IP:PORT
```
# openssl s_client -showcerts -connect 10.44.0.20:20000
CONNECTED(00000003)
depth=2 CN = demo.svc.cluster.local
verify error:num=20:unable to get local issuer certificate
139754122000024:error:14094410:SSL routines:ssl3_read_bytes:sslv3 alert handshake failure:s3_pkt.c:1487:SSL alert number 40
139754122000024:error:140790E5:SSL routines:ssl23_write:ssl handshake failure:s23_lib.c:177:
---
Certificate chain
 0 s:/CN=poc0300.svc.default.99a02990.consul
   i:/CN=pri-yvgbkax.vault.ca.99a02990.consul
-----BEGIN CERTIFICATE-----
MIICWzCCAgGgAwIBAgIUGtrNreW4Iq/8MdsnaFSakEeouDIwCgYIKoZIzj0EAwIw
LzEtMCsGA1UEAxMkcHJpLXl2Z2JrYXgudmF1bHQuY2EuOTlhMDI5OTAuY29uc3Vs
MB4XDTIwMTExOTAwMDkyOFoXDTIwMTEyMjAwMDk1OFowLjEsMCoGA1UEAxMjcG9j
MDMwMC5zdmMuZGVmYXVsdC45OWEwMjk5MC5jb25zdWwwWTATBgcqhkjOPQIBBggq
hkjOPQMBBwNCAARM2f97Ci2PmfJC1Li/u0SSUS83wpSgfJioxaC3fENuYdTo0Det
PuC5C5bGo+0DcFyBr5JdQ6keOZ2FIhjRIzUqo4H7MIH4MA4GA1UdDwEB/wQEAwID
qDAdBgNVHSUEFjAUBggrBgEFBQcDAQYIKwYBBQUHAwIwHQYDVR0OBBYEFHT8ksqS
um5I2hg9qrP5mJlIdl+6MB8GA1UdIwQYMBaAFGv48jcvKKyWLbKb+9DP1GJBipJt
MIGGBgNVHREEfzB9giNwb2MwMzAwLnN2Yy5kZWZhdWx0Ljk5YTAyOTkwLmNvbnN1
bIZWc3BpZmZlOi8vOTlhMDI5OTAtNjE4MC1lOGUwLTI0MDQtYzY1MmU4YmZjOGFl
LmNvbnN1bC9ucy9kZWZhdWx0L2RjL3JkbTViL3N2Yy9wb2MtMDMtMDAwCgYIKoZI
zj0EAwIDSAAwRQIhANf+nCH0e7jNI1PPDbhQDHxsEecCGOmhVc2Ki6m1cYupAiBe
KBEKF3+E7/T1+32mfF0bT1pBNwQlFwhLv4/G618dmA==
-----END CERTIFICATE-----
 1 s:/CN=pri-yvgbkax.vault.ca.99a02990.consul
   i:/CN=demo.svc.cluster.local
-----BEGIN CERTIFICATE-----
MIIDfzCCAmegAwIBAgIUS5hYtQk/5zSVAhEbA+8nZD+l/xgwDQYJKoZIhvcNAQEL
BQAwITEfMB0GA1UEAxMWZGVtby5zdmMuY2x1c3Rlci5sb2NhbDAeFw0yMDExMTgy
MzU4NTdaFw0yMDEyMjAyMzU5MjdaMC8xLTArBgNVBAMTJHByaS15dmdia2F4LnZh
dWx0LmNhLjk5YTAyOTkwLmNvbnN1bDBZMBMGByqGSM49AgEGCCqGSM49AwEHA0IA
BJiWAlbp5vqFi+8FFGR+goQ2WPkqtWeAY5cevmB8KBt+J1evt1pCdBM7y/Y296/J
8kgwSuoxubiMYqqjr70cu2KjggFqMIIBZjAOBgNVHQ8BAf8EBAMCAQYwDwYDVR0T
AQH/BAUwAwEB/zAdBgNVHQ4EFgQUa/jyNy8orJYtspv70M/UYkGKkm0wHwYDVR0j
BBgwFoAUao/N9Bj0SvGOyszN4x7iA86dlBQwUgYIKwYBBQUHAQEERjBEMEIGCCsG
AQUFBzAChjZodHRwOi8vdmF1bHRkZW1vLmRlbW8uc3ZjLmNsdXN0ZXIubG9jYWw6
ODIwMC92MS9wa2kvY2EwSAYDVR0fBEEwPzA9oDugOYY3aHR0cDovL3ZhdWx0ZGVt
by5kZW1vLnN2Yy5jbHVzdGVyLmxvY2FsOjgyMDAvdjEvcGtpL2NybDBlBgNVHREE
XjBcgiRwcmkteXZnYmtheC52YXVsdC5jYS45OWEwMjk5MC5jb25zdWyGNHNwaWZm
ZTovLzk5YTAyOTkwLTYxODAtZThlMC0yNDA0LWM2NTJlOGJmYzhhZS5jb25zdWww
DQYJKoZIhvcNAQELBQADggEBAHIEK4XLG3xjnJIQ7OPOUfNIRHNO8ZRG9+RUwnmf
yIKdPJzixogJIWoKZFxMjOqioQA2WKDfvPjxRU/JOwRTNs6O7gX/jRHn6reTdJ+C
t61+rENZngNrhNV2Ew5LtVS+3FeE3nsXaMkatzfq8J0i9PVeIQwcoKA545muqA/z
dgrlmpSbfk7m4o2CoGZxlKgs3KI92QgErJXVeCV/aIgCxXVCVp3g9Z8HA/khPif2
2mkJAIH2Khg+hYwKCHVku/dBjwNcH7PIfa1BcuVv4sxUg4LKNKT5/ZQVMRYpAp9B
xUUaoxHc+Nb1nzE70iD/SRVwdma63SgiRajylMKq4nCKk7I=
-----END CERTIFICATE-----
 2 s:/CN=demo.svc.cluster.local
   i:/CN=pri-hciwc1th.consul.ca.99a02990.consul
-----BEGIN CERTIFICATE-----
MIICoDCCAkagAwIBAgIBNDAKBggqhkjOPQQDAjAxMS8wLQYDVQQDEyZwcmktaGNp
d2MxdGguY29uc3VsLmNhLjk5YTAyOTkwLmNvbnN1bDAeFw0yMDExMTgyMzU4Mjda
Fw0yMDExMjUyMzU4MjdaMCExHzAdBgNVBAMTFmRlbW8uc3ZjLmNsdXN0ZXIubG9j
YWwwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCsBdGfQV6eDeKrFLpI
xCFRodrD0yoqhqvX6nORP3Dx01PWky+eTXbjC0ofB3Q+rC29SH1DXsP0HIUlRNbe
CwzpTOnSFDhJzPHlCxG2hmytX1e+5swqcq+wmugks8KSURF45mchRDu85dZN3VYt
ARkoj/o26D9tgs2fJmQS7KNue7TKz/v+qCrHMlauG9pl98HFJRMiKLKsNuL3T5nz
OCy1w/q8OQsas18z+XpDyax6hPrNASYVsLbg0/vypggzSj0SRlUaatstsOr2uIdI
Iunu+vmr9o6Mi5aEieTYPRR3qLt3Oviz9KIiGALEuhU5PfbkI38Qit3H/JNkBz2Z
Y9PhAgMBAAGjgZMwgZAwDgYDVR0PAQH/BAQDAgEGMA8GA1UdEwEB/wQFMAMBAf8w
HQYDVR0OBBYEFGqPzfQY9ErxjsrMzeMe4gPOnZQUMCsGA1UdIwQkMCKAIMFVbL9t
5lD59tf0XXLQiVzz0CFNwFUPDEthHj0ex/o1MCEGA1UdEQQaMBiCFmRlbW8uc3Zj
LmNsdXN0ZXIubG9jYWwwCgYIKoZIzj0EAwIDSAAwRQIgREqwoe3XHRKY0Af4S/Mp
IUAxdWMAo5H0IGjuDwt9Cb0CIQCY8eIfjvM85aD/aR2VVb+kO27LgZvh3YmGySO7
kVN2qA==
-----END CERTIFICATE-----
 3 s:/CN=pri-yvgbkax.vault.ca.99a02990.consul
   i:/CN=demo.svc.cluster.local
-----BEGIN CERTIFICATE-----
MIIDfzCCAmegAwIBAgIUS5hYtQk/5zSVAhEbA+8nZD+l/xgwDQYJKoZIhvcNAQEL
BQAwITEfMB0GA1UEAxMWZGVtby5zdmMuY2x1c3Rlci5sb2NhbDAeFw0yMDExMTgy
MzU4NTdaFw0yMDEyMjAyMzU5MjdaMC8xLTArBgNVBAMTJHByaS15dmdia2F4LnZh
dWx0LmNhLjk5YTAyOTkwLmNvbnN1bDBZMBMGByqGSM49AgEGCCqGSM49AwEHA0IA
BJiWAlbp5vqFi+8FFGR+goQ2WPkqtWeAY5cevmB8KBt+J1evt1pCdBM7y/Y296/J
8kgwSuoxubiMYqqjr70cu2KjggFqMIIBZjAOBgNVHQ8BAf8EBAMCAQYwDwYDVR0T
AQH/BAUwAwEB/zAdBgNVHQ4EFgQUa/jyNy8orJYtspv70M/UYkGKkm0wHwYDVR0j
BBgwFoAUao/N9Bj0SvGOyszN4x7iA86dlBQwUgYIKwYBBQUHAQEERjBEMEIGCCsG
AQUFBzAChjZodHRwOi8vdmF1bHRkZW1vLmRlbW8uc3ZjLmNsdXN0ZXIubG9jYWw6
ODIwMC92MS9wa2kvY2EwSAYDVR0fBEEwPzA9oDugOYY3aHR0cDovL3ZhdWx0ZGVt
by5kZW1vLnN2Yy5jbHVzdGVyLmxvY2FsOjgyMDAvdjEvcGtpL2NybDBlBgNVHREE
XjBcgiRwcmkteXZnYmtheC52YXVsdC5jYS45OWEwMjk5MC5jb25zdWyGNHNwaWZm
ZTovLzk5YTAyOTkwLTYxODAtZThlMC0yNDA0LWM2NTJlOGJmYzhhZS5jb25zdWww
DQYJKoZIhvcNAQELBQADggEBAHIEK4XLG3xjnJIQ7OPOUfNIRHNO8ZRG9+RUwnmf
yIKdPJzixogJIWoKZFxMjOqioQA2WKDfvPjxRU/JOwRTNs6O7gX/jRHn6reTdJ+C
t61+rENZngNrhNV2Ew5LtVS+3FeE3nsXaMkatzfq8J0i9PVeIQwcoKA545muqA/z
dgrlmpSbfk7m4o2CoGZxlKgs3KI92QgErJXVeCV/aIgCxXVCVp3g9Z8HA/khPif2
2mkJAIH2Khg+hYwKCHVku/dBjwNcH7PIfa1BcuVv4sxUg4LKNKT5/ZQVMRYpAp9B
xUUaoxHc+Nb1nzE70iD/SRVwdma63SgiRajylMKq4nCKk7I=
-----END CERTIFICATE-----
 4 s:/CN=pri-yvgbkax.vault.ca.99a02990.consul
   i:/CN=demo.svc.cluster.local
-----BEGIN CERTIFICATE-----
MIIDfzCCAmegAwIBAgIUS5hYtQk/5zSVAhEbA+8nZD+l/xgwDQYJKoZIhvcNAQEL
BQAwITEfMB0GA1UEAxMWZGVtby5zdmMuY2x1c3Rlci5sb2NhbDAeFw0yMDExMTgy
MzU4NTdaFw0yMDEyMjAyMzU5MjdaMC8xLTArBgNVBAMTJHByaS15dmdia2F4LnZh
dWx0LmNhLjk5YTAyOTkwLmNvbnN1bDBZMBMGByqGSM49AgEGCCqGSM49AwEHA0IA
BJiWAlbp5vqFi+8FFGR+goQ2WPkqtWeAY5cevmB8KBt+J1evt1pCdBM7y/Y296/J
8kgwSuoxubiMYqqjr70cu2KjggFqMIIBZjAOBgNVHQ8BAf8EBAMCAQYwDwYDVR0T
AQH/BAUwAwEB/zAdBgNVHQ4EFgQUa/jyNy8orJYtspv70M/UYkGKkm0wHwYDVR0j
BBgwFoAUao/N9Bj0SvGOyszN4x7iA86dlBQwUgYIKwYBBQUHAQEERjBEMEIGCCsG
AQUFBzAChjZodHRwOi8vdmF1bHRkZW1vLmRlbW8uc3ZjLmNsdXN0ZXIubG9jYWw6
ODIwMC92MS9wa2kvY2EwSAYDVR0fBEEwPzA9oDugOYY3aHR0cDovL3ZhdWx0ZGVt
by5kZW1vLnN2Yy5jbHVzdGVyLmxvY2FsOjgyMDAvdjEvcGtpL2NybDBlBgNVHREE
XjBcgiRwcmkteXZnYmtheC52YXVsdC5jYS45OWEwMjk5MC5jb25zdWyGNHNwaWZm
ZTovLzk5YTAyOTkwLTYxODAtZThlMC0yNDA0LWM2NTJlOGJmYzhhZS5jb25zdWww
DQYJKoZIhvcNAQELBQADggEBAHIEK4XLG3xjnJIQ7OPOUfNIRHNO8ZRG9+RUwnmf
yIKdPJzixogJIWoKZFxMjOqioQA2WKDfvPjxRU/JOwRTNs6O7gX/jRHn6reTdJ+C
t61+rENZngNrhNV2Ew5LtVS+3FeE3nsXaMkatzfq8J0i9PVeIQwcoKA545muqA/z
dgrlmpSbfk7m4o2CoGZxlKgs3KI92QgErJXVeCV/aIgCxXVCVp3g9Z8HA/khPif2
2mkJAIH2Khg+hYwKCHVku/dBjwNcH7PIfa1BcuVv4sxUg4LKNKT5/ZQVMRYpAp9B
xUUaoxHc+Nb1nzE70iD/SRVwdma63SgiRajylMKq4nCKk7I=
-----END CERTIFICATE-----
---
Server certificate
subject=/CN=poc0300.svc.default.99a02990.consul
issuer=/CN=pri-yvgbkax.vault.ca.99a02990.consul
---
Acceptable client certificate CA names
/CN=pri-hciwc1th.consul.ca.99a02990.consul
/CN=demo.svc.cluster.local
Client Certificate Types: RSA sign, ECDSA sign
Requested Signature Algorithms: ECDSA+SHA256:0x04+0x08:RSA+SHA256:ECDSA+SHA384:0x05+0x08:RSA+SHA384:0x06+0x08:RSA+SHA512:RSA+SHA1
Shared Requested Signature Algorithms: ECDSA+SHA256:RSA+SHA256:ECDSA+SHA384:RSA+SHA384:RSA+SHA512:RSA+SHA1
Peer signing digest: SHA256
Server Temp Key: ECDH, P-256, 256 bits
---
SSL handshake has read 4364 bytes and written 138 bytes
---
New, TLSv1/SSLv3, Cipher is ECDHE-ECDSA-AES128-GCM-SHA256
Server public key is 256 bit
Secure Renegotiation IS supported
Compression: NONE
Expansion: NONE
No ALPN negotiated
SSL-Session:
    Protocol  : TLSv1.2
    Cipher    : ECDHE-ECDSA-AES128-GCM-SHA256
    Session-ID: 
    Session-ID-ctx: 
    Master-Key: A2809BEA5AD3353F7DE1D3754CA8564C71043BC1C299019122A4CA2D6D90E6E5A39742DB1EB59F593E113C5EBE1EFFE1
    Key-Arg   : None
    PSK identity: None
    PSK identity hint: None
    SRP username: None
    Start Time: 1605744611
    Timeout   : 300 (sec)
    Verify return code: 20 (unable to get local issuer certificate)
---

```



