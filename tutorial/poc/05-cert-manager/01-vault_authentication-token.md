# VAULT CERT-MANAGER INTEGRATION:

## VAULT AUTHENTICATION

#### TYPES
- AppRole
- ServiceAccount
- Token

#### POLICY
Write Vault Policy to enable proper permissions for CERT-MANAGER - Example HCL from ```~/policy/01-p.cert-manager.crudls.hcl```
```
# Allow management of secrets path pki (crudls)
path "pki/*" {
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Allow management of secrets path pki_int (crudls)
path "pki_int/*" {
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
```
Create Policy
```
# vault policy write cert-manager.crudls p.cert-manager.crudls.hcl 
Success! Uploaded policy: cert-manager.crudls

# vault policy read cert-manager.crudls
# Allow management of secrets path pki (crudls)
path "pki/*" {
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Allow management of secrets path pki_int (crudls)
path "pki_int/*" {
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
```
#### TOKEN METHOD
This method of authentication uses a token string that has been generated from one of the many authentication backends that Vault supports. These tokens have an expiry and so need to be periodically refreshed.

1. Generate Token based on Vault Policy: 
    ```
    # vault token create -policy=cert-manager.crudls -no-default-policy -orphan -ttl=768h
    Key                  Value
    ---                  -----
    token                {{ TOKEN }}
    token_accessor       {{ TOKEN_ACCESSOR }}
    token_duration       768h
    token_renewable      true
    token_policies       ["cert-manager.crudls"]
    identity_policies    []
    policies             ["cert-manager.crudls"]
    ```
2. Take above token and convert to ___BASE64___:
    ```
    # echo {{ TOKEN }} | base64
    {{ BASE64 TOKEN }}
    ```
3. Create K8s Secret with ```{{ BASE64 TOKEN }}``` like this ```~/01-vault_authentication-token/01-vault_authentication-token.secret.yaml```. Note: This secret needs to be in the same NameSpace as where you intend to make the TLS secrest available to be consumed / ___issuer___ instance.
    ```
    apiVersion: v1
    kind: Secret
    type: Opaque
    metadata:
      name: cert-manager-vault-token
      namespace: demo
    data:
      token: "{{ BASE64 TOKEN }}"
    ```
    ```
    # kubectl -n cert-manager create -f ./manifests/01-vault_authentication-token.secret.yaml
    secret/cert-manager-vault-token created
    ```
4. (IF NEEDED) To renew token
    ```
    # vault token renew {{ TOKEN }}
    Key                  Value
    ---                  -----
    token                {{ TOKEN }}
    token_accessor       {{ TOKEN_ACCESSOR }}
    token_duration       768h
    token_renewable      true
    token_policies       ["cert-manager.crudls"]
    identity_policies    []
    policies             ["cert-manager.crudls"]
    ```
5. ```cert-manager``` K8s ___issuer.cert-manager.io___ resource:

   Vault ___issuer___ is able to be created using token authentication by referencing this Secret along with the key of the field the token data is stored at. This ___issuer___ will have the Vault attributes defined for URL, endpoint, etc., that will be referenced to retrieve the PKI Secrets.

   - Manifest:
    ```
    apiVersion: cert-manager.io/v1alpha2
    kind: Issuer
    metadata:
      name: vault-issuer
      namespace: demo
    spec:
      vault:
        path: pki_int/sign/demo-svc-cluster-local-server-n4
        server: http://vaultdemo.demo.svc.cluster.local:8200
        auth:
          tokenSecretRef:
              name: cert-manager-vault-token
              key: token
    ```
   - E.g.
    ```
    # kubectl -n cert-manager create -f 01-vault_authentication-token.issuer-server.yaml
    issuer.cert-manager.io/vault-issuer-server-token created
    
    # kubectl -n cert-manager create -f 01-vault_authentication-token.issuer-client.yaml
    issuer.cert-manager.io/vault-issuer-client-token created
    
    # kubectl -n cert-manager get issuer.cert-manager.io                                                           
    NAMESPACE      NAME                        READY   STATUS           AGE
    cert-manager   vault-issuer-client-token   True    Vault verified   31s
    cert-manager   vault-issuer-server-token   True    Vault verified   11s
    
    # kubectl -n cert-manager describe issuer.cert-manager.io vault-issuer-client-token
    Name:         vault-issuer-client-token
    Namespace:    cert-manager
    Labels:       <none>
    Annotations:  <none>
    API Version:  cert-manager.io/v1alpha3
    Kind:         Issuer
    Metadata:
      Creation Timestamp:  2020-08-27T01:18:31Z
      Generation:          1
      Managed Fields:
        API Version:  cert-manager.io/v1alpha2
        Fields Type:  FieldsV1
        fieldsV1:
          f:status:
            .:
            f:conditions:
        Manager:      controller
        Operation:    Update
        Time:         2020-08-27T01:18:31Z
        API Version:  cert-manager.io/v1alpha2
        Fields Type:  FieldsV1
        fieldsV1:
          f:spec:
            .:
            f:vault:
              .:
              f:auth:
                .:
                f:tokenSecretRef:
                  .:
                  f:key:
                  f:name:
              f:path:
              f:server:
        Manager:         kubectl
        Operation:       Update
        Time:            2020-08-27T01:18:31Z
      Resource Version:  27684023
      Self Link:         /apis/cert-manager.io/v1alpha3/namespaces/cert-manager/issuers/vault-issuer-client-token
      UID:               e7795cb8-e66a-47dd-917c-425c07eb3458
    Spec:
      Vault:
        Auth:
          Token Secret Ref:
            Key:   token
            Name:  cert-manager-vault-token
        Path:      pki_int/sign/demo-svc-cluster-local-client-n4
        Server:    http://vaultdemo.demo.svc.cluster.local:8200
    Status:
      Conditions:
        Last Transition Time:  2020-08-27T01:18:31Z
        Message:               Vault verified
        Reason:                VaultVerified
        Status:                True
        Type:                  Ready
    Events:                    <none>
    
    # kubectl -n cert-manager describe issuer.cert-manager.io vault-issuer-server-token
    Name:         vault-issuer-server-token
    Namespace:    cert-manager
    Labels:       <none>
    Annotations:  <none>
    API Version:  cert-manager.io/v1alpha3
    Kind:         Issuer
    Metadata:
      Creation Timestamp:  2020-08-27T01:18:51Z
      Generation:          1
      Managed Fields:
        API Version:  cert-manager.io/v1alpha2
        Fields Type:  FieldsV1
        fieldsV1:
          f:status:
            .:
            f:conditions:
        Manager:      controller
        Operation:    Update
        Time:         2020-08-27T01:18:51Z
        API Version:  cert-manager.io/v1alpha2
        Fields Type:  FieldsV1
        fieldsV1:
          f:spec:
            .:
            f:vault:
              .:
              f:auth:
                .:
                f:tokenSecretRef:
                  .:
                  f:key:
                  f:name:
              f:path:
              f:server:
        Manager:         kubectl
        Operation:       Update
        Time:            2020-08-27T01:18:51Z
      Resource Version:  27684169
      Self Link:         /apis/cert-manager.io/v1alpha3/namespaces/cert-manager/issuers/vault-issuer-server-token
      UID:               3dcab683-d7b5-47ca-8d1b-b97c965584e7
    Spec:
      Vault:
        Auth:
          Token Secret Ref:
            Key:   token
            Name:  cert-manager-vault-token
        Path:      pki_int/sign/demo-svc-cluster-local-server-n4
        Server:    http://vaultdemo.demo.svc.cluster.local:8200
    Status:
      Conditions:
        Last Transition Time:  2020-08-27T01:18:51Z
        Message:               Vault verified
        Reason:                VaultVerified
        Status:                True
        Type:                  Ready
    Events:                    <none>
    ```
6. ```cert-manager``` K8s ___certificate.cert-manager.io___ Resource
  - Manifest:
    ```
    apiVersion: cert-manager.io/v1alpha2
    kind: Certificate
    metadata:
      name: token-n4--client
      namespace: demo
    spec:
      secretName: mtls-token-n4-client
      issuerRef:
        name: vault-issuer-client-token
      commonName: demo.svc.cluster.local
      dnsNames:
      - demo.svc.cluster.local
    ```
  - E.g.
    ```
    # kubectl -n cert-manager create -f ./01-vault_authentication-token.certificate_client.yaml
    certificate.cert-manager.io/token-n4-client created
    
    # kubectl create -f ./01-vault_authentication-token.certificate_server.yaml 
    certificate.cert-manager.io/token-n4-server created
    
    # kubectl get --all-namespaces -o wide certificate.cert-manager.io                                          
    NAMESPACE   NAME        READY   SECRET                     ISSUER                      STATUS                                                              AGE
    demo        token-n4-client   False   cert-manager-vault-token   vault-issuer-client-token   Waiting for CertificateRequest "token-n4-client-216327105" to complete    13s
    demo        token-n4-server   False   cert-manager-vault-token   vault-issuer-server-token   Waiting for CertificateRequest "token-n4-server-1672283117" to complete   7s
    
    # kubectl -n demo describe certificate.cert-manager.io token-n4-client                     
    Name:         token-n4-client
    Namespace:    demo
    Labels:       <none>
    Annotations:  <none>
    API Version:  cert-manager.io/v1alpha3
    Kind:         Certificate
    Metadata:
      Creation Timestamp:  2020-08-27T01:26:01Z
      Generation:          1
      Managed Fields:
        API Version:  cert-manager.io/v1alpha2
        Fields Type:  FieldsV1
        fieldsV1:
          f:status:
            .:
            f:conditions:
        Manager:      controller
        Operation:    Update
        Time:         2020-08-27T01:26:01Z
        API Version:  cert-manager.io/v1alpha2
        Fields Type:  FieldsV1
        fieldsV1:
          f:spec:
            .:
            f:commonName:
            f:dnsNames:
            f:issuerRef:
              .:
              f:name:
            f:secretName:
        Manager:         kubectl
        Operation:       Update
        Time:            2020-08-27T01:26:01Z
      Resource Version:  27687004
      Self Link:         /apis/cert-manager.io/v1alpha3/namespaces/demo/certificates/token-n4-client
      UID:               e993d344-7102-4047-80f8-49aa1c116f82
    Spec:
      Common Name:  demo.svc.cluster.local
      Dns Names:
        demo.svc.cluster.local
      Issuer Ref:
        Name:       vault-issuer-client-token
      Secret Name:  cert-manager-vault-token
    Status:
      Conditions:
        Last Transition Time:  2020-08-27T01:26:01Z
        Message:               Waiting for CertificateRequest "token-n4-client-216327105" to complete
        Reason:                InProgress
        Status:                False
        Type:                  Ready
    Events:
      Type    Reason     Age    From          Message
      ----    ------     ----   ----          -------
      Normal  Requested  3m56s  cert-manager  Created new CertificateRequest resource "token-n4-client-216327105"
    
    # kubectl -n demo describe certificate.cert-manager.io token-n4-server
    Name:         token-n4-server
    Namespace:    demo
    Labels:       <none>
    Annotations:  <none>
    API Version:  cert-manager.io/v1alpha3
    Kind:         Certificate
    Metadata:
      Creation Timestamp:  2020-08-27T01:26:07Z
      Generation:          1
      Managed Fields:
        API Version:  cert-manager.io/v1alpha2
        Fields Type:  FieldsV1
        fieldsV1:
          f:status:
            .:
            f:conditions:
        Manager:      controller
        Operation:    Update
        Time:         2020-08-27T01:26:07Z
        API Version:  cert-manager.io/v1alpha2
        Fields Type:  FieldsV1
        fieldsV1:
          f:spec:
            .:
            f:commonName:
            f:dnsNames:
            f:issuerRef:
              .:
              f:name:
            f:secretName:
        Manager:         kubectl
        Operation:       Update
        Time:            2020-08-27T01:26:07Z
      Resource Version:  27687052
      Self Link:         /apis/cert-manager.io/v1alpha3/namespaces/demo/certificates/token-n4-server
      UID:               4e6b8ebc-9063-43c2-bdf6-2278f3c2278b
    Spec:
      Common Name:  demo.svc.cluster.local
      Dns Names:
        demo.svc.cluster.local
      Issuer Ref:
        Name:       vault-issuer-server-token
      Secret Name:  cert-manager-vault-token
    Status:
      Conditions:
        Last Transition Time:  2020-08-27T01:26:07Z
        Message:               Waiting for CertificateRequest "token-n4-server-1672283117" to complete
        Reason:                InProgress
        Status:                False
        Type:                  Ready
    Events:
      Type    Reason     Age    From          Message
      ----    ------     ----   ----          -------
      Normal  Requested  4m23s  cert-manager  Created new CertificateRequest resource "token-n4-server-1672283117"
    ```

### REFERENCES
- https://learn.hashicorp.com/tutorials/vault/kubernetes-cert-manager
- https://cert-manager.io/docs/configuration/vault/
- https://docs.cert-manager.io/en/release-0.7/tasks/issuers/setup-vault.html
- https://www.arctiq.ca/our-blog/2019/4/1/how-to-use-vault-pki-engine-for-dynamic-tls-certificates-on-gke/
- https://medium.com/uptime-99/upgrade-cert-manager-its-worth-it-dff80e2a8e6
- https://www.ibm.com/support/knowledgecenter/SSHKN6/cert-manager/3.x.x/cert_vault.html