# INTERMEDIATE CA

### Generate Intermediate CA
1. First, enable the pki secrets engine at the pki_int path.
    ```
    # vault secrets enable -path=pki_int pki
    Success! Enabled the pki secrets engine at: pki_int/
    ```
2. Tune the pki_int secrets engine to issue certificates with a maximum time-to-live (TTL) of 43800 hours.
    ```
    # vault secrets tune -max-lease-ttl=43800h pki_int
    Success! Tuned the secrets engine at: pki_int/
    ```
3. Execute the following command to generate an intermediate and save the CSR as pki_intermediate.csr.
    ```
    # vault write -format=json pki_int/intermediate/generate/internal \
    common_name="demo.svc.cluster.local" > intermediate.out
    
    # cat intermediate.out
    {
      "request_id": "b02327f4-da27-1fc0-9238-d73427630b9b",
      "lease_id": "",
      "lease_duration": 0,
      "renewable": false,
      "data": {
        "csr": "-----BEGIN CERTIFICATE REQUEST-----\nMIICoDCCAYgCAQAwJDEiMCAGA1UEAxMZZGVmYXVsdC5zdmMuY2x1c3Rlci5sb2Nh\nbDCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAJCtEEQbTc9V8pi9WNp6\nCXw5jCs4qXukmHV/o+fyWRvFjJEAGzC4pqo7X5hQ29JhcNjG0NNV3mLa9b6xKiTE\nKK0aGe+CbqA8H1NbqVw5mkG4L/ZLnaXuTrsyR0f2DbAWgp28UnSwL92m28M2Y5sd\ndAem4+V04udtCAuAWnMEvYoa7hwwZpCkKa3NclmKytyIwg1qFBwDFl760mlOvu7d\nx8PDNoXvozAD/ntStc55+RycibfoRcNqSISjyd7gFwinKLqMrqpWah2TTdOqjlvu\n1QAvHXXCDIIZv+IRROgyMq38dDlAvOQ/T4xxpFUiCuLXUawN3+HvY53knGb7mFD8\nLhcCAwEAAaA3MDUGCSqGSIb3DQEJDjEoMCYwJAYDVR0RBB0wG4IZZGVmYXVsdC5z\ndmMuY2x1c3Rlci5sb2NhbDANBgkqhkiG9w0BAQsFAAOCAQEAWI16Bt9kMdV3BMeJ\nTEo29EUx136UHE029Vx+EG7zOH7XxBy6A5PSShLnCHw/4eM9pOBa1JNNUwm/zu+I\nltmvbyB4sRoOryJ2Fn1Big2QUvA6f6ghYqMoYfJnqQhRIxi6MtbrANecOnUcRm9E\nJlevftJod5be78OB8BE0/GECG+4pr3q1po/Dv51VRqJHBNBbw1GO15H56DL5Fvxu\nPNp5TQ8zwVlHQHTntrxuBcvrQUFUvJXx8aRwYlVdGqUy0ASc/Aqgit120G4evOqZ\nEuV+mpTGEg40iIbJ5tX+51TsFc7RUWKHGuYK2fLVxXqPV5v760SoxwRWIMKpRd6d\nlSoltg==\n-----END CERTIFICATE REQUEST-----"
      },
      "warnings": null
    }
    
    # cat intermediate.out | jq -r '.data.csr' > pki_intermediate.csr
    
    # cat pki_intermediate.csr
    -----BEGIN CERTIFICATE REQUEST-----
    MIICoDCCAYgCAQAwJDEiMCAGA1UEAxMZZGVmYXVsdC5zdmMuY2x1c3Rlci5sb2Nh
    bDCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAJCtEEQbTc9V8pi9WNp6
    CXw5jCs4qXukmHV/o+fyWRvFjJEAGzC4pqo7X5hQ29JhcNjG0NNV3mLa9b6xKiTE
    KK0aGe+CbqA8H1NbqVw5mkG4L/ZLnaXuTrsyR0f2DbAWgp28UnSwL92m28M2Y5sd
    dAem4+V04udtCAuAWnMEvYoa7hwwZpCkKa3NclmKytyIwg1qFBwDFl760mlOvu7d
    x8PDNoXvozAD/ntStc55+RycibfoRcNqSISjyd7gFwinKLqMrqpWah2TTdOqjlvu
    1QAvHXXCDIIZv+IRROgyMq38dDlAvOQ/T4xxpFUiCuLXUawN3+HvY53knGb7mFD8
    LhcCAwEAAaA3MDUGCSqGSIb3DQEJDjEoMCYwJAYDVR0RBB0wG4IZZGVmYXVsdC5z
    dmMuY2x1c3Rlci5sb2NhbDANBgkqhkiG9w0BAQsFAAOCAQEAWI16Bt9kMdV3BMeJ
    TEo29EUx136UHE029Vx+EG7zOH7XxBy6A5PSShLnCHw/4eM9pOBa1JNNUwm/zu+I
    ltmvbyB4sRoOryJ2Fn1Big2QUvA6f6ghYqMoYfJnqQhRIxi6MtbrANecOnUcRm9E
    JlevftJod5be78OB8BE0/GECG+4pr3q1po/Dv51VRqJHBNBbw1GO15H56DL5Fvxu
    PNp5TQ8zwVlHQHTntrxuBcvrQUFUvJXx8aRwYlVdGqUy0ASc/Aqgit120G4evOqZ
    EuV+mpTGEg40iIbJ5tX+51TsFc7RUWKHGuYK2fLVxXqPV5v760SoxwRWIMKpRd6d
    lSoltg==
    -----END CERTIFICATE REQUEST-----
    ```
4. Sign the intermediate certificate with the root certificate and save the generated certificate as intermediate.cert.pem.
    ```
    # vault write -format=json pki/root/sign-intermediate csr=@pki_intermediate.csr \
    format=pem_bundle ttl="43800h" > pem.out
    
    # cat pem.out
    {
      "request_id": "da320154-0eba-9db1-8eb8-2da88cccef23",
      "lease_id": "",
      "lease_duration": 0,
      "renewable": false,
      "data": {
        "certificate": "-----BEGIN CERTIFICATE-----\nMIID/zCCAuegAwIBAgIUIQlX5xF3/nBlkt5fdVsJHhPoAwAwDQYJKoZIhvcNAQEL\nBQAwJDEiMCAGA1UEAxMZZGVmYXVsdC5zdmMuY2x1c3Rlci5sb2NhbDAeFw0yMDA2\nMjYwMTExNTNaFw0yNTA2MjUwMTEyMjNaMCQxIjAgBgNVBAMTGWRlZmF1bHQuc3Zj\nLmNsdXN0ZXIubG9jYWwwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCQ\nrRBEG03PVfKYvVjaegl8OYwrOKl7pJh1f6Pn8lkbxYyRABswuKaqO1+YUNvSYXDY\nxtDTVd5i2vW+sSokxCitGhnvgm6gPB9TW6lcOZpBuC/2S52l7k67MkdH9g2wFoKd\nvFJ0sC/dptvDNmObHXQHpuPldOLnbQgLgFpzBL2KGu4cMGaQpCmtzXJZisrciMIN\nahQcAxZe+tJpTr7u3cfDwzaF76MwA/57UrXOefkcnIm36EXDakiEo8ne4BcIpyi6\njK6qVmodk03Tqo5b7tUALx11wgyCGb/iEUToMjKt/HQ5QLzkP0+McaRVIgri11Gs\nDd/h72Od5Jxm+5hQ/C4XAgMBAAGjggEnMIIBIzAOBgNVHQ8BAf8EBAMCAQYwDwYD\nVR0TAQH/BAUwAwEB/zAdBgNVHQ4EFgQUDO1fraj9NzEC4zG9OwVGJCzizg8wHwYD\nVR0jBBgwFoAU7BcSqhYh9AFuEwo5xJEZv6CgcLkwUQYIKwYBBQUHAQEERTBDMEEG\nCCsGAQUFBzAChjVodHRwOi8vdmF1bHQuZGVmYXVsdC5zdmMuY2x1c3Rlci5sb2Nh\nbDo4MjAwL3YxL3BraS9jYTAkBgNVHREEHTAbghlkZWZhdWx0LnN2Yy5jbHVzdGVy\nLmxvY2FsMEcGA1UdHwRAMD4wPKA6oDiGNmh0dHA6Ly92YXVsdC5kZWZhdWx0LnN2\nYy5jbHVzdGVyLmxvY2FsOjgyMDAvdjEvcGtpL2NybDANBgkqhkiG9w0BAQsFAAOC\nAQEAXJ4Pw77dJBpUcRXaavDEwDcD2wbh0XP3mpOzPfBTb+oEvjGESTMI6LcnWFIM\nX2AgCfr6NLjbjRyH9pwqahqFRmlTLsDJJSzO5CK/xqpZuSztvMYdgggK+rvqCUZC\nYe5Il+pJbTRhA3Erx//9JU2hY/Tp0bTfbb3+aYq8ezZUWBWvppngCgeQWCcIyUrp\nMswVoDI58uaV8SKDWakBKiOWcHgLX4rG04ixHMYHdhCWS6P51a0R0kdC77fwMHlu\nhj96FXS47HPrOg0VsTsh6jS8Ini/hMX1vaystPFlmv0ilxf7FCuNZoL9w11+BoR0\nE0Hm/44IYh8d6Dybnd1JZ157Kw==\n-----END CERTIFICATE-----",
        "expiration": 1750813943,
        "issuing_ca": "-----BEGIN CERTIFICATE-----\nMIIDYTCCAkmgAwIBAgIUOmw3P8wGCo5uF4mTxcA1VCt47IowDQYJKoZIhvcNAQEL\nBQAwJDEiMCAGA1UEAxMZZGVmYXVsdC5zdmMuY2x1c3Rlci5sb2NhbDAeFw0yMDA2\nMjYwMTAzMjRaFw0zMDA2MjQwMTAzNTRaMCQxIjAgBgNVBAMTGWRlZmF1bHQuc3Zj\nLmNsdXN0ZXIubG9jYWwwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDS\n7yja7aTAeq/KdV69GrjCuZV0L70EQAQBAjWTvMVvOjZ0cZBl9jvFC15xfpocqDfH\ndqNM2epMduiOr32JoOjV8h9G3idHXKShZ+dhp/ml3qhCWKhE8vAN5jt3p8TqXA66\nuTXZDPasgRvZkRfPVWvBkOpVyU4ksiwQG4B8s5VTemB8WV86sFnvcsBgqrG52peb\nO47nO/ah180VLi2w25IHiiHTpoe7CpTOJlHOLjXEVF3K/DdBVQjRACq/x8W0YjKd\ncMuUh0Wc9ICeHOeLVVMxCa0nfxLsFTk+GBBgyIPDal3iS4886TrTrcsJVICbIPfb\n40uyV5aOABtjtAvYqqBFAgMBAAGjgYowgYcwDgYDVR0PAQH/BAQDAgEGMA8GA1Ud\nEwEB/wQFMAMBAf8wHQYDVR0OBBYEFOwXEqoWIfQBbhMKOcSRGb+goHC5MB8GA1Ud\nIwQYMBaAFOwXEqoWIfQBbhMKOcSRGb+goHC5MCQGA1UdEQQdMBuCGWRlZmF1bHQu\nc3ZjLmNsdXN0ZXIubG9jYWwwDQYJKoZIhvcNAQELBQADggEBAEruL8CA/W6oFV7Z\n0o+XPa4zvm8RWUXe8V7ZSRqhcFiACycNnWgnkR4NYeofTzUAJlH5nCJEb2rffSFz\nievUFK6T77pXHiRC4KtJqA7FPoeGQjV3vAGV30qfOvnuZLedoDAl3e8POGYElIeK\nH1hkUGTwhJETS7KkVtliZrI/AWLBjKyuY0RuY8kU8QTHBc8JXyV5N72AEuY3HWGg\nVq649WeM28ssDX4lj7/m6ZwKvfPFC4OUB8jfBwJ476XR8cJSi1TVw8el8aVYc7xs\nr/jTzdWP3R6DhokOx3YtKSLFjY/FHw3+1dd8uj71UfKRCTGK3F8JVmaSGod2BtcX\nAbVaWIc=\n-----END CERTIFICATE-----",
        "serial_number": "21:09:57:e7:11:77:fe:70:65:92:de:5f:75:5b:09:1e:13:e8:03:00"
      },
      "warnings": null
    }
    
    # cat pem.out | jq -r '.data.certificate' > intermediate.cert.pem
    
    # cat intermediate.cert.pem
    -----BEGIN CERTIFICATE-----
    MIID/zCCAuegAwIBAgIUIQlX5xF3/nBlkt5fdVsJHhPoAwAwDQYJKoZIhvcNAQEL
    BQAwJDEiMCAGA1UEAxMZZGVmYXVsdC5zdmMuY2x1c3Rlci5sb2NhbDAeFw0yMDA2
    MjYwMTExNTNaFw0yNTA2MjUwMTEyMjNaMCQxIjAgBgNVBAMTGWRlZmF1bHQuc3Zj
    LmNsdXN0ZXIubG9jYWwwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCQ
    rRBEG03PVfKYvVjaegl8OYwrOKl7pJh1f6Pn8lkbxYyRABswuKaqO1+YUNvSYXDY
    xtDTVd5i2vW+sSokxCitGhnvgm6gPB9TW6lcOZpBuC/2S52l7k67MkdH9g2wFoKd
    vFJ0sC/dptvDNmObHXQHpuPldOLnbQgLgFpzBL2KGu4cMGaQpCmtzXJZisrciMIN
    ahQcAxZe+tJpTr7u3cfDwzaF76MwA/57UrXOefkcnIm36EXDakiEo8ne4BcIpyi6
    jK6qVmodk03Tqo5b7tUALx11wgyCGb/iEUToMjKt/HQ5QLzkP0+McaRVIgri11Gs
    Dd/h72Od5Jxm+5hQ/C4XAgMBAAGjggEnMIIBIzAOBgNVHQ8BAf8EBAMCAQYwDwYD
    VR0TAQH/BAUwAwEB/zAdBgNVHQ4EFgQUDO1fraj9NzEC4zG9OwVGJCzizg8wHwYD
    VR0jBBgwFoAU7BcSqhYh9AFuEwo5xJEZv6CgcLkwUQYIKwYBBQUHAQEERTBDMEEG
    CCsGAQUFBzAChjVodHRwOi8vdmF1bHQuZGVmYXVsdC5zdmMuY2x1c3Rlci5sb2Nh
    bDo4MjAwL3YxL3BraS9jYTAkBgNVHREEHTAbghlkZWZhdWx0LnN2Yy5jbHVzdGVy
    LmxvY2FsMEcGA1UdHwRAMD4wPKA6oDiGNmh0dHA6Ly92YXVsdC5kZWZhdWx0LnN2
    Yy5jbHVzdGVyLmxvY2FsOjgyMDAvdjEvcGtpL2NybDANBgkqhkiG9w0BAQsFAAOC
    AQEAXJ4Pw77dJBpUcRXaavDEwDcD2wbh0XP3mpOzPfBTb+oEvjGESTMI6LcnWFIM
    X2AgCfr6NLjbjRyH9pwqahqFRmlTLsDJJSzO5CK/xqpZuSztvMYdgggK+rvqCUZC
    Ye5Il+pJbTRhA3Erx//9JU2hY/Tp0bTfbb3+aYq8ezZUWBWvppngCgeQWCcIyUrp
    MswVoDI58uaV8SKDWakBKiOWcHgLX4rG04ixHMYHdhCWS6P51a0R0kdC77fwMHlu
    hj96FXS47HPrOg0VsTsh6jS8Ini/hMX1vaystPFlmv0ilxf7FCuNZoL9w11+BoR0
    E0Hm/44IYh8d6Dybnd1JZ157Kw==
    -----END CERTIFICATE-----
    
    ```
5. Once the CSR is signed and the root CA returns a certificate, it can be imported back into Vault.
    ```
    # vault write pki_int/intermediate/set-signed certificate=@intermediate.cert.pem
    Success! Data written to: pki_int/intermediate/set-signed
    ```

    ```
    # vault read pki_int/roles/demo-svc-cluster-local
    Key                                   Value
    ---                                   -----
    allow_any_name                        false
    allow_bare_domains                    false
    allow_glob_domains                    false
    allow_ip_sans                         true
    allow_localhost                       true
    allow_subdomains                      true
    allow_token_displayname               false
    allowed_domains                       [demo.svc.cluster.local]
    allowed_other_sans                    <nil>
    allowed_serial_numbers                []
    allowed_uri_sans                      []
    basic_constraints_valid_for_non_ca    false
    client_flag                           true
    code_signing_flag                     false
    country                               []
    email_protection_flag                 false
    enforce_hostnames                     true
    ext_key_usage                         []
    ext_key_usage_oids                    []
    generate_lease                        false
    key_bits                              2048
    key_type                              rsa
    key_usage                             [DigitalSignature KeyAgreement KeyEncipherment]
    locality                              []
    max_ttl                               720h
    no_store                              false
    not_before_duration                   30s
    organization                          []
    ou                                    []
    policy_identifiers                    []
    postal_code                           []
    province                              []
    require_cn                            true
    server_flag                           true
    street_address                        []
    ttl                                   0s
    use_csr_common_name                   true
    use_csr_sans                          true
    
    # vault read pki_int/roles/demo-svc-cluster-local -format=json
    {
      "request_id": "4963a8cc-8f01-f293-4298-0e2dc0570310",
      "lease_id": "",
      "lease_duration": 0,
      "renewable": false,
      "data": {
        "allow_any_name": false,
        "allow_bare_domains": false,
        "allow_glob_domains": false,
        "allow_ip_sans": true,
        "allow_localhost": true,
        "allow_subdomains": true,
        "allow_token_displayname": false,
        "allowed_domains": [
          "demo.svc.cluster.local"
        ],
        "allowed_other_sans": null,
        "allowed_serial_numbers": [],
        "allowed_uri_sans": [],
        "basic_constraints_valid_for_non_ca": false,
        "client_flag": true,
        "code_signing_flag": false,
        "country": [],
        "email_protection_flag": false,
        "enforce_hostnames": true,
        "ext_key_usage": [],
        "ext_key_usage_oids": [],
        "generate_lease": false,
        "key_bits": 2048,
        "key_type": "rsa",
        "key_usage": [
          "DigitalSignature",
          "KeyAgreement",
          "KeyEncipherment"
        ],
        "locality": [],
        "max_ttl": 2592000,
        "no_store": false,
        "not_before_duration": 30,
        "organization": [],
        "ou": [],
        "policy_identifiers": [],
        "postal_code": [],
        "province": [],
        "require_cn": true,
        "server_flag": true,
        "street_address": [],
        "ttl": 0,
        "use_csr_common_name": true,
        "use_csr_sans": true
      },
      "warnings": null
    }
    
    ```
##### Vault CRL URL
CRL:
```
~/v1/pki_int/crl/pem (PEM Format)
~/v1/pki_int/crl (Default DER Format)
```