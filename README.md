# Api Bluerails

This project uses MIT-LICENSE.

Tools for developing an API written in Rails with api blueprint documentation

## Usage

### Overview of provided Rake Tasks

```shell
rake -T

rake doc:coverage      # Print Coverage of the api blueprint with rails routes
```


### doc:coverage

```shell
>>>
available Routes
-----------------------------------------------------------------------------------------------------------------
                                                                         /assets |         GET, POST, PUT, DELETE
                                                     /oauth/authorize/:code.json |                            GET
                                                           /oauth/authorize.json |         GET, POST, PUT, DELETE
                                                               /oauth/token.json |                           POST
                                                              /oauth/revoke.json |                           POST
                                                                             ...
                                                                /api/status.json |                            GET
                                                     /rails/info/properties.json |         GET, POST, PUT, DELETE
=                                                                             96 | =                          153

<<<


>>>
documneted routes
-----------------------------------------------------------------------------------------------------------------
                                                                /api/status.json |                            GET
                                                               /oauth/token.json |               POST, POST, POST
                                                              /api/v2/users.json |                   POST, DELETE
                                                      /api/v2/users/sign_in.json |                            GET         
=                                                                              4 | =                           7

<<<


>>>
not documented routes
-----------------------------------------------------------------------------------------------------------------
                          /api/v2/partner/{namespace}/{foreign_token}/store.json |                            GET
                   /api/v2/partner/{namespace}/{foreign_token}/transactions.json |                           POST
                      /api/v2/user/payment_identities/{payment_identity_id}.json |                    PUT, DELETE
=                                                                              3 | =                           4

<<<
echo $?
4

```
