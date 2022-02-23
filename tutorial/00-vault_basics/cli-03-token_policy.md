#

##

####

######

```
# vault token create -policy=default
Key                  Value
---                  -----
token                {{ token }}
token_accessor       {{ accessor }}
token_duration       768h
token_renewable      true
token_policies       ["default"]
identity_policies    []
policies             ["default"]
```