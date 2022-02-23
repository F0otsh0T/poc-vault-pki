```





wget --quiet https://releases.hashicorp.com/vault/1.4.2/vault_1.4.2_linux_amd64.zip

wget https://releases.hashicorp.com/vault/1.4.2/vault_1.4.2_linux_amd64.zip


export VAULT_ADDR=http://vault.default.svc.cluster.local:8200
export VAULT_TOKEN=s.MDXxMYVcth9tzBbct41istbm
export http_proxy=""
export https_proxy=""


curl --header "X-Vault-Token: s.MDXxMYVcth9tzBbct41istbm" http://vault.default.svc.cluster.local:8200/v1/ca/roles/xip-dot-io

curl --header "X-Vault-Token: s.MDXxMYVcth9tzBbct41istbm" http://vault.default.svc.cluster.local:8200/v1/ca/

curl --header "X-Vault-Token: s.MDXxMYVcth9tzBbct41istbm" http://vault.default.svc.cluster.local:8200/v1/ca/pem/

curl --header "X-Vault-Token: s.MDXxMYVcth9tzBbct41istbm" http://vault.default.svc.cluster.local:8200/v1/pki/cert/crl
curl --header "X-Vault-Token: s.MDXxMYVcth9tzBbct41istbm" http://vault.default.svc.cluster.local:8200/v1/pki_int/cert/crl

curl --header "X-Vault-Token: s.MDXxMYVcth9tzBbct41istbm" http://vault.default.svc.cluster.local:8200/v1/pki/ca_chain
curl --header "X-Vault-Token: s.MDXxMYVcth9tzBbct41istbm" http://vault.default.svc.cluster.local:8200/v1/pki_int/ca_chain

curl --header "X-Vault-Token: s.MDXxMYVcth9tzBbct41istbm" --request LIST http://vault.default.svc.cluster.local:8200/v1/pki/certs
curl --header "X-Vault-Token: s.MDXxMYVcth9tzBbct41istbm" --request LIST http://vault.default.svc.cluster.local:8200/v1/pki_int/certs

curl --header "X-Vault-Token: s.MDXxMYVcth9tzBbct41istbm" http://vault.default.svc.cluster.local:8200/v1/pki/crl/pem
curl --header "X-Vault-Token: s.MDXxMYVcth9tzBbct41istbm" http://vault.default.svc.cluster.local:8200/v1/pki_int/crl_pem

curl --header "X-Vault-Token: s.MDXxMYVcth9tzBbct41istbm" http://vault.default.svc.cluster.local:8200/v1/pki/roles/xip-dot-io
curl --header "X-Vault-Token: s.MDXxMYVcth9tzBbct41istbm" http://vault.default.svc.cluster.local:8200/v1/pki_int/issue/xip-dot-io

curl --header "X-Vault-Token: s.MDXxMYVcth9tzBbct41istbm" http://vault.default.svc.cluster.local:8200/v1/pki_int/cert/1a:cc:72:45:9e:19:35:b4:70:45:81:b9:2d:aa:23:b3:75:a6:74:fe

curl --header "X-Vault-Token: s.MDXxMYVcth9tzBbct41istbm" http://vault.default.svc.cluster.local:8200/v1/pki_int/cert/1a:cc:72:45:9e:19:35:b4:70:45:81:b9:2d:aa:23:b3:75:a6:74:fe | jq

curl --header "X-Vault-Token: s.MDXxMYVcth9tzBbct41istbm" http://vault.default.svc.cluster.local:8200/v1/pki_int/cert/1a:cc:72:45:9e:19:35:b4:70:45:81:b9:2d:aa:23:b3:75:a6:74:fe | jq '.data.certificate'


curl -w json --header "X-Vault-Token: s.MDXxMYVcth9tzBbct41istbm" http://vault.default.svc.cluster.local:8200/v1/pki_int/cert/1a:cc:72:45:9e:19:35:b4:70:45:81:b9:2d:aa:23:b3:75:a6:74:fe -o test

curl -w 'code: %{certificate}' --header "X-Vault-Token: s.MDXxMYVcth9tzBbct41istbm" http://vault.default.svc.cluster.local:8200/v1/pki_int/cert/1a:cc:72:45:9e:19:35:b4:70:45:81:b9:2d:aa:23:b3:75:a6:74:fe -o test

curl -w 'code: %{data.certificate}' --header "X-Vault-Token: s.MDXxMYVcth9tzBbct41istbm"http://vault.default.svc.cluster.local:8200/v1/pki_int/cert/1a:cc:72:45:9e:19:35:b4:70:45:81:b9:2d:aa:23:b3:75:a6:74:fe -o test

curl --header "X-Vault-Token: s.MDXxMYVcth9tzBbct41istbm" http://vault.default.svc.cluster.local:8200/v1/pki_int/ca/pem | openssl x509 -text

curl --header "X-Vault-Token: s.MDXxMYVcth9tzBbct41istbm" http://vault.default.svc.cluster.local:8200/v1/pki/cert/:1a:cc:72:45:9e:19:35:b4:70:45:81:b9:2d:aa:23:b3:75:a6:74:fe





```