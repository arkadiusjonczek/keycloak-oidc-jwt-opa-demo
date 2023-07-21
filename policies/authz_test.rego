package authz.test

import data.authz.allow

mock_token_user := get_token("user")
mock_token_admin := get_token("admin")

get_token(user) := json.unmarshal(http.send({
    "url": "http://localhost:8080/realms/demo/protocol/openid-connect/token/",
    "method": "POST",
    "headers": {
        "Content-Type": "application/x-www-form-urlencoded"
    },
    "raw_body": sprintf("grant_type=password&client_id=app&username=%s&password=123456", [user])
}).raw_body).access_token

jwks_url := "http://localhost:8080/realms/demo/protocol/openid-connect/certs"

# --- tests ---

# role = guest
test_disallow_view_post_for_guest {
    allow == false
    with input as {
        "action": "view_post"
    }
    with data.token.jwks_url as jwks_url
}

test_disallow_create_post_for_guest {
    allow == false
    with input as {
        "action": "create_post"
    }
    with data.token.jwks_url as jwks_url
}

# role = user
test_allow_view_post_for_user {
    allow == true
    with input as {
        "action": "view_post",
        "token" : mock_token_user
    }
    with data.token.jwks_url as jwks_url
}

test_disallow_create_post_for_user {
    allow == false
    with input as {
        "action": "create_post",
        "token" : mock_token_user
    }
    with data.token.jwks_url as jwks_url
}

# role = admin
test_allow_view_post_for_user {
    allow == true
    with input as {
        "action": "view_post",
        "token" : mock_token_admin
    }
    with data.token.jwks_url as jwks_url
}

test_disallow_create_post_for_user {
    allow == true
    with input as {
        "action": "create_post",
        "token" : mock_token_admin
    }
    with data.token.jwks_url as jwks_url
}