# PKI ENGINE: REVOKE CERTIFICATES

### Revoke Certificates
If a certificate must be revoked, you can easily perform the revocation action which will cause the CRL to be regenerated. When the CRL is regenerated, any expired certificates are removed from the CRL.
1. In certain circumstances, you may wish to revoke an issued certificate. To revoke a certificate, execute the following command.
    ```
    # vault write pki_int/revoke \
            serial_number="48:97:82:dd:f0:d3:d9:7e:53:25:ba:fd:f6:77:3e:89:e5:65:cc:e7"
    Key                        Value
    ---                        -----
    revocation_time            1532539632
    revocation_time_rfc3339    2018-07-25T17:27:12.165206399Z
    ```
2.









