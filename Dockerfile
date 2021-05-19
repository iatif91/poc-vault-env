FROM ghcr.io/banzaicloud/vault-env:1.12.0 AS VAULT-ENV

FROM alpine:latest 

RUN mkdir /vault
COPY --from=VAULT-ENV /usr/local/bin/vault-env /vault/