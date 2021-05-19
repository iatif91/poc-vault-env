#!/bin/bash

kubectl create namespace vault-infra
kubectl create namespace ns1
kubectl create namespace ns2
kubectl create namespace ns3

kubectl create sa app-1-dev --namespace=ns1
kubectl create sa app-2-dev --namespace=ns2
kubectl create sa app-1-staging --namespace=ns3

kubectl create -f k8s/roles.yaml