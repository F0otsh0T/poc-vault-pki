# ROOT CA

### Generate Root CA
1. First, enable the pki secrets engine at the pki path.
    ```
    # vault secrets enable pki
    Success! Enabled the pki secrets engine at: pki/
    ```
2. Tune the pki secrets engine to issue certificates with a maximum time-to-live (TTL) of 87600 hours.
    ```
    # vault secrets tune -max-lease-ttl=87600h pki
    Success! Tuned the secrets engine at: pki/
    ```
3. Generate the root certificate and save the certificate in CA_cert.crt. *Need to be in a working directory where you can write to.
    ```
    # vault write -field=certificate pki/root/generate/internal \
    common_name="demo.svc.cluster.local" \
    ttl=87600h > CA_cert.crt
    
    # cat CA_cert.crt
    -----BEGIN CERTIFICATE-----
    MIIDYTCCAkmgAwIBAgIUOmw3P8wGCo5uF4mTxcA1VCt47IowDQYJKoZIhvcNAQEL
    BQAwJDEiMCAGA1UEAxMZZGVmYXVsdC5zdmMuY2x1c3Rlci5sb2NhbDAeFw0yMDA2
    MjYwMTAzMjRaFw0zMDA2MjQwMTAzNTRaMCQxIjAgBgNVBAMTGWRlZmF1bHQuc3Zj
    LmNsdXN0ZXIubG9jYWwwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDS
    7yja7aTAeq/KdV69GrjCuZV0L70EQAQBAjWTvMVvOjZ0cZBl9jvFC15xfpocqDfH
    dqNM2epMduiOr32JoOjV8h9G3idHXKShZ+dhp/ml3qhCWKhE8vAN5jt3p8TqXA66
    uTXZDPasgRvZkRfPVWvBkOpVyU4ksiwQG4B8s5VTemB8WV86sFnvcsBgqrG52peb
    O47nO/ah180VLi2w25IHiiHTpoe7CpTOJlHOLjXEVF3K/DdBVQjRACq/x8W0YjKd
    cMuUh0Wc9ICeHOeLVVMxCa0nfxLsFTk+GBBgyIPDal3iS4886TrTrcsJVICbIPfb
    40uyV5aOABtjtAvYqqBFAgMBAAGjgYowgYcwDgYDVR0PAQH/BAQDAgEGMA8GA1Ud
    EwEB/wQFMAMBAf8wHQYDVR0OBBYEFOwXEqoWIfQBbhMKOcSRGb+goHC5MB8GA1Ud
    IwQYMBaAFOwXEqoWIfQBbhMKOcSRGb+goHC5MCQGA1UdEQQdMBuCGWRlZmF1bHQu
    c3ZjLmNsdXN0ZXIubG9jYWwwDQYJKoZIhvcNAQELBQADggEBAEruL8CA/W6oFV7Z
    0o+XPa4zvm8RWUXe8V7ZSRqhcFiACycNnWgnkR4NYeofTzUAJlH5nCJEb2rffSFz
    ievUFK6T77pXHiRC4KtJqA7FPoeGQjV3vAGV30qfOvnuZLedoDAl3e8POGYElIeK
    H1hkUGTwhJETS7KkVtliZrI/AWLBjKyuY0RuY8kU8QTHBc8JXyV5N72AEuY3HWGg
    Vq649WeM28ssDX4lj7/m6ZwKvfPFC4OUB8jfBwJ476XR8cJSi1TVw8el8aVYc7xs
    r/jTzdWP3R6DhokOx3YtKSLFjY/FHw3+1dd8uj71UfKRCTGK3F8JVmaSGod2BtcX
    AbVaWIc=
    -----END CERTIFICATE-----
    
    ```
    This generates a new self-signed CA certificate and private key. Vault will automatically revoke the generated root at the end of its lease period (TTL); the CA certificate will sign its own Certificate Revocation List (CRL).

4. Configure the CA and CRL URLs.
    ```
    # vault write pki/config/urls \
    issuing_certificates="http://vaultdemo.demo.svc.cluster.local:8200/v1/pki/ca" \
    crl_distribution_points="http://vaultdemo.demo.svc.cluster.local:8200/v1/pki/crl"
    Success! Data written to: pki/config/urls
    ```

### Appendix


### References
https://learn.hashicorp.com/vault/secrets-management/sm-pki-engine

```
openssl x509 -text -noout -in [filename]
```





