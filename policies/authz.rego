package authz

import data.request.action
import data.token.jwks_url
import data.token.jwks
import data.token.jwt
import data.token.roles
import future.keywords

default allow := false

debug := {"token": token, "jwks_url": jwks_url, "jwks": jwks} {
    jwks_url = jwks_url
    jwks = jwks
    token = jwt
}

# allow action 'view_post' for 'user' role
allow {
    action == "view_post"
    some role in roles
    role == "user"
}

# allow all actions for 'admin' role
allow {
    some role in roles
    role == "admin"
}
