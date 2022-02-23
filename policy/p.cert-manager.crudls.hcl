# Allow management of secrets path pki (crudls)
path "pki/*" {
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Allow management of secrets path pki_int (crudls)
path "pki_int/*" {
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}