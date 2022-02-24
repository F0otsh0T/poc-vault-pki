# VAULT - CUBBYHOLE

## TUTORIAL

#### **WRITE TOKEN-BASED SECRETS**

Login with the dev mode server initial root token.

```
vault-server:~# vault login root
Success! You are now authenticated. The token information displayed below
is already stored in the token helper. You do NOT need to run "vault login"
again. Future Vault requests will automatically use this token.

Key                  Value
---                  -----
token                root
token_accessor       q0YZUMahIHvMVjCBNBuDbeXN
token_duration       ∞
token_renewable      false
token_policies       ["root"]
identity_policies    []
policies             ["root"]

```

To better demonstrate the cubbyhole secrets engine, first create a non-privileged token.

```

vault-server:~# vault token create -policy=default \
>     -format=json | jq -r ".auth.client_token" > token.txt
vault-server:~# cat token.txt
s.nD3eU4ZvmMN1nxeLv9YI5X48

```

Now, log into Vault using the newly generated token:

```

vault-server:~# vault login $(cat token.txt)
Success! You are now authenticated. The token information displayed below
is already stored in the token helper. You do NOT need to run "vault login"
again. Future Vault requests will automatically use this token.

Key                  Value
---                  -----
token                s.nD3eU4ZvmMN1nxeLv9YI5X48
token_accessor       DqxyhOy4B9g5ZWBLeip5cIpS
token_duration       767h59m33s
token_renewable      true
token_policies       ["default"]
identity_policies    []
policies             ["default"]

```

Your token has ```default``` policy attached which does not give you access to any of the secrets engines except cubbyhole. You can test that by running the following command:

```

vault-server:~# vault kv put secret/test password="my-password"
Error making API request.

URL: GET http://localhost:8200/v1/sys/internal/ui/mounts/secret/test
Code: 403. Errors:

* preflight capability check returned 403, please ensure client's policies grant access to path "secret/test/"

```

This should result in a ```permission denied``` error.

**WRITE SECRETS IN CUBBYHOLE**

Execute the following command to write secret in the ```cubbyhole/private``` path:

```

vault-server:~# vault write cubbyhole/private mobile="123-456-7890"
Success! Data written to: cubbyhole/private

```

Read back the secret you just wrote. It should return the secret.

```

vault-server:~# vault read cubbyhole/private
Key       Value
---       -----
mobile    123-456-7890

```

Try as a root

Log back in with root token:

```

vault-server:~# vault login root
Success! You are now authenticated. The token information displayed below
is already stored in the token helper. You do NOT need to run "vault login"
again. Future Vault requests will automatically use this token.

Key                  Value
---                  -----
token                root
token_accessor       q0YZUMahIHvMVjCBNBuDbeXN
token_duration       ∞
token_renewable      false
token_policies       ["root"]
identity_policies    []
policies             ["root"]

```

Now, try to read the ```cubbyhole/private``` path.
What response did you receive?

Cubbyhole secret backend provide an isolated secrete storage area for an individual token where no other token can violate.

```

vault-server:~# vault read cubbyhole/private
No value found at cubbyhole/private

```


#### **CUBBYHOLE WRAPPING TOKEN**

Think of a scenario where apps read secrets from Vault. The apps need:

- Policy granting "read" permission on the specific path (```secret/dev```)
- Valid tokens to interact with Vault.
- More privileged token (e.g. admin) wraps a secret only the expecting client can read.
- The receiving client (an app) unwraps the secret to obtain the token.

When the response to ```vault token create``` request is wrapped, Vault inserts the generated token into the ```cubbyhole``` of a single-use token, returning that single-use wrapping token. Retrieving the secret requires an ```unwrap``` operation against this wrapping token.

Since you are currently logged in as a root, you are going to perform the following to demonstrate the apps operations:

1. Create a token with default policy.
2. Unwrap the secret to obtain the apps token.
3. Verify that you can read ```secret/dev``` using the apps token.
4. Verify that ```root``` cannot read the cubbyhole secrets written by another token.

To clear the screen: ```clear```.

Create a New Token for Apps

A policy file (```apps-policy.hcl```) is provided.

```

vault-server:~# cat apps-policy.hcl
path "secret/data/dev" {
  capabilities = [ "read" ]
}

```

This policy grants read operation on the ```secret/dev``` and nothing else.

```

path "secret/data/dev" {
  capabilities = [ "read" ]
}

```

Execute the following command to create a new policy named, ```apps-policy```:

```

vault-server:~# vault policy write apps apps-policy.hcl
Success! Uploaded policy: apps

```

Also, write some data in ```secret/data/dev``` for testing:

```

vault-server:~# vault kv put secret/dev apikey="1234567890"
Key                Value
---                -----
created_time       2022-02-23T21:52:37.221902824Z
custom_metadata    <nil>
deletion_time      n/a
destroyed          false
version            1

```

To create a new token using response wrapping, run the ```vault token create``` command with ```-wrap-ttl``` flag:

```

vault token create -policy=$POLICY_NAME -wrap-ttl=$WRAP_TTL_VALUE

```

Execute the following commands to generate a token for apps using response wrapping with TTL of 360 seconds, and save the generated wrapping token in a file named, ```wrapping_token.txt```

```

vault-server:~# vault token create -policy=apps -wrap-ttl=360 \
>     -format=json | jq -r ".wrap_info.token" > wrapping-token.txt
vault-server:~# cat wrapping-token.txt 
s.zOJ5RZiLcVafzBzHLSRIM43H

```
    NOTE: The response is the wrapping token rather than the actual client token for apps-policy; therefore, the admin user does not even see the generated token that he/she generated. After 360 seconds, the wrapping token gets expired that its wrapped content will no longer discoverable.

#### **UNWRAP SECRETS**

In order for the apps to acquire a valid token to read secrets from ```secret/data/dev``` path, it must run the unwrap operation using this token.

Use ```vault unwrap``` command to retrieve the wrapped secrets as follow:

```

vault unwrap 

```

or

```

VAULT_TOKEN= vault unwrap

```

or

```

vault login 
vault unwrap

```

Let's unwrap the secret which contains the client token with ```apps```. The following command stores the resulting token in ```client-token.txt```.

```

vault-server:~# vault unwrap -format=json $(cat wrapping-token.txt) \
>     | jq -r ".auth.client_token" > client-token.txt


```

Log into Vault using the token you just uncovered:

```

vault-server:~# vault login $(cat client-token.txt)
Success! You are now authenticated. The token information displayed below
is already stored in the token helper. You do NOT need to run "vault login"
again. Future Vault requests will automatically use this token.

Key                  Value
---                  -----
token                s.FFemppZQtWEj0fsV9FArF87C
token_accessor       WesqtY0vZteML5hCwJsvvy3B
token_duration       767h59m23s
token_renewable      true
token_policies       ["apps" "default"]
identity_policies    []
policies             ["apps" "default"]

```

Remember that the ```apps``` policy has a very limited privilege, that does not grant any other capabilities on the ```secret/data/dev``` path than read. Run the following command to verify that you can read the data at ```secret/dev```:

```

vault-server:~# vault kv get secret/dev
======= Metadata =======
Key                Value
---                -----
created_time       2022-02-23T22:14:40.933199461Z
custom_metadata    <nil>
deletion_time      n/a
destroyed          false
version            1

===== Data =====
Key       Value
---       -----
apikey    1234567890

```

Wrap Any Response

Wrapping a token is just one example use of Cubbyhole. If you have a user credential stored in Vault and wish to distribute it securely, you can use response wrapping.

Login with root token again:

```

vault-server:~# vault login root
Success! You are now authenticated. The token information displayed below
is already stored in the token helper. You do NOT need to run "vault login"
again. Future Vault requests will automatically use this token.

Key                  Value
---                  -----
token                root
token_accessor       MmvrBOBUDF04b3zIk8C6SDm2
token_duration       ∞
token_renewable      false
token_policies       ["root"]
identity_policies    []
policies             ["root"]

```

Write some secrets:

```

vault-server:~# vault kv put secret/app_credential user_id="project-admin" password="my-long-password"
Key                Value
---                -----
created_time       2022-02-23T22:17:15.250582555Z
custom_metadata    <nil>
deletion_time      n/a
destroyed          false
version            1

```


Without response wrapping enabled, the output is visible:

```

vault-server:~# vault kv get secret/app_credential
======= Metadata =======
Key                Value
---                -----
created_time       2022-02-23T22:17:15.250582555Z
custom_metadata    <nil>
deletion_time      n/a
destroyed          false
version            1

====== Data ======
Key         Value
---         -----
password    my-long-password
user_id     project-admin

```
    
But when you wrap the ```get``` response, the resulting data from the command invocation is not printed to standard output. The response from the ```vault kv``` get operation is placed into the cubbyhole tied to the single use token (```wrapping_token```).

```

vault-server:~# vault kv get -format=json -wrap-ttl=60 secret/app_credential \
>      | jq -r ".wrap_info.token" > wrapping-token.txt

```

```

vault-server:~# vault kv get -wrap-ttl=60 secret/app_credential
Key                              Value
---                              -----
wrapping_token:                  s.mWUpEi4xPJo1dDV5TQSz4SbE
wrapping_accessor:               DaIKzBpLrxIfaLhQq2PizI02
wrapping_token_ttl:              1m
wrapping_token_creation_time:    2022-02-23 22:18:16.31501954 +0000 UTC
wrapping_token_creation_path:    secret/data/app_credential

```

Using the ```wrapping_token```, you can unwrap the response:

```

vault-server:~# vault unwrap -format=json $(cat wrapping-token.txt)
{
  "request_id": "eadd6227-13b0-1e71-0126-242a21fbb41a",
  "lease_id": "",
  "lease_duration": 0,
  "renewable": false,
  "data": {
    "data": {
      "password": "my-long-password",
      "user_id": "project-admin"
    },
    "metadata": {
      "created_time": "2022-02-23T22:17:15.250582555Z",
      "custom_metadata": null,
      "deletion_time": "",
      "destroyed": false,
      "version": 1
    }
  },
  "warnings": null
}

```

NOTE: If you run the ```unwrap``` command again, it fails since the ```wrapping_token``` is a single-use token. Just like any other token, you can revoke ```wrapping_token``` if you think it was compromised at any time.

```

vault-server:~# vault unwrap -format=json $(cat wrapping-token.txt)
Error unwrapping: Error making API request.

URL: PUT http://localhost:8200/v1/sys/wrapping/unwrap
Code: 400. Errors:

* wrapping token is not valid or does not exist

```


#### **VAULT UI**

Use the CLI to enable the ```userpass``` auth method.

```

vault-server:~# vault auth enable userpass
Success! Enabled userpass auth method at: userpass/

```

Create a user, "bob" with only the ```default``` policy attached. The password is "password".

```

vault-server:~# vault write auth/userpass/users/bob password="password" policies="default"
Success! Data written to: auth/userpass/users/bob

```

Web UI

    1. Click on the Vault UI tab to launch the Vault UI.
    2. Enter root in the Token text field and then click Sign In. (from CLI, ```cat ~/.vault-token```)
    3. Select secret > app_credential.
    4. Select Copy > Wrap secret.
    5. Copy the wrapping token by clicking the clipboard icon.
    6. Sign out of the UI.

    1. Select Username under Method, enter bob in the Username text field, and password in the Password field.
    2. Click Sign In.
    3. Notice that "bob" only has a visibility to the Cubbyhole secrets engine.
    4. Select Tools and then Unwrap.
    5. Enter the wrapping token value you copied earlier in the Wrapping token field, and then click Unwrap data.
    6. Sign out of the UI.

#### SUMMARY

When you need to pass secrets to someone who does not have access to the secret path or even Vault, use the response wrapping. The wrapping token is a reference to the secret location; therefore, you don't have to send the secrets over the public network. In fact, the secrets remain within the Vault.











