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
#### SERIVCE ACCOUNT METHOD
This method of authentication uses a K8s ```serviceaccount``` Resource that integrates with many authentication backends that Vault supports.

1. Enable Vault Kubernetes Authentication Method 
    ```
    # vault auth enable kubernetes
    Success! Enabled kubernetes auth method at: kubernetes/
    ```
2. Configure the Kubernetes authentication method to use the service account token, the location of the Kubernetes host, and its certificate.:
    ```
    # vault write auth/kubernetes/config \
    token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
    kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443" \
    kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
    Success! Data written to: auth/kubernetes/config
    ```
3. Create a Kubernetes authentication role named ```issuer``` that binds the ```pki``` policy with a Kubernetes service account named ```issuer```.
    ```
    # vault write auth/kubernetes/role/issuer \
        bound_service_account_names=issuer \
        bound_service_account_namespaces=demo \
        policies=cert-manager.crudls \
        ttl=20m
    Success! Data written to: auth/kubernetes/role/issuer
    ```
    ```
    # vault read auth/kubernetes/role/issuer
    Key                                 Value
    ---                                 -----
    bound_service_account_names         [issuer]
    bound_service_account_namespaces    [demo]
    policies                            [pki]
    token_bound_cidrs                   []
    token_explicit_max_ttl              0s
    token_max_ttl                       0s
    token_no_default_policy             false
    token_num_uses                      0
    token_period                        0s
    token_policies                      [pki]
    token_ttl                           20m
    token_type                          default
    ttl                                 20m
    ```
4. Create a K8s ```serviceaccount``` in the same ```namespace``` of your Vault Application
    ```
    # kubectl -n demo create serviceaccount issuer
    serviceaccount/issuer ceated
    ```
5. With the above ```serviceaccount```, a corresponding ```secret``` prefaced by ```issuer-token-``` will have been created.
    - Check that new ```secret``` is created
    ```
    # kubectl -n demo get secret | grep -i issue-token
    demo              issuer-token-4lc5z                               kubernetes.io/service-account-token   3      1m
    ```
    - Set and export environment variable named ```ISSUER_SECRET_REF``` to capture the secret name.
    ```
    # ISSUER_SECRET_REF=$(kubectl -n demo get serviceaccount issuer -o json | jq -r ".secrets[].name")
    
    # echo $ISSUER_SECRET_REF
    issuer-token-4lc5z
    ```
6. Create  ```cert-manager``` K8s ___Issuer___ Resource(s), named ```vault-issuer-client-serviceaccount``` (and ```vault-issuer-server-serviceaccount```, that defines Vault as a certificate issuer.
    - Manifest @ ```~/01-vault_authentication-serviceaccount/01-vault_authentication-serviceaccount.issuer-client.yaml```
    ```
    apiVersion: cert-manager.io/v1alpha2
    kind: Issuer
    metadata:
      name: vault-issuer-client-serviceaccount
      namespace: cert-manager
    spec:
      vault:
        path: pki_int/sign/demo-svc-cluster-local-client-n4
        server: http://vaultdemo.demo.svc.cluster.local:8200
        auth:
          kubernetes:
            mountPath: /v1/auth/kubernetes
            role: issuer
            secretRef:
              name: $ISSUER_SECRET_REF
              key: token
    ```
    - The specification defines the signing endpoint and the authentication endpoint and credentials.
        - ```metadata.name``` sets the name of the Issuer to ```vault-issuer-client-serviceaccount```
        - ```spec.vault.server``` sets the server address to the Kubernetes service created in the demo ```namespace```
        - ```spec.vault.path``` is the signing endpoint created by Vault's PKI ```demo-svc-cluster-local-client-n4``` and ```demo-svc-cluster-local-server-n4``` roles
        - ```spec.vault.auth.kubernetes.mountPath``` sets the Vault authentication endpoint
        - ```spec.vault.auth.kubernetes.role``` sets the Vault Kubernetes role to ```issuer```
        - ```spec.vault.auth.kubernetes/secretRef.name``` sets the secret for the Kubernetes service account
        - ```spec.vault.auth.kubernetes/secretRef.key``` sets the type to ```token```.
    - E.g.
    ```
    # kubectl create -f ./01-vault_authentication-serviceaccount.issuer-client.yaml
    issuer.cert-manager.io/vault-issuer-client-serviceaccount created
    
    # kubectl create -f ./01-vault_authentication-serviceaccount.issuer-server.yaml
    issuer.cert-manager.io/vault-issuer-server-serviceaccount created
    
    # kga issuer.cert-manager.io                                                   
    NAMESPACE      NAME                                 READY   STATUS           AGE
    demo           vault-issuer-client-serviceaccount   True    Vault verified   10s
    demo           vault-issuer-server-serviceaccount   True    Vault verified   4s
    
    # kubectl -n demo describe issuer.cert-manager.io vault-issuer-client-serviceaccount       
    Name:         vault-issuer-client-serviceaccount
    Namespace:    demo
    Labels:       <none>
    Annotations:  <none>
    API Version:  cert-manager.io/v1alpha3
    Kind:         Issuer
    Metadata:
      Creation Timestamp:  2020-08-27T02:45:43Z
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
        Time:         2020-08-27T02:45:43Z
        API Version:  cert-manager.io/v1alpha2
        Fields Type:  FieldsV1
        fieldsV1:
          f:spec:
            .:
            f:vault:
              .:
              f:auth:
                .:
                f:kubernetes:
                  .:
                  f:mountPath:
                  f:role:
                  f:secretRef:
                    .:
                    f:key:
                    f:name:
              f:path:
              f:server:
        Manager:         kubectl
        Operation:       Update
        Time:            2020-08-27T02:45:43Z
      Resource Version:  27718477
      Self Link:         /apis/cert-manager.io/v1alpha3/namespaces/demo/issuers/vault-issuer-client-serviceaccount
      UID:               e53b18e3-3429-47d9-8dbc-8c9cee30ade1
    Spec:
      Vault:
        Auth:
          Kubernetes:
            Mount Path:  /v1/auth/kubernetes
            Role:        issuer
            Secret Ref:
              Key:   token
              Name:  issuer-token-4lc5z
        Path:        pki_int/sign/demo-svc-cluster-local-client-n4
        Server:      http://vaultdemo.demo.svc.cluster.local:8200
    Status:
      Conditions:
        Last Transition Time:  2020-08-27T02:45:43Z
        Message:               Vault verified
        Reason:                VaultVerified
        Status:                True
        Type:                  Ready
    Events:                    <none>
    
    # kubectl -n demo describe issuer.cert-manager.io vault-issuer-server-serviceaccount      
    Name:         vault-issuer-server-serviceaccount
    Namespace:    demo
    Labels:       <none>
    Annotations:  <none>
    API Version:  cert-manager.io/v1alpha3
    Kind:         Issuer
    Metadata:
      Creation Timestamp:  2020-08-27T02:45:49Z
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
        Time:         2020-08-27T02:45:49Z
        API Version:  cert-manager.io/v1alpha2
        Fields Type:  FieldsV1
        fieldsV1:
          f:spec:
            .:
            f:vault:
              .:
              f:auth:
                .:
                f:kubernetes:
                  .:
                  f:mountPath:
                  f:role:
                  f:secretRef:
                    .:
                    f:key:
                    f:name:
              f:path:
              f:server:
        Manager:         kubectl
        Operation:       Update
        Time:            2020-08-27T02:45:49Z
      Resource Version:  27718521
      Self Link:         /apis/cert-manager.io/v1alpha3/namespaces/demo/issuers/vault-issuer-server-serviceaccount
      UID:               b5f159ce-ac1c-46e9-ac5c-733a1e9e5703
    Spec:
      Vault:
        Auth:
          Kubernetes:
            Mount Path:  /v1/auth/kubernetes
            Role:        issuer
            Secret Ref:
              Key:   token
              Name:  issuer-token-4lc5z
        Path:        pki_int/sign/demo-svc-cluster-local-client-n4
        Server:      http://vaultdemo.demo.svc.cluster.local:8200
    Status:
      Conditions:
        Last Transition Time:  2020-08-27T02:45:49Z
        Message:               Vault verified
        Reason:                VaultVerified
        Status:                True
        Type:                  Ready
    Events:                    <none>
    ```

7. ```cert-manager``` K8s ___certificate.cert-manager.io___ Resource
  - Manifest:
    ```
    apiVersion: cert-manager.io/v1alpha2
    kind: Certificate
    metadata:
      name: serviceaccount-n4-client
      namespace: demo
    spec:
      secretName: mtls-serviceaccount-n4-client
      issuerRef:
        name: vault-issuer-client-serviceaccount
      commonName: demo.svc.cluster.local
      dnsNames:
      - demo.svc.cluster.local
    ```
  - E.g.
    ```
    # kubectl -n cert-manager create -f ./01-vault_authentication-serviceaccount.certificate_client.yaml
    certificate.cert-manager.io/serviceaccount-n4-client created
    
    # kubectl create -f ./01-vault_authentication-serviceaccount.certificate_server.yaml 
    certificate.cert-manager.io/serviceaccount-n4-server created
    
    # kubectl get -A certificate -o wide
    NAMESPACE   NAME                       READY   SECRET                          ISSUER                               STATUS                                                                             AGE
    demo        serviceaccount-n4-client   False   mtls-serviceaccount-n4-client   vault-issuer-client-serviceaccount   Waiting for CertificateRequest "serviceaccount-n4-client-3052513419" to complete   2m4s
    demo        serviceaccount-n4-server   False   mtls-serviceaccount-n4-server   vault-issuer-server-serviceaccount   Waiting for CertificateRequest "serviceaccount-n4-server-4100858035" to complete   119s

    # kubectl -n demo describe certificate.cert-manager.io serviceaccount-n4-client
    Name:         serviceaccount-n4-client
    Namespace:    demo
    Labels:       <none>
    Annotations:  <none>
    API Version:  cert-manager.io/v1alpha3
    Kind:         Certificate
    Metadata:
      Creation Timestamp:  2020-08-27T04:04:40Z
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
        Time:         2020-08-27T04:04:40Z
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
        Time:            2020-08-27T04:04:40Z
      Resource Version:  27749694
      Self Link:         /apis/cert-manager.io/v1alpha3/namespaces/demo/certificates/serviceaccount-n4-client
      UID:               7180c59a-2966-4b56-bb6d-d705706e6a68
    Spec:
      Common Name:  demo.svc.cluster.local
      Dns Names:
        demo.svc.cluster.local
      Issuer Ref:
        Name:       vault-issuer-client-serviceaccount
      Secret Name:  mtls-serviceaccount-n4-client
    Status:
      Conditions:
        Last Transition Time:  2020-08-27T04:04:40Z
        Message:               Waiting for CertificateRequest "serviceaccount-n4-client-3052513419" to complete
        Reason:                InProgress
        Status:                False
        Type:                  Ready
    Events:
      Type    Reason     Age    From          Message
      ----    ------     ----   ----          -------
      Normal  Requested  3m11s  cert-manager  Created new CertificateRequest resource "serviceaccount-n4-client-3052513419"
    
    # kubectl -n demo describe certificate.cert-manager.io serviceaccount-n4-server
    Name:         serviceaccount-n4-server
    Namespace:    demo
    Labels:       <none>
    Annotations:  <none>
    API Version:  cert-manager.io/v1alpha3
    Kind:         Certificate
    Metadata:
      Creation Timestamp:  2020-08-27T04:04:45Z
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
        Time:         2020-08-27T04:04:45Z
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
        Time:            2020-08-27T04:04:45Z
      Resource Version:  27749723
      Self Link:         /apis/cert-manager.io/v1alpha3/namespaces/demo/certificates/serviceaccount-n4-server
      UID:               c637bde6-85af-4a05-a70d-e55d0481da73
    Spec:
      Common Name:  demo.svc.cluster.local
      Dns Names:
        demo.svc.cluster.local
      Issuer Ref:
        Name:       vault-issuer-server-serviceaccount
      Secret Name:  mtls-serviceaccount-n4-server
    Status:
      Conditions:
        Last Transition Time:  2020-08-27T04:04:45Z
        Message:               Waiting for CertificateRequest "serviceaccount-n4-server-4100858035" to complete
        Reason:                InProgress
        Status:                False
        Type:                  Ready
    Events:
      Type    Reason     Age    From          Message
      ----    ------     ----   ----          -------
      Normal  Requested  3m10s  cert-manager  Created new CertificateRequest resource "serviceaccount-n4-server-4100858035"
    ```

### REFERENCES
- https://learn.hashicorp.com/tutorials/vault/kubernetes-cert-manager
- https://cert-manager.io/docs/configuration/vault/
- https://docs.cert-manager.io/en/release-0.7/tasks/issuers/setup-vault.html
- https://www.arctiq.ca/our-blog/2019/4/1/how-to-use-vault-pki-engine-for-dynamic-tls-certificates-on-gke/
- https://medium.com/uptime-99/upgrade-cert-manager-its-worth-it-dff80e2a8e6
- https://www.ibm.com/support/knowledgecenter/SSHKN6/cert-manager/3.x.x/cert_vault.html