path "secret/data/app-1/staging/*" {
  capabilities = ["read", "list"]
}

path "secret/data/app-1/staging/generated/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}