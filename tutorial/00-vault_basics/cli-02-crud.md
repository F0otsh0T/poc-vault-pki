#### VAULT CLI CRUD
Assuming an existing Secret Engine (hello) => Secret (test) exists:
###### HELP AND INTRO
```
# vault secrets list
Path          Type         Accessor              Description
----          ----         --------              -----------
cubbyhole/    cubbyhole    cubbyhole_b0548235    per-token private secret storage
hello/        kv           kv_9055d1ef           n/a
identity/     identity     identity_eaf773c9     identity store
sys/          system       system_629cc1f2       system endpoints used for control, policy and debugging

# vault kv --help
Usage: vault kv <subcommand> [options] [args]

  This command has subcommands for interacting with Vault's key-value
  store. Here are some simple examples, and more detailed examples are
  available in the subcommands or the documentation.

  Create or update the key named "foo" in the "secret" mount with the value
  "bar=baz":

      $ vault kv put secret/foo bar=baz

  Read this value back:

      $ vault kv get secret/foo

  Get metadata for the key:

      $ vault kv metadata get secret/foo
          
  Get a specific version of the key:

      $ vault kv get -version=1 secret/foo

  Please see the individual subcommand help for detailed usage information.

Subcommands:
    delete               Deletes versions in the KV store
    destroy              Permanently removes one or more versions in the KV store
    enable-versioning    Turns on versioning for a KV store
    get                  Retrieves data from the KV store
    list                 List data or secrets
    metadata             Interact with Vault's Key-Value storage
    patch                Sets or updates data in the KV store without overwriting
    put                  Sets or updates data in the KV store
    rollback             Rolls back to a previous version of data
    undelete             Undeletes versions in the KV store
```
###### [CREATE]RUD
```
# vault kv put hello/test key=value
Key              Value
---              -----
created_time     2020-04-14T22:45:55.52113438Z
deletion_time    n/a
destroyed        false
version          6

# vault kv get hello/test
====== Metadata ======
Key              Value
---              -----
created_time     2020-04-14T22:45:55.52113438Z
deletion_time    n/a
destroyed        false
version          6

=== Data ===
Key    Value
---    -----
key    value
```
```
# vault kv put hello/test test=put
Key              Value
---              -----
created_time     2020-04-14T22:46:14.644568967Z
deletion_time    n/a
destroyed        false
version          7

# vault kv get hello/test
====== Metadata ======
Key              Value
---              -----
created_time     2020-04-14T22:46:14.644568967Z
deletion_time    n/a
destroyed        false
version          7

==== Data ====
Key     Value
---     -----
test    put
```
###### CR[UPDATE]D
```
# vault kv patch hello/test test2=patch
Key              Value
---              -----
created_time     2020-04-14T22:47:27.498467331Z
deletion_time    n/a
destroyed        false
version          8

# vault kv get hello/test
====== Metadata ======
Key              Value
---              -----
created_time     2020-04-14T22:47:27.498467331Z
deletion_time    n/a
destroyed        false
version          8

==== Data ====
Key      Value
---      -----
test     put
test2    patch
```

###### C[READ]UD
```
# vault kv get hello/test
====== Metadata ======
Key              Value
---              -----
created_time     2020-04-14T22:47:27.498467331Z
deletion_time    n/a
destroyed        false
version          8

==== Data ====
Key      Value
---      -----
test     put
test2    patch

# vault kv get hello/test
====== Metadata ======
Key              Value
---              -----
created_time     2020-04-14T22:47:27.498467331Z
deletion_time    n/a
destroyed        false
version          8

==== Data ====
Key      Value
---      -----
test     put
test2    patch
 
# vault kv get -field=test2 hello/test
patch

# vault kv get -format=json hello/test
{
  "request_id": "6721fab2-e0e1-2008-0218-e0d7561bbdae",
  "lease_id": "",
  "lease_duration": 0,
  "renewable": false,
  "data": {
    "data": {
      "test": "put",
      "test2": "patch"
    },
    "metadata": {
      "created_time": "2020-04-14T22:47:27.498467331Z",
      "deletion_time": "",
      "destroyed": false,
      "version": 8
    }
  },
  "warnings": null
}
```

###### CRU[DELETE]
```
# vault kv delete hello/test
Success! Data deleted (if it existed) at: hello/test

# vault kv get hello/test
====== Metadata ======
Key              Value
---              -----
created_time     2020-04-14T22:47:27.498467331Z
deletion_time    2020-04-20T19:14:33.254060949Z
destroyed        false
version          8
```




## VAULT SECRETS ENGINES

#### ENABLE SECRETS ENGINE
```
# vault secrets enable -path=kv kv
Success! Enabled the kv secrets engine at: kv/

# vault secrets enable kv
Error enabling: Error making API request.

URL: POST http://127.0.0.1:8200/v1/sys/mounts/kv
Code: 400. Errors:

* path is already in use at kv/

# vault secrets list
Path          Type         Accessor              Description
----          ----         --------              -----------
cubbyhole/    cubbyhole    cubbyhole_b0548235    per-token private secret storage
hello/        kv           kv_9055d1ef           n/a
identity/     identity     identity_eaf773c9     identity store
kv/           kv           kv_2ff98680           n/a
sys/          system       system_629cc1f2       system endpoints used for control, policy and debugging

/ $ vault kv put kv/hello target=world
Success! Data written to: kv/hello
/ $ vault kv get kv/hello
===== Data =====
Key       Value
---       -----
target    world

# vault kv put kv/my-secret vault="s3c(et"
Success! Data written to: kv/my-secret

# vault kv get kv/my-secret
==== Data ====
Key      Value
---      -----
vault    s3c(et

# vault kv delete kv/my-secret
Success! Data deleted (if it existed) at: kv/my-secret

# vault kv list kv/
Keys
----

# vault secrets disable kv/
Success! Disabled the secrets engine (if it existed) at: kv/

# vault secrets list
Path          Type         Accessor              Description
----          ----         --------              -----------
cubbyhole/    cubbyhole    cubbyhole_b0548235    per-token private secret storage
hello/        kv           kv_9055d1ef           n/a
identity/     identity     identity_eaf773c9     identity store
sys/          system       system_629cc1f2       system endpoints used for control, policy and debugging
```












