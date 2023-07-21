# keycloak-oidc-jwt-opa-demo

This is a demonstration of Open Policy Agent checking access for a given JWT of a OpenID Connect client configured in Keycloak instance.

It uses simple RBAC for demonstration but using e.g. ABAC would be a better approach.

__Please remember that this keycloak setup is not meant for production.__

## Introduction

We assume having an API with `view_post` and `create_post` actions.

There are three roles `guest`, `user` and `admin`:

- The role `guest` is a user without registration (or not authenticated). He/she has no access to the API.
- The role `user` is a registered user who can view posts. But he/she cannot create posts.
- The role `admin` is privileged user who can view and create posts.

## Local infrastructure

The local docker environment contains keycloak, opa and a nginx service. The nginx is used as a provider for the opa bundles (*.tar.gz file) which will be fetched and used by the opa daemon service. 

## Start dockerized environment in background

```shell
docker-compose up -d
```

## Test OPA policies

```shell
./test.sh
```

Make sure that the local docker environment is running because the tests are retrieving access token from the keycloak container. (Sadly `io.jwt.decode_verify()` does not work with token that never expire)

## Build OPA Bundle

```shell
./build.sh
```

If you make changes to the opa rego files then run this command again. The OPA service will then fetch the updated bundle file.

## Usage

### Get JWT access token for user 'user' or 'admin' of client 'app'

```shell
curl -XPOST http://localhost:8080/realms/demo/protocol/openid-connect/token/ -d "grant_type=password" -d "client_id=app" -d "username=user" -d "password=123456" | jq -r .access_token
curl -XPOST http://localhost:8080/realms/demo/protocol/openid-connect/token/ -d "grant_type=password" -d "client_id=app" -d "username=admin" -d "password=123456" | jq -r .access_token
```

### OPA Requests for demonstration

Replace the token placeholder with the previously requested token from keycloak.

```shell
curl -XPOST http://localhost:8181/v1/data/authz -d '{"input":{"action":"view_post"}}' | jq
curl -XPOST http://localhost:8181/v1/data/authz -d '{"input":{"action":"create_post"}}' | jq
curl -XPOST http://localhost:8181/v1/data/authz -d '{"input":{"action":"view_post", "token": "XXX"}}' | jq
curl -XPOST http://localhost:8181/v1/data/authz -d '{"input":{"action":"create_post", "token": "XXX"}}' | jq
```

## More

## Get JWKS from keycloak

```shell
curl http://localhost:8080/realms/demo/protocol/openid-connect/certs
```

## Export realm

```shell
docker-compose exec -it keycloak bash
/opt/keycloak/bin/kc.sh export --file /opt/keycloak/data/import/demo-realm.json --realm demo --users realm_file
```
