# PKI ENGINE ROLES

### Create a Role
Create a role named demo-svc-cluster-local which allows subdomains.

720 Hours:
```
# vault write pki_int/roles/demo-svc-cluster-local \
allowed_domains="demo.svc.cluster.local" \
allow_subdomains=true \
allow_bare_domains=true \
max_ttl="720h"
Success! Data written to: pki_int/roles/demo-svc-cluster-local
```
24 Hours
```
# vault write pki_int/roles/demo-svc-cluster-local \
allowed_domains="demo.svc.cluster.local" \
allow_subdomains=true \
allow_bare_domains=true \
max_ttl="24h"
Success! Data written to: pki_int/roles/demo-svc-cluster-local
```
10 Minutes
```
# vault write pki_int/roles/demo-svc-cluster-local \
allowed_domains="demo.svc.cluster.local" \
allow_subdomains=true \
allow_bare_domains=true \
server_flag=true \
max_ttl="10m"
Success! Data written to: pki_int/roles/demo-svc-cluster-local
```

### Roles for Server and Client
Server:
```
# vault write pki_int/roles/demo-svc-cluster-local-server \
allowed_domains="demo.svc.cluster.local" \
allow_subdomains=true \
allow_bare_domains=true \
server_flag=true \
client_flag=false \
max_ttl="10m"
Success! Data written to: pki_int/roles/demo-svc-cluster-local-server

# vault read pki_int/roles/demo-svc-cluster-local-server  
Key                                   Value
---                                   -----
allow_any_name                        false
allow_bare_domains                    true
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
client_flag                           false
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
max_ttl                               10m
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
```

Client:
```
# vault write pki_int/roles/demo-svc-cluster-local-client \
> allowed_domains="demo.svc.cluster.local" \
> allow_subdomains=true \
> allow_bare_domains=true \
> server_flag=false \
> client_flag=true \
> max_ttl="10m"
Success! Data written to: pki_int/roles/demo-svc-cluster-local-client

# vault read pki_int/roles/demo-svc-cluster-local-client                               Key                                   Value
---                                   -----
allow_any_name                        false
allow_bare_domains                    true
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
max_ttl                               10m
no_store                              false
not_before_duration                   30s
organization                          []
ou                                    []
policy_identifiers                    []
postal_code                           []
province                              []
require_cn                            true
server_flag                           false
street_address                        []
ttl                                   0s
use_csr_common_name                   true
use_csr_sans                          true

```
### List Roles
```
# vault list pki_int/roles/
Keys
----
demo-svc-cluster-local
demo-svc-cluster-local-client
demo-svc-cluster-local-client-n4
demo-svc-cluster-local-server
demo-svc-cluster-local-server-n4
```
### REFERENCES
https://www.vaultproject.io/api-docs/secret/pki#create-update-role
