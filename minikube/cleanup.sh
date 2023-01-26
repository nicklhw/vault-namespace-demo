#!/bin/bash

NAMESPACE='vault'
VAULT_CS_NAMESPACE='customer-success'

export VAULT_ADDR=http://localhost:8200
export VAULT_TOKEN=$(cat ../docker-compose/scripts/vault.json | jq -r .root_token)

helm delete vault --namespace=${NAMESPACE}

kubectl delete namespace vault
kubectl delete namespace us-east
kubectl delete namespace us-west

vault auth disable -namespace=${VAULT_CS_NAMESPACE} kubernetes