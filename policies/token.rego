package token

jwks_request(url) := http.send({
    "url": url,
    "method": "GET"
})

# use JWKS_URL environment variable
jwks_url := opa.runtime().env.JWKS_URL

# JWKS = Json Web Key Set
jwks := jwks_request(jwks_url).raw_body

jwt := payload {
    # [valid, header, payload]
    # https://www.openpolicyagent.org/docs/latest/policy-reference/#builtin-tokens-iojwtdecode_verify
    [_, _, payload] := io.jwt.decode_verify(input.token, {
        "cert": jwks,
        "alg": "RS256",
        "iss": "http://localhost:8080/realms/demo",
        "aud": "account" # why not client 'app' ?
    })
}

roles := jwt.realm_access.roles
