# VAULT TOKEN

#### TOKEN CREATE
- https://www.vaultproject.io/docs/commands/token/create

Create Token:
```
vault token create -policy=my-policy -policy=other-policy
Key                Value
---                -----
token              95eba8ed-f6fc-958a-f490-c7fd0eda5e9e
token_accessor     882d4a40-3796-d06e-c4f0-604e8503750b
token_duration     768h
token_renewable    true
token_policies     [default my-policy other-policy]
```








#### 









#### REFERENCE
- https://www.vaultproject.io/docs/commands/token
- https://www.vaultproject.io/docs/concepts/tokens








