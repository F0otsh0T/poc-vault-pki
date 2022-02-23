# PKI ENGINE: TIDY EXPIRED CERTIFICATRES

### Remove Expired Certificates
Keep the storage backend and CRL by periodically removing certificates that have expired and are past a certain buffer period beyond their expiration time.
1. To remove revoked certificate and clean the CRL.
    ```
    # vault write pki_int/tidy tidy_cert_store=true tidy_revoked_certs=true
    ```
2.








