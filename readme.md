# PoC Using vault-env without the mutating webhooks

We were looking for a secure way to inject Vault secrets in our containers for applications that cannot directly be intgrated with Vault (like Spring Boot ones for eg).
Using HashiCorp initContainer/sidecar was not considered as good enough as the secrets get written into a file and thus are somehow exposed. 
After a little digging, we came accross a very intresting solution from [Bazai Cloud](https://banzaicloud.com/docs/bank-vaults/mutating-webhook/ ) that uses mutating webhooks capabilities of Kubernetes in orderd to:

> [...] an init-container will be injected into the given Pod. This container copies the vault-env binary into an in-memory volume and mounts that Volume to every container which has an environment variable definition like that. It also changes the command of the container to run vault-env instead of your application directly. When vault-env starts up, it connects to Vault to checks the environment variables. (By default, vault-env uses the Kubernetes Auth method, but you can also configure other authentication methods for the webhook.) The variables that have a reference to a value stored in Vault (vault:secret/....) are replaced with that value read from the Secret backend. After this, vault-env immediately executes (with syscall.Exec()) your process with the given arguments, replacing itself with that process (in non-daemon mode).

> With this solution none of your Secrets stored in Vault will ever land in Kubernetes Secrets, thus in etcd.

> vault-env was designed to work in Kubernetes in the first place, but nothing stops you to use it outside Kubernetes as well. It can be configured with the standard Vault client’s environment variables (because there is a standard Go Vault client underneath).

But in our context, as we're hosted on a shared Kubernetes Cluster, deploying mutating webhooks, ClusterRoles etc was not an option, at least in the short term. So we explored embedding vault-env in our images and using it without the need of mutating webhook.

This repository is a step by step tutorial of a working configuration that uses vault-env binary to inject Vault secrets directly in your container.

For the following, you'll need to install: kind, kubectl, helm and jq.

## Kind cluster setup a kind cluster

```shell
##export PATH=/Users/iatif/k8s-tools:$PATH
kind create cluster
kubectl cluster-info --context kind-kind
./setup-k8s.sh
```

## Vault intall and configuration

```shell
helm repo add hashicorp https://helm.releases.hashicorp.com
helm --namespace vault-infra install vault hashicorp/vault
## Pod status
kubectl describe pod/vault-0 --namespace=vault-infra
```

Once Vault pod is started (but not ready), proceed with Vault setup:

```shell
## Vault initialization
kubectl exec --namespace=vault-infra vault-0 -- vault operator init -key-shares=1 -key-threshold=1 -format=json > cluster-keys.json

## Unseal the Vault
VAULT_UNSEAL_KEY=$(cat cluster-keys.json | jq -r ".unseal_keys_b64[]")
kubectl exec --namespace=vault-infra vault-0 -- vault operator unseal $VAULT_UNSEAL_KEY

## Token for authentication
cat cluster-keys.json | jq -r ".root_token"

## Copy files into Vault container
./copy-files-to-vault.sh

## Shell into Vault container
kubectl exec --namespace=vault-infra --stdin=true --tty=true vault-0 -- /bin/sh
## in Vault container
vault login
sh /tmp/configure-vault.sh
```

# Deploy the apps

```shell
kubectl create -f k8s/deployment.yaml
```
App1-dev and app2-dev will fail to start at different stages of the vault-env workflow. App1-staging will work as expected, notice secrets retrivied and inline mutation (base64 decoding in our eg). 

