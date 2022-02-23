# VAULT CERT-MANAGER INTEGRATION:

## CONSUME TLS

#### TYPES
- Mount Secrets
- ConfigMap



#### STEPS
1. Create Secret: In this case, we will have created secrets via the different Vault Authentication methods (AppRole, ServiceAccount, Token)
2. View information about the K8s ```secret```
    ```
    # kubectl get secret --all-namespaces -o wide | grep -i mtls
    demo              mtls-serviceaccount-n4-client                    kubernetes.io/tls                     3      5d
    demo              mtls-serviceaccount-n4-server                    kubernetes.io/tls                     3      5d

    # kubectl -n demo describe secret mtls-serviceaccount-n4-server   
    Name:         mtls-serviceaccount-n4-server
    Namespace:    demo
    Labels:       <none>
    Annotations:  cert-manager.io/alt-names: demo.svc.cluster.local
                  cert-manager.io/certificate-name: serviceaccount-n4-server
                  cert-manager.io/common-name: demo.svc.cluster.local
                  cert-manager.io/ip-sans: 
                  cert-manager.io/issuer-kind: Issuer
                  cert-manager.io/issuer-name: vault-issuer-server-serviceaccount
                  cert-manager.io/uri-sans: 
    
    Type:  kubernetes.io/tls
    
    Data
    ====
    tls.crt:  2680 bytes
    tls.key:  1675 bytes
    ca.crt:   1435 bytes
    
    # kubectl -n demo describe secret mtls-serviceaccount-n4-client
    Name:         mtls-serviceaccount-n4-client
    Namespace:    demo
    Labels:       <none>
    Annotations:  cert-manager.io/alt-names: demo.svc.cluster.local
                  cert-manager.io/certificate-name: serviceaccount-n4-client
                  cert-manager.io/common-name: demo.svc.cluster.local
                  cert-manager.io/ip-sans: 
                  cert-manager.io/issuer-kind: Issuer
                  cert-manager.io/issuer-name: vault-issuer-client-serviceaccount
                  cert-manager.io/uri-sans: 
    
    Type:  kubernetes.io/tls
    
    Data
    ====
    ca.crt:   1435 bytes
    tls.crt:  2680 bytes
    tls.key:  1675 bytes
    ```
3. Edit Pod or Deployment Spec to mount the K8s ```secret``` into the ```pod``` file system - Example K8s ```deployment``` or ```pod``` spec modifications:
    ```
    spec:
      template:
        spec:
          volumes:
            - name: mtls-server
              secret:
                secretName: mtls-token-n4-server
            - name: mtls-client
              secret:
                secretName: mtls-token-n4-client
    .
    .
    .
          containers;
            - name:
              volumeMounts:
                - name: mtls-server
                  mountPath: /vault/secrets/server
                - name: mtls-client
                  mountPath: /vault/secrets/client
    ```

4. Verify K8s ```secret``` mounted
    ```
    # kubectl -n demo exec -it [pod name] -- ls -al /vault/secrets
    total 8
    drwxr-xr-x 4 root root 4096 Sep  8 19:08 .
    drwxr-xr-x 3 root root 4096 Sep  8 19:08 ..
    drwxrwxrwt 3 root root  140 Sep  8 19:45 client
    drwxrwxrwt 3 root root  140 Sep  8 19:41 server
    
    # kubectl -n demo exec -it [pod name] -- ls -al /vault/secrets/client
    total 4
    drwxrwxrwt 3 root root  140 Sep  8 19:45 .
    drwxr-xr-x 4 root root 4096 Sep  8 19:08 ..
    drwxr-xr-x 2 root root  100 Sep  8 19:45 ..2020_09_08_19_45_45.307353323
    lrwxrwxrwx 1 root root   31 Sep  8 19:45 ..data -> ..2020_09_08_19_45_45.307353323
    lrwxrwxrwx 1 root root   13 Sep  8 19:07 ca.crt -> ..data/ca.crt
    lrwxrwxrwx 1 root root   14 Sep  8 19:07 tls.crt -> ..data/tls.crt
    lrwxrwxrwx 1 root root   14 Sep  8 19:07 tls.key -> ..data/tls.key
    
    # kubectl -n demo exec -it [pod name] -- ls -al /vault/secrets/server
    total 4
    drwxrwxrwt 3 root root  140 Sep  8 19:41 .
    drwxr-xr-x 4 root root 4096 Sep  8 19:08 ..
    drwxr-xr-x 2 root root  100 Sep  8 19:41 ..2020_09_08_19_41_44.555460284
    lrwxrwxrwx 1 root root   31 Sep  8 19:41 ..data -> ..2020_09_08_19_41_44.555460284
    lrwxrwxrwx 1 root root   13 Sep  8 19:07 ca.crt -> ..data/ca.crt
    lrwxrwxrwx 1 root root   14 Sep  8 19:07 tls.crt -> ..data/tls.crt
    lrwxrwxrwx 1 root root   14 Sep  8 19:07 tls.key -> ..data/tls.key
    ```
#### REFERENCE
- https://kubernetes.io/docs/tasks/inject-data-application/distribute-credentials-secure/
- 