#!/bin/bash

kubectl cp vault/policy-app-1-dev.hcl --namespace=vault-infra vault-0:/tmp/
kubectl cp vault/policy-app-2-dev.hcl --namespace=vault-infra vault-0:/tmp/
kubectl cp vault/policy-app-1-staging.hcl --namespace=vault-infra vault-0:/tmp/
kubectl cp cert/cert-b64 --namespace=vault-infra vault-0:/tmp/
kubectl cp cert/key-b64 --namespace=vault-infra vault-0:/tmp/
kubectl cp configure-vault.sh --namespace=vault-infra vault-0:/tmp/