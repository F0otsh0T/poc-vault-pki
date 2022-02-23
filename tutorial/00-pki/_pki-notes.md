# PKI NOTES

##### Definitions
- **ca_chain**: Only Intermediate CA (or Issuing CA)
- **ca_chain bundle**: Root + Intermediate (or just Root if creating CRT & KEY from Root CA)
- **issuing_ca**: Intermediate CA (from perspective of where you are submitting CSR / generating CA from)
- **certificate**: cert (server &/or client depending on role server_flag/client_flag)
- **key**: key (server &/or client depending on role server_flag/client_flag)

##### mTLS Client / Server CRT & KEY Concepts
- Key / Centered around Issuing CA / Chain Trust
- Client / Server CRT & KEY <==Vault PKI Engine==> Vault PKI Certificate Serial Number: Does not need to match on PKI Engine Serial Number - only cares that Issuing CA is legitimate & matches other criteria for lease / validity / etc.,
- ```client_flag``` & ```server_flag``` == x.509 functionality (not Vault)
- Use Vault Output of CRT and KEY as *BOTH* server and client

##### CA Bundle
- ROOT CA + INTERMEDIATE CA Bundle - merge with Server/Client CRT & KEY
- Public Key of Root CA: CORPORATION / Venafi / DigiCert will give Public Key for the Root CA

##### Ubuntu Cert Rotation:
```
sudo mv /tmp/files/vault-ca.pem /opt/vault/tls/ca.crt.pem
sudo mv /tmp/files/vault.pem /opt/vault/tls/vault.crt.pem
sudo mv /tmp/files/vault-key.pem /opt/vault/tls/vault.key.pem
sudo cp /opt/vault/tls/ca.crt.pem /usr/local/share/ca-certificates/custom.crt
sudo update-ca-certificates
```

##### 5G N-Interface Taxonomy Mapping with PKI Engine
- Separate Roles for each N-Interfaces
- x.509 Parameter: Use OU for N-Interface Interaction Designation

##### Vault PKI Engine CRL URL:
```
~/v1/pki_int/crl/pem (PEM Format)
~/v1/pki_int/crl (Default DER Format)
```

