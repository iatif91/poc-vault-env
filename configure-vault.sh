#!/bin/bash

# Enable kv secret engine
vault secrets enable -path=secret kv-v2

# Enable & Configure Kubernetes Auth method
vault auth enable -path=k8s kubernetes
vault write auth/k8s/config \
    kubernetes_host=https://10.96.0.1:443 \
    kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt

# Write Policies
vault policy write app-1-dev /tmp/policy-app-1-dev.hcl
vault policy write app-2-dev /tmp/policy-app-2-dev.hcl
vault policy write app-1-staging /tmp/policy-app-1-staging.hcl

# Write Roles
vault write auth/k8s/role/app-1-dev \
     bound_service_account_names=app-1-dev \
     bound_service_account_namespaces=ns1 \
     policies=app-1-dev \
     ttl=24h
vault write auth/k8s/role/app-2-dev \
     bound_service_account_names=app-2-dev \
     bound_service_account_namespaces=ns2 \
     policies=app-2-dev \
     ttl=24h
vault write auth/k8s/role/app-1-staging \
     bound_service_account_names=app-1-staging \
     bound_service_account_namespaces=ns3 \
     policies=app-1-staging \
     ttl=24h

# Write secrets
vault kv put secret/app-1/dev/ibm-cloud IBM_ACCESS_KEY=s3cr3t-app-1-dev-ns1
vault kv put secret/app-2/dev/ibm-cloud IBM_ACCESS_KEY=s3cr3t-app-2-dev-ns2
vault kv put secret/app-1/staging/ibm-cloud IBM_ACCESS_KEY=s3cr3t-app-1-staging-ns3

vault kv put secret/app-1/staging/nginx-cert key=@/tmp/key-b64 certificate=@/tmp/cert-b64 key-passcode=poc_vault